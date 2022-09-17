//
//  Pt3AddRunInfoVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-08-30.
//

import UIKit
import CoreData

class Pt3AddRunInfoVC: UIViewController {

    var edit : Bool = false //false if run is being added, true if run is being edited
//    var keys : [String] = [] //already entered fields
//    var values : [Any] = [] //already entered values
    var dict = [String : Any]()
    var dictKeys = ["distance", "runTimeSeconds", "secondsPerKm", "runType", "runIntensity", "location", "temperature", "weather", "shoe", "lastMeal", "sorenessBefore", "sorenessDuring", "sorenessAfter", "publicNotes", "privateNotes", "runDate"]
    var coreDataRun: NSManagedObject = NSManagedObject()
    
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var publicTextField: UITextView!
    @IBOutlet weak var privateTextField: UITextView!
    
    var run : [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(run)
        
        self.hideKeyboardWhenTappedAround()
        
        intensitySlider.isContinuous = false
        
        //for text view border
        for textview in [publicTextField, privateTextField] {
            textview?.layer.borderColor = UIColor.lightGray.cgColor
            textview?.layer.borderWidth = 1
        }
        
        if edit == true {
            editingSetup()
            shareButton.titleLabel?.text = "Save"
            
        }
        
        
        

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        if edit == false {addRunHelp.backButton(self: self, back: true)}
        else {addRunHelp.editingBackButton(self: self, back: true)}
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        sender.setValue(sender.value.rounded(.toNearestOrEven), animated: true)
        print(sender.value)
    }
   
    @IBAction func shareButtonClicked(_ sender: UIButton) {
        if edit == false //run being added
        {
            let refreshAlert = UIAlertController(title: "Adding Run", message: "Run will be added to log and shared with friends", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
               //   TODO: add run to database
                self.addRunDict()
                self.addRunDatabase()
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }))

            self.present(refreshAlert, animated: true, completion: nil)
        }
        else //run being edited
        {
            let refreshAlert = UIAlertController(title: "Update Run", message: "Run changes will be made and shared with friends", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
               //   TODO: add run to database
                self.addRunDict()
                self.editRunDatabase()
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }))

            self.present(refreshAlert, animated: true, completion: nil)
            shareButton.titleLabel?.text = "Save"
        }
        
    }
    
    //adding to run dictionary
    func addRunDict()
    {
        run["intensity"] = Int(intensitySlider.value)
        
        if (publicTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) != ""
        {
            run["public"] = publicTextField.text
        }
        if (privateTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) != ""
        {
            run["private"] = privateTextField.text
        }
        
        print(run)
    }
    
    func addRunDatabase()
    {
        
        //setting up for database additions
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
          }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
          
          // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "UserRun",
                                       in: managedContext)!
        let userRun = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
        
        
        //adding info
        userRun.setValue(round(run["distance"] as! Double * 100) / 100.0, forKey: "distance")
        userRun.setValue(run["diet"], forKey: "lastMeal")
        userRun.setValue(run["location"], forKey: "location")
        userRun.setValue(run["private"], forKey: "privateNotes")
        userRun.setValue(run["public"], forKey: "publicNotes")
        userRun.setValue(run["date"], forKey: "runDate")
        userRun.setValue(run["intensity"], forKey: "runIntensity")
        userRun.setValue(run["runTimeSeconds"], forKey: "runTimeSeconds")
        userRun.setValue(run["type"], forKey: "runType")
        userRun.setValue(run["shoe"], forKey: "shoe")
        userRun.setValue(run["sorenessAfter"], forKey: "sorenessAfter")
        userRun.setValue(run["sorenessBefore"], forKey: "sorenessBefore")
        userRun.setValue(run["sorenessDuring"], forKey: "sorenessDuring")
        userRun.setValue(run["temperature"], forKey: "temperature")
        userRun.setValue(run["weather"], forKey: "weather")
        userRun.setValue(run["pace"], forKey: "secondsPerKm")
        
        //saving to database
        
            
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        //for testing - can delete later
        
//        let fetchRequest =
//            NSFetchRequest<NSManagedObject>(entityName: "UserRun")
//        do {
//            let databaseRuns = try managedContext.fetch(fetchRequest)
//            print(databaseRuns)
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
        
        
    }
    
    func editRunDatabase()
    {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
          }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        coreDataRun.setValue(round(run["distance"] as! Double * 100) / 100.0, forKey: "distance")
        coreDataRun.setValue(run["diet"], forKey: "lastMeal")
        coreDataRun.setValue(run["location"], forKey: "location")
        coreDataRun.setValue(run["private"], forKey: "privateNotes")
        coreDataRun.setValue(run["public"], forKey: "publicNotes")
        coreDataRun.setValue(run["date"], forKey: "runDate")
        coreDataRun.setValue(run["intensity"], forKey: "runIntensity")
        coreDataRun.setValue(run["runTimeSeconds"], forKey: "runTimeSeconds")
        coreDataRun.setValue(run["type"], forKey: "runType")
        coreDataRun.setValue(run["shoe"], forKey: "shoe")
        coreDataRun.setValue(run["sorenessAfter"], forKey: "sorenessAfter")
        coreDataRun.setValue(run["sorenessBefore"], forKey: "sorenessBefore")
        coreDataRun.setValue(run["sorenessDuring"], forKey: "sorenessDuring")
        coreDataRun.setValue(run["temperature"], forKey: "temperature")
        coreDataRun.setValue(run["weather"], forKey: "weather")
        coreDataRun.setValue(run["pace"], forKey: "secondsPerKm")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
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
                        
                 //   case "runType":
                    
                        
                    case "runIntensity":
                    intensitySlider.setValue(Float("\(dictValue)") ?? 5.0, animated: false)
                    sliderChanged(intensitySlider)
                        
                  //  case "location":
                    
                  //  case "temperature": //TODO: unit conversion
                    
                        
                  //  case "weather":
                    
                        
                    //case "shoe":
                    
                        
                    //case "lastMeal":
                    
                        
                    //case "sorenessBefore":
                    
                        
                    //case "sorenessDuring":
                    
                        
                    //case "sorenessAfter":
                    
                        
                    case "publicNotes":
                    publicTextField.text = "\(dictValue)"
                        
                    case "privateNotes":
                    privateTextField.text = "\(dictValue)"
                        
                    default:
                        let useless = 0
                }
            }
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

extension Pt3AddRunInfoVC {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddRunInfoVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
