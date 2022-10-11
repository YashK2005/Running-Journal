//
//  PastRunsVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-08-18.
//

import UIKit
import CoreData

class PastRunsVC: UIViewController {

    let userDefaults = UserDefaults.standard
    var distanceUnits = "km"
    var temperatureUnits = "°C"
    var runs: [NSManagedObject] = []
    
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var runsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
        menuSetup()
       // print("past runs")
        
        runsTableView.delegate = self
        runsTableView.dataSource = self
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sortButton.setTitle("Sort By: Date", for: .normal)
        
        //getting user's preferred units for distance and temperature
        let unitPreferences = getUserUnits()
        print(unitPreferences)
        distanceUnits = unitPreferences[0]
        temperatureUnits = unitPreferences[1]
        
        getCoreDataRuns(descriptors: [NSSortDescriptor(key: "runDate", ascending: false)])
    }
    
    func getUserUnits() -> [String]
    {
        let distanceKey = K.userDefaults.distance
        let temperatureKey = K.userDefaults.temperature
        
        let distanceUnits = userDefaults.string(forKey: distanceKey)
        if distanceUnits == nil
        {
            userDefaults.set("km", forKey: distanceKey)
        }
        
        let temperatureUnits = userDefaults.string(forKey: temperatureKey)
        if temperatureUnits == nil
        {
            userDefaults.set("°C", forKey: temperatureKey)
        }
        
        return [userDefaults.string(forKey: distanceKey) ?? "km", userDefaults.string(forKey: temperatureKey) ?? "°C"]
    }
    
    func getCoreDataRuns(descriptors: [NSSortDescriptor], predicate: NSPredicate = NSPredicate(value: true))
    {
        guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
             return
         }
         
         let managedContext =
           appDelegate.persistentContainer.viewContext
         
         //2
         let fetchRequest =
           NSFetchRequest<NSManagedObject>(entityName: "UserRun")
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = descriptors
         
         //3
         do {
           runs = try managedContext.fetch(fetchRequest)
         } catch let error as NSError {
           print("Could not fetch. \(error), \(error.userInfo)")
         }
        runsTableView.reloadData()
    }
    
    //MARK: - Sort Menu
    
    func menuSetup() {
//
        let tagsSubMenuOptions = [UICommand(title: "Race", action: #selector(tagRaceSort)),
                                  UICommand(title: "Time Trial", action: #selector(tagTimeTrialSort)),
                                  UICommand(title: "Easy Run", action: #selector(tagEasySort)),
                                  UICommand(title: "Long Run", action: #selector(tagLongSort)),
                                  UICommand(title: "Track Run", action: #selector(tagTrackSort)),
                                  UICommand(title: "Trail Run", action: #selector(tagTrailSort)),
                                  UICommand(title: "Cross-Country Run", action: #selector(tagCrossCountrySort)),
                                  UICommand(title: "Interval Training", action: #selector(tagIntervalSort)),
                                  UICommand(title: "Road Run", action: #selector(tagRoadSort)),
                                  UICommand(title: "Hill Workout", action: #selector(tagHillSort)),
                                  UICommand(title: "Tempo Run", action: #selector(tagTempoSort)),
                                  UICommand(title: "Recovery Run", action: #selector(tagRecoverySort)),
                                  UICommand(title: "Fartlek", action: #selector(tagFartlekSort)),
                                  
        ]
        
        let tagsSubMenu = UIMenu(title: "Run Type", children: tagsSubMenuOptions)
        
        
        
        let date = UICommand(title: "Date", action: #selector(dateSort))
        
        let distance = UICommand(title: "Distance", action: #selector(distanceSort))
        let pace = UICommand(title: "Pace", action: #selector(paceSort))
        
        let menu = UIMenu(children: [date, distance, pace, tagsSubMenu])
        
      
        
        //handler to intercept event related to UIActions.
        
        
        sortButton.menu = menu
        
        
    }
    
    @objc func dateSort() {
       // print("date")
        sortButton.setTitle("Sort By: Date", for: .normal)
        getCoreDataRuns(descriptors: [NSSortDescriptor(key: "runDate", ascending: false)])
    }
    @objc func distanceSort() {
       // print("distance")
        sortButton.setTitle("Sort By: Distance", for: .normal)
        getCoreDataRuns(descriptors: [NSSortDescriptor(key: "distance", ascending: false), NSSortDescriptor(key: "runDate", ascending: false)])
    }
    @objc func paceSort() {
        sortButton.setTitle("Sort By: Pace", for: .normal)
        getCoreDataRuns(descriptors: [NSSortDescriptor(key: "secondsPerKm", ascending: true), NSSortDescriptor(key: "runDate", ascending: false)], predicate: NSPredicate(format: "secondsPerKm != nil")) //TODO: add zero values at the very end instead of front
    }
    
    
    @objc func tagRaceSort() {
        tagSorter("Race")
    }
    @objc func tagTimeTrialSort() {
        tagSorter("Time Trial")
    }
    @objc func tagEasySort() {
        tagSorter("Easy Run")
    }
    @objc func tagLongSort() {
        tagSorter("Long Run")
    }
    @objc func tagTrackSort() {
        tagSorter("Track Run")
    }
    
    
    @objc func tagTrailSort() {
        tagSorter("Trail Run")
    }
    @objc func tagCrossCountrySort() {
        tagSorter("Cross-Country Run")
    }
    @objc func tagIntervalSort() {
        tagSorter("Interval Training")
    }
    @objc func tagRoadSort() {
        tagSorter("Road Run")
    }
    @objc func tagHillSort() {
        tagSorter("Hill Training")
    }
    @objc func tagTempoSort() {
        tagSorter("Tempo Run")
    }
    @objc func tagRecoverySort() {
        tagSorter("Recovery Run")
    }
    @objc func tagFartlekSort() {
        tagSorter("Fartlek Run")
    }
    
    
    func tagSorter(_ tagName: String) {
       // print(tagName)
        sortButton.setTitle("Sort By: Run Type (\(tagName))", for: .normal)
        getCoreDataRuns(descriptors: [NSSortDescriptor(key: "runDate", ascending: false)], predicate: NSPredicate(format: "runType = %@", tagName))
    }

    
    
    //MARK: - Add Run
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue)
    {
        
    }
    /*
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pastRunsToViewRun" //going to ViewRunInfoVC
        {
            let segueRun = runs[runsTableView.indexPathForSelectedRow!.row]
            let destinationVC = segue.destination as? ViewRunInfoVC
            destinationVC?.run = segueRun
            
            
        }
    }

}


extension PastRunsVC: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me!")
        performSegue(withIdentifier: "pastRunsToViewRun", sender: self)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69
    }
}

extension PastRunsVC: UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runs.count //TODO: get run count instead
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let run = runs[indexPath.row]
        let cell = runsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! runCell
        
        //getting coredata values to display on run cell
        let distance: Double = (run.value(forKeyPath: "distance"))! as! Double
        let date: Date = run.value(forKeyPath: "runDate") as! Date
        let runTime: Int = (run.value(forKeyPath: "runTimeSeconds") ?? 0) as! Int
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, y"
        var pace: Int = ((run.value(forKeyPath: "secondsPerKm") ?? 0) as! Int)
        let runType: String = ((run.value(forKeyPath: "runType") ?? "") as! String)
        
        
        
      //  print(date)
        
      //  print(distance)
       // cell.textLabel?.text = "\(distance)"// runs[indexPath.row]
        if distanceUnits == "km"
        {
            cell.distanceLabel.text = "\(distance)km"
        }
        else
        {
            cell.distanceLabel.text = "\(round(unitConversions.kmToMiles(km: distance)*100)/100.0)mi"
        }
        
        if runType != ""
        {
            cell.dateLabel.text = "\(formatter.string(from: date)): \(runType)"
        } else {
            cell.dateLabel.text = "\(formatter.string(from: date))"
        }
       
        if runTime != 0
        {
            if distanceUnits == "mi"
            {
                pace = Int(unitConversions.milesTokm(miles: Double(pace)))
            }
            var paceMinutes = pace / 60
            var paceSeconds = pace % 60
            cell.paceLabel.text = "\(paceMinutes):\(String(format:"%02d", paceSeconds))/\(distanceUnits)" //TODO: units
        } else {
            cell.paceLabel.text = ""
        }
        return cell
    }
}
