//
//  SharingPersonVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-10-18.
//

import UIKit
import CloudKit

class SharingPersonVC: UIViewController {
    
    let userDefaults = UserDefaults.standard
    var distanceUnits = "km"
    var temperatureUnits = "°C"
    var runs : [CKRecord] = []
    var selectedRuns : [CKRecord] = []
    var userFullName : String = ""
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var runsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        distanceUnits = userDefaults.string(forKey: K.userDefaults.distance) ?? "km"
        temperatureUnits = userDefaults.string(forKey: K.userDefaults.temperature) ?? "°C"
        fullNameLabel.text = userFullName
        
        runsTableView.delegate = self
        runsTableView.dataSource = self
        
        menuSetup()
        runSorter(arg: "Upload")
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if runs.count == 0 //exits if the person has no runs
        {
            let alert = UIAlertController(title: "No runs found", message: "\(userFullName) has not uploaded any runs", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                self.dismiss(animated: true)
            }))
            present(alert, animated: true)
        }
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "personToRun"
        {
            let destinationVC = segue.destination as? SharingRunVC
            destinationVC?.runArray = [selectedRuns[sender as? Int ?? 0]]
            destinationVC?.ownerName = userFullName
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SharingPersonVC: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me!")
        performSegue(withIdentifier: "personToRun", sender: indexPath.row)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69
    }
}

extension SharingPersonVC: UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedRuns.count //TODO: get run count instead
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let run = selectedRuns[indexPath.row]
        let cell = runsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! runCell
        
        //getting coredata values to display on run cell
        let distance: Double = (run.value(forKey: "CD_distance"))! as! Double
        let date: Date = run.value(forKey: "CD_runDate") as! Date
        let runTime: Int = (run.value(forKey: "CD_runTimeSeconds") ?? 0) as! Int
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, y"
        var pace: Int = ((run.value(forKey: "CD_secondsPerKm") ?? 0) as! Int)
        let runType: String = ((run.value(forKey: "CD_runType") ?? "") as! String)
        
        
        
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

//MARK: - Sorting
extension SharingPersonVC
{
    func runSorter(arg: String, type: String = "") {
        
        if arg == "Upload"
        {
            selectedRuns = runs.sorted(by: { $0.creationDate ?? Date() > $1.creationDate ?? Date() })
        }
        else if arg == "Date"
        {
            selectedRuns = runs.sorted(by: { $0.value(forKey: "CD_runDate") as! Date > $1.value(forKey: "CD_runDate") as! Date })
        }
        else if arg == "Distance"
        {
            selectedRuns = runs.sorted(by: { $0.value(forKey: "CD_distance") as? Double ?? 0 > $1.value(forKey: "CD_distance") as? Double ?? 0 })
        }
        else if arg == "Pace"
        {
            selectedRuns = runs.sorted(by: {first,second in
                let value1 = first.value(forKey: "CD_secondsPerKm")
                let value2 = second.value(forKey: "CD_secondsPerKm")
                if value1 != nil && value2 == nil
                {
                    return true
                }
                if value1 == nil && value2 != nil
                {
                    return false
                }
                if value1 == nil && value2 == nil
                {
                    return (first.creationDate ?? Date() > second.creationDate ?? Date())
                }
                if value1 != nil && value2 != nil
                {
                    return (value1 as? Int ?? 0 < value2 as? Int ?? 0)
                }
                return true
            })
        }
        else if arg == "Type"
        {
            selectedRuns = runs.filter({ record in
                if record.value(forKey: "CD_runType") as? String ?? "a" == type
                {
                    return true
                }
                else
                {
                    return false
                }
            })
        }
        
        runsTableView.reloadData()
    }
    
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
        
        let upload = UICommand(title: "Upload Date", action: #selector(uploadSort))
        let date = UICommand(title: "Run Date", action: #selector(dateSort))
        let distance = UICommand(title: "Distance", action: #selector(distanceSort))
        let pace = UICommand(title: "Pace", action: #selector(paceSort))
        
        let menu = UIMenu(children: [upload, date, distance, pace, tagsSubMenu])
        sortButton.menu = menu
    }
    
    @objc func uploadSort() {
        sortButton.setTitle("Sort By: Upload Date", for: .normal)
        runSorter(arg: "Upload")
    }
    @objc func dateSort() {
       // print("date")
        sortButton.setTitle("Sort By: Run Date", for: .normal)
        runSorter(arg: "Date")
        //getCoreDataRuns(descriptors: [NSSortDescriptor(key: "runDate", ascending: false)])
    }
    @objc func distanceSort() {
       // print("distance")
        sortButton.setTitle("Sort By: Distance", for: .normal)
        runSorter(arg: "Distance")
       // getCoreDataRuns(descriptors: [NSSortDescriptor(key: "distance", ascending: false), NSSortDescriptor(key: "runDate", ascending: false)])
    }
    @objc func paceSort() {
        sortButton.setTitle("Sort By: Pace", for: .normal)
        runSorter(arg: "Pace")
        //getCoreDataRuns(descriptors: [NSSortDescriptor(key: "secondsPerKm", ascending: true), NSSortDescriptor(key: "runDate", ascending: false)], predicate: NSPredicate(format: "secondsPerKm != nil")) //TODO: add zero values at the very end instead of front
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
        runSorter(arg: "Type", type: tagName)
        //getCoreDataRuns(descriptors: [NSSortDescriptor(key: "runDate", ascending: false)], predicate: NSPredicate(format: "runType = %@", tagName))
    }
}
