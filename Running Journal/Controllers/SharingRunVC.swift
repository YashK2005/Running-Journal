//
//  SharingRunVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-10-20.
//

import UIKit
import CloudKit

class SharingRunVC: UIViewController {
    
    let userDefaults = UserDefaults.standard
    var distanceUnits = "km"
    var temperatureUnits = "°C"
    
    var runArray : [CKRecord] = []
    var ownerName : String = ""
 //   var dictKeys = ["distance", "lastMeal", "location", "privateNotes", "publicNotes", "runIntensity", "runTimeSeconds", "runType", "secondsPerKm", "shoe", "sorenessAfter", "sorenessBefore", "sorenessDuring", "temperature", "weather"] //TODO: reorder
    var dictKeys = ["CD_distance", "CD_runTimeSeconds", "CD_secondsPerKm", "CD_runType", "CD_runIntensity", "CD_location", "CD_temperature", "CD_weather", "CD_shoe", "CD_lastMeal", "CD_sorenessBefore", "CD_sorenessDuring", "CD_sorenessAfter", "CD_publicNotes"]
    var validKeys : [String] = []
    var validValues : [Any] = []
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var runsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        distanceUnits = userDefaults.string(forKey: K.userDefaults.distance) ?? "km"
        temperatureUnits = userDefaults.string(forKey: K.userDefaults.temperature) ?? "°C"
        
        runsTableView.delegate = self
        runsTableView.dataSource = self
        fullNameLabel.text = ownerName
        
        let date: Date = runArray[0].value(forKey: "CD_runDate") as! Date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, y - h:mm a"
        dateLabel.text = "\(formatter.string(from: date))"
        
        setupTableViewArrays()
        runsTableView.estimatedRowHeight = 100
        runsTableView.rowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupTableViewArrays()
    {
        var dict = runArray[0].dictionaryWithValues(forKeys: dictKeys)
        for dictKey in dictKeys
        {
            if type(of: dict[dictKey]!) != type(of: NSNull())
            { //var dictKeys = ["distance", "runTimeSeconds", "secondsPerKm", "runType", "runIntensity", "location", "temperature", "weather", "shoe", "lastMeal", "sorenessBefore", "sorenessDuring", "sorenessAfter", "publicNotes", "privateNotes"]
                //validKeys.append(dictKey)
             //   validValues.append(dict[dictKey]!)
                
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
            case "CD_distance": //TODO: unit conversion
                var distance = Double(value) ?? 0
                if distanceUnits == "mi"
                {
                    distance = unitConversions.kmToMiles(km: distance)
                }
                distance = round(distance * 100) / 100
                return ["Distance", "\(distance)\(distanceUnits)"]
            case "CD_runTimeSeconds":
                let totalSeconds = Int(value) ?? 0
                let hours = totalSeconds / 3600
                let minutes = String(format: "%02d", ((totalSeconds % 3600) / 60))
                let seconds = String(format: "%02d", (totalSeconds % 3600) % 60)
                
                if hours > 0 {return ["Run Time", "\(hours):\(minutes):\(seconds)"]}
                else {return ["Run Time", "\(minutes):\(seconds)"]}
            
            case "CD_secondsPerKm":
                var totalSeconds = Int(value) ?? 0
                if distanceUnits == "mi"
                {
                    totalSeconds = Int(unitConversions.milesTokm(miles: Double(totalSeconds)))
                }
                let minutes = totalSeconds / 60
                let seconds = totalSeconds % 60
                let paceString = "\(minutes):\(String(format:"%02d", seconds))"
                return["Pace", "\(paceString)/\(distanceUnits)"]
            case "CD_runType":
                return ["Run Type", value]
            case "CD_runIntensity":
                return ["Run Intensity", "\(value)/10"]
            case "CD_location":
                return ["Location", value]
            case "CD_temperature": //TODO: unit conversion
                if temperatureUnits == "°C"
                {
                    return ["Temperature", "\(value)°C"]
                }
                else
                {
                    return ["Temperature", "\(unitConversions.celToFahr(celcius: Int(value) ?? 0))°F"]
                }
                
            case "CD_weather":
                return ["Weather", value]
            case "CD_shoe":
                return ["Shoe Used", value]
            case "CD_lastMeal":
                return ["Most Recent Meal", value]
            case "CD_sorenessBefore":
                return ["Soreness Before Run", value]
            case "CD_sorenessDuring":
                return ["Soreness During Run", value]
            case "CD_sorenessAfter":
                return ["Soreness After Run", value]
            case "CD_publicNotes":
                return ["Public Notes", value]
            default:
                print("ERROR")
                return ["ERROR", key]
        }
    }
}

extension SharingRunVC: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me!")
    }
}

extension SharingRunVC: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return validKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = runsTableView.dequeueReusableCell(withIdentifier: "runInfoCell", for: indexPath) as! runInfoCell
        cell.titleLabel.text = validKeys[indexPath.row]
        cell.dataLabel.text =  "\(validValues[indexPath.row])"
        cell.dataLabel.numberOfLines = 0
        return cell
    }
}


