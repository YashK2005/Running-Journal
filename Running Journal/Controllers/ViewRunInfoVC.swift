//
//  ViewController.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-09-12.
//

import UIKit
import CoreData

class ViewRunInfoVC: UIViewController {
    
    let userDefaults = UserDefaults.standard
    var distanceUnits = "km"
    var temperatureUnits = "°C"
    
    var run: NSManagedObject = NSManagedObject()
 //   var dictKeys = ["distance", "lastMeal", "location", "privateNotes", "publicNotes", "runIntensity", "runTimeSeconds", "runType", "secondsPerKm", "shoe", "sorenessAfter", "sorenessBefore", "sorenessDuring", "temperature", "weather"] //TODO: reorder
    var dictKeys = ["distance", "runTimeSeconds", "secondsPerKm", "runType", "runIntensity", "location", "temperature", "weather", "shoe", "lastMeal", "sorenessBefore", "sorenessDuring", "sorenessAfter", "publicNotes", "privateNotes"]
    var validKeys : [String] = []
    var validValues : [Any] = []

    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var runInfoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        distanceUnits = userDefaults.string(forKey: K.userDefaults.distance) ?? "km"
        temperatureUnits = userDefaults.string(forKey: K.userDefaults.temperature) ?? "°C"
        
        runInfoTableView.delegate = self
        runInfoTableView.dataSource = self
        
        
        let date: Date = run.value(forKeyPath: "runDate") as! Date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, y - h:mm a"
        dateTimeLabel.text = "\(formatter.string(from: date))"
        
        setupTableViewArrays()
        runInfoTableView.estimatedRowHeight = 100
        runInfoTableView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "viewRunInfoToAddRun", sender: sender)
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        
        let refreshAlert = UIAlertController(title: "Are You Sure?", message: "All data will be lost.", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Delete Run", style: .destructive, handler: { (action: UIAlertAction!) in
            guard let appDelegate =
               UIApplication.shared.delegate as? AppDelegate else {
                 return
             }
             let managedContext =
               appDelegate.persistentContainer.viewContext
           // print(run.isDeleted)
            managedContext.delete(self.run)
            
           // print(run.isDeleted)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
             
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
           //   print("Handle Cancel Logic here")
        }))

        self.present(refreshAlert, animated: true, completion: nil) 
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewRunInfoToAddRun" //after editing button clicked
        {
            let destinationVC = segue.destination as! AddRunInfoVC
            destinationVC.edit = true
            
            var passedDictKeys = dictKeys
            passedDictKeys.append("runDate")
            destinationVC.dict = run.dictionaryWithValues(forKeys: passedDictKeys)
            destinationVC.coreDataRun = run
            print(destinationVC.dict)
        }
    }
    
    func setupTableViewArrays()
    {
        var dict = run.dictionaryWithValues(forKeys: dictKeys)
        for dictKey in dictKeys
        {
            if type(of: dict[dictKey]!) != type(of: NSNull())
            {
                let result = getArrayText(key: dictKey, value: "\(dict[dictKey]!)")
                print(result)
                if result[0] == "Run Time" && result[1] == "00:00"
                {
                    
                }
                else if result[0] == "Pace" && !(validKeys.contains("Run Time"))
                {
                    
                }
                else
                {
                    validKeys.append(result[0])
                    validValues.append(result[1])
                }
            }
        }
    }
    
    func getArrayText(key: String, value: String) -> [String]
    {
        switch key {
            case "distance": //TODO: unit conversion
                var distance = Double(value) ?? 0
                if distanceUnits == "mi"
                {
                    distance = unitConversions.kmToMiles(km: distance)
                }
                distance = round(distance * 100) / 100
                return ["Distance", "\(distance)\(distanceUnits)"]
            case "runTimeSeconds":
                let totalSeconds = Int(value) ?? 0
                let hours = totalSeconds / 3600
                let minutes = String(format: "%02d", ((totalSeconds % 3600) / 60))
                let seconds = String(format: "%02d", (totalSeconds % 3600) % 60)
                
                if hours > 0 {return ["Run Time", "\(hours):\(minutes):\(seconds)"]}
                else {return ["Run Time", "\(minutes):\(seconds)"]}
            
            case "secondsPerKm":
                var totalSeconds = Int(value) ?? 0
                if distanceUnits == "mi"
                {
                    totalSeconds = Int(unitConversions.milesTokm(miles: Double(totalSeconds)))
                }
                let minutes = totalSeconds / 60
                let seconds = totalSeconds % 60
                let paceString = "\(minutes):\(String(format:"%02d", seconds))"
                return["Pace", "\(paceString)/\(distanceUnits)"]
            case "runType":
                return ["Run Type", value]
            case "runIntensity":
                return ["Run Intensity", "\(value)/10"]
            case "location":
                return ["Location", value]
            case "temperature": //TODO: unit conversion
                if temperatureUnits == "°C"
                {
                    return ["Temperature", "\(value)°C"]
                }
                else
                {
                    return ["Temperature", "\(unitConversions.celToFahr(celcius: Int(value) ?? 0))°F"]
                }
                
            case "weather":
                return ["Weather", value]
            case "shoe":
                return ["Shoe Used", value]
            case "lastMeal":
                return ["Most Recent Meal", value]
            case "sorenessBefore":
                return ["Soreness Before Run", value]
            case "sorenessDuring":
                return ["Soreness During Run", value]
            case "sorenessAfter":
                return ["Soreness After Run", value]
            case "publicNotes":
                return ["Public Notes", value]
            case "privateNotes":
                return ["Private Notes", value]
            default:
                print("ERROR")
                return ["ERROR", key]
        }
    }
}

extension ViewRunInfoVC: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me!")
    }
}

extension ViewRunInfoVC: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return validKeys.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = runInfoTableView.dequeueReusableCell(withIdentifier: "runInfoCell", for: indexPath) as! runInfoCell
        cell.titleLabel.text = validKeys[indexPath.row]
        cell.dataLabel.text =  "\(validValues[indexPath.row])"
        cell.dataLabel.numberOfLines = 0
        return cell
    }
}

