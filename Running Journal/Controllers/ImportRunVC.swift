//
//  ImportRunVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-11-14.
//

import UIKit
import HealthKit

class ImportRunVC: UIViewController {
    
    let userDefaults = UserDefaults.standard
    var distanceUnits = "km"
    
    
    @IBOutlet weak var healthRunsTableView: UITableView!
    @IBOutlet weak var noRunsLabel: UILabel!
    
    struct healthRun
    {
        //var workout: HKWorkout
        var distance: Double
        var date: Date
        var duration: TimeInterval
        var temp: Int?
    }
    
    var healthRuns:[healthRun] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: K.userDefaults.badgeCount)
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0)
        }
       // getNotificationPermission()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        noRunsLabel.isHidden = true
        distanceUnits = userDefaults.string(forKey: K.userDefaults.distance) ?? "km"
        getRunsDataFromHealth()
        healthRunsTableView.delegate = self
        healthRunsTableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    @objc func willEnterForeground()
    {
        
        if healthRunsTableView.isHidden
        {
            getRunsDataFromHealth()
        }
    }
    
    
    
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
//    func getNotificationPermission()
//    {
//        print("FA")
//        let un = UNUserNotificationCenter.current()
//        un.requestAuthorization { success, error in
//            if error != nil{
//                print(error?.localizedDescription)
//            }
//        }
//    }
//    func startObservingRuns(healthKitStore:HKHealthStore)
//    {
//        let sampleType = HKObjectType.workoutType()
//        var query = HKObserverQuery(sampleType: sampleType, predicate: HKQuery.predicateForWorkouts(with: .running)) { query, completionHandler, error in
//            let content = UNMutableNotificationContent()
//            content.title = "Add your run to Running Journal!"
//            let request = UNNotificationRequest(identifier: "runningJournal", content: content, trigger: nil)
//            UNUserNotificationCenter.current().add(request) { error in
//                if error != nil
//                {
//                    print(error?.localizedDescription)
//                }
//            }
//        }
//        healthKitStore.execute(query)
//        print("AD")
//        healthKitStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { succeeded, error in
//            if error != nil
//            {
//                print(error?.localizedDescription)
//            }
//            print("FEA")
//        }
//    }
    
    func getRunsDataFromHealth()
    {
        if HKHealthStore.isHealthDataAvailable() { // Add code to use HealthKit here.
            let healthStore = HKHealthStore()
            
            Task {
                requestUserPermission(store: healthStore)
                if HKHealthStore.isHealthDataAvailable()
                {
                    //startObservingRuns(healthKitStore: healthStore)
                    //backgroundDelivery(store: healthStore)
                    let workouts = await readWorkouts(store: healthStore)
                    if workouts != nil
                    {
                        var count = 0
                        for workout in workouts!
                        {
                            count += 1
                            let w = workout
                            
                            let forWorkout = HKQuery.predicateForObjects(from: workout)
                            let distanceDescription = HKQueryDescriptor(sampleType: HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!, predicate: forWorkout)
                            
                            let distanceQuery = HKSampleQuery(queryDescriptors: [distanceDescription], limit: HKObjectQueryNoLimit) { query, samples, error in
                                
                                guard let samples = samples else {
                                    
                                    fatalError(error!.localizedDescription)
                                }
                                var sum = 0.0
                                
                                for sample in samples {
                                    
                                    guard let sam = sample as? HKQuantitySample else {return}
                                    sum += sam.quantity.doubleValue(for: HKUnit.meterUnit(with: .kilo))
                                    
                                }
                                
                                let temp = w.metadata?[HKMetadataKeyWeatherTemperature].map({ value in
                                    let val = value as! HKQuantity
                                    return Int(val.doubleValue(for: .degreeCelsius()))
                                })
                                
                                self.healthRuns.append(healthRun(distance: sum, date: w.startDate, duration: w.duration, temp: temp))
                                if w == workouts?.last || count > 20
                                {
                                    
                                    self.healthRuns.sort { $0.date > $1.date }
                                    DispatchQueue.main.async {
                                        self.healthRunsTableView.isHidden = false
                                        self.noRunsLabel.isHidden = true
                                        self.healthRunsTableView.reloadData()
                                    }
                                }
                                
                                
                            }
                            healthStore.execute(distanceQuery)
                        }
                        if healthRuns.isEmpty
                        {
                            print("NO RUNS")
                            noRunsFound()
                        }
                        print(healthRuns)
                    }
                }
            }
        }
    }
    
    func getDistance(store: HKHealthStore, uuid: UUID)
    {
        print(uuid)
        
        guard let runningType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else { fatalError("*** Unable to create a distance type ***")}
        let workoutPredicate = HKQuery.predicateForObject(with: uuid)
        
       // let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
        let query = HKSampleQuery(sampleType: runningType, predicate: workoutPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
            
            guard let distanceSamples = samples as? [HKQuantitySample] else {return}
            let val = distanceSamples.map { $0.quantity.doubleValue(for: HKUnit.meter()) }
            print("AAF")
            print(val)
           // print(distanceSamples.first)
        }
        HKHealthStore().execute(query)
    }
    
    func readWorkouts(store: HKHealthStore) async -> [HKWorkout]? {
        let running = HKQuery.predicateForWorkouts(with: .running)
        let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            store.execute(HKSampleQuery(sampleType: .workoutType(), predicate: running, limit: HKObjectQueryNoLimit,sortDescriptors: [.init(keyPath: \HKSample.startDate, ascending: false)], resultsHandler: { query, samples, error in
                if let hasError = error {
                    continuation.resume(throwing: hasError)
                    return
                }

                guard let samples = samples else {
                    fatalError("*** Invalid State: This can only fail if there was an error. ***")
                }

                continuation.resume(returning: samples)
            }))
        }
        guard let workouts = samples as? [HKWorkout] else {
            return nil
        }
        return workouts
    }
    
    func requestUserPermission(store: HKHealthStore)
    {
        let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        
        //let types = Set([HKSeriesType.workoutType(), HKSeriesType.workoutRoute(), distance]) //this is for when i start using run location
        let types = Set([HKSeriesType.workoutType(), distance])
        store.requestAuthorization(toShare: Set(), read: types) { success, error in //gives access to workout and workoutRoute
            if !success {
                if error != nil {
                    print(error?.localizedDescription)
                }
            }
            else
            {
                return
            }
        }
    }
    
    func noRunsFound()
    {
        healthRunsTableView.isHidden = true
        noRunsLabel.isHidden = false
        
    }
    
