//
//  Pt2AddRunInfoVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-08-26.
//

import UIKit
import CoreData


class Pt2AddRunInfoVC: UIViewController {
    
    let userDefaults = UserDefaults.standard
    var distanceUnits = "km"
    
    //variables if editing a previous run
    var edit : Bool = false //false if run is being added, true if run is being edited
//    var keys : [String] = [] //already entered fields
//    var values : [Any] = [] //already entered values
    var dict = [String : Any]()
    var dictKeys = ["distance", "runTimeSeconds", "secondsPerKm", "runType", "runIntensity", "location", "temperature", "weather", "shoe", "lastMeal", "sorenessBefore", "sorenessDuring", "sorenessAfter", "publicNotes", "privateNotes", "runDate"]
    var coreDataRun: NSManagedObject = NSManagedObject()
    
    @IBOutlet weak var runTypeButton: UIButton!
    
    var selectedRunType = ""
    
    
    @IBOutlet weak var shoeUsedButton: UIButton!
    var shoeDict: [String: Double] = ["Asics" : 200, //TODO: get from database
                                   "Nike"  : 150,
                                   "Hoka"  : 12]
    var shoeName = ""
    
    
    
    @IBOutlet weak var dietTextView: UITextView!
   
    
    @IBOutlet weak var sorenessBeforeTextView: UITextView!
    @IBOutlet weak var sorenessDuringTextView: UITextView!
    @IBOutlet weak var sorenessAfterTextView: UITextView!
    
    var run : [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceUnits = userDefaults.string(forKey: K.userDefaults.distance) ?? "km"
        if distanceUnits == "mi"
        {
            for (key, value) in shoeDict
            {
                shoeDict.updateValue(unitConversions.kmToMiles(km: value), forKey: key)
            }
        }
        

        print(run)
        self.hideKeyboardWhenTappedAround()
        
        //creating menus
        runTypeMenuSetup()
        shoeMenuSetup()
        
        
        //for text view border
        for textview in [dietTextView, sorenessBeforeTextView, sorenessDuringTextView, sorenessAfterTextView] {
            textview?.layer.borderColor = UIColor.lightGray.cgColor
            textview?.layer.borderWidth = 1
        }
        
        if edit == true {
            editingSetup()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //TODO: clear fields in run that are related to the info on this screen only (not page 1, only this page)
        //run.removeAll() //in case user goes back an then clear a fields
        for dictKey in ["type", "shoe", "diet", "sorenessBefore", "sorenessDuring", "sorenessAfter"]
        {
            run.removeValue(forKey: dictKey)
        }
       
    }
    
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        if edit == false {addRunHelp.backButton(self: self, back: true)}
        else {addRunHelp.editingBackButton(self: self, back: true)}
        
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) { //TODO: segue to next page
        performSegue(withIdentifier: "addRunPage2-3", sender: sender)
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addRunPage2-3"
        {
            let runType = runTypeButton.currentTitle ?? "Select"
            if runType != "Select"
            {
                run["type"] = runType
            }
            if shoeName != ""
            {
                run["shoe"] = shoeName
            }
            if (dietTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) != ""
            {
                run["diet"] = dietTextView.text
            }
            
            if (sorenessBeforeTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) != ""
            {
                run["sorenessBefore"] = sorenessBeforeTextView.text
            }
            if (sorenessDuringTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) != ""
            {
                run["sorenessDuring"] = sorenessDuringTextView.text
            }
            if (sorenessAfterTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) != ""
            {
                run["sorenessAfter"] = sorenessAfterTextView.text
            }
            //Calculate time before meal
            
         //   print(runTime.timeIntervalSince1970 - mealTime)
            
            
            
            print(run)
            let destinationVC = segue.destination as! Pt3AddRunInfoVC
            destinationVC.run = run
            
            if edit == true
            {
                destinationVC.edit = true
                destinationVC.coreDataRun = coreDataRun
                destinationVC.dict = dict
            }
        }
        
        
    }
    
    func editingSetup()
    {
        for dictKey in dictKeys
        {
            if type(of: dict[dictKey]!) != type(of: NSNull())
            {
                let dictValue = (dict[dictKey]!)
                switch dictKey {
               //     case "runDate":
                    
                 //   case "distance": //TODO: unit conversion
                    
                   // case "runTimeSeconds":
                    
                //    case "secondsPerKm":
                        
                    case "runType":
                    tagSorter("\(dictValue)")
                        
                  //  case "runIntensity":
                        
                  //  case "location":
                    
                  //  case "temperature": //TODO: unit conversion
                    
                        
                  //  case "weather":
                    
                        
                    case "shoe":
                    if shoeDict.keys.contains("\(dictValue)")
                    {
                        shoeName = "\(dictValue)"
                        shoeUsedButton.setTitle("\(dictValue) - \(shoeDict["\(dictValue)"]!)\(distanceUnits)", for: .normal)
                        
                    }
                        
                    case "lastMeal":
                    dietTextView.text = "\(dictValue)"
                        
                    case "sorenessBefore":
                    sorenessBeforeTextView.text = "\(dictValue)"
                        
                    case "sorenessDuring":
                    sorenessDuringTextView.text = "\(dictValue)"
                        
                    case "sorenessAfter":
                    sorenessAfterTextView.text = "\(dictValue)"
                        
                  //  case "publicNotes":
                        
                  //  case "privateNotes":
                        
                    default:
                        let useless = 0
                }
            }
        }
    }
    //MARK: - Run Type Menu Setup
    func runTypeMenuSetup() {
        let menuOptions:[UICommand] = [
           // UICommand(title: "Select", action: #selector(menuFunc), attributes: .disabled),
            UICommand(title: "Race", action: #selector(tagRaceSort)),
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
       // menuOptions.first?.state
        
        
        let runOptionsMenu = UIMenu(children: menuOptions)
        
        runTypeButton.menu = runOptionsMenu
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
        
        runTypeButton.setTitle("\(tagName)", for: .normal)
        selectedRunType = tagName
    }
    
//MARK: - Shoe Menu Setup
    func shoeMenuSetup() { //add functionality for adding a new shoe
        var menuOptions:[UIAction] = []
        for (key, value) in shoeDict {
            menuOptions.append(UIAction(title: "\(key) - \(value)\(distanceUnits)") { [self] (action) in self.shoeUsedButton.setTitle("\(key) - \(value)\(distanceUnits)", for: .normal)
                shoeName = key
            })}
        
        //TODO: add another option for adding a new shoe
        let shoeMenu = UIMenu(children: menuOptions)
        
        shoeUsedButton.menu = shoeMenu
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


extension Pt2AddRunInfoVC {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddRunInfoVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