//    func backgroundDelivery(store: HKHealthStore)
//    {
//        store.enableBackgroundDelivery(for: HKObjectType.workoutType(), frequency: .immediate) { success, error in
//            guard error != nil && success else {return}
//            let query = HKObserverQuery(sampleType: HKObjectType.workoutType(), predicate: HKQuery.predicateForWorkouts(with: .running)) { query, completionHandler, error in
//                defer {
//                    completionHandler()
//                }
//                guard error != nil else {return}
//
//            }
//            store.execute(query)
//        }
//    }
        
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "importToAddRun"
        {
            let destinationVC = segue.destination as! AddRunInfoVC
            destinationVC.imported = true
            destinationVC.importRun = healthRuns[sender as? Int ?? 0]
        }
    }
}

extension ImportRunVC: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me!")
        performSegue(withIdentifier: "importToAddRun", sender: indexPath.row)
    }
}

extension ImportRunVC: UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return healthRuns.count //TODO: get sharing people count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = healthRunsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! shoeCell
        let run = healthRuns[indexPath.row]
        let date = run.date
        let dateString = date.formatted(date: .abbreviated, time: .omitted)
        print(dateString)
        cell.nameLabel.text = dateString
        var distance = run.distance
        if distanceUnits == "mi"
        {
            distance = unitConversions.kmToMiles(km: distance)
        }
        distance = round(distance * 100) / 100
        if distance == 0.0
        {
            cell.distanceLabel.text = ""
        }
        else
        {
            cell.distanceLabel.text = "\(distance)\(distanceUnits)"
        }
        
        
        return cell
    }
    
}
