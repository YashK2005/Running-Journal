//
//  Pt3AddRunInfoVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-08-30.
//

import UIKit
import CoreData

class Pt3AddRunInfoVC: UIViewController {

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
        
       
        
        
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        addRunHelp.backButton(self: self, back: true)
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        sender.setValue(sender.value.rounded(.toNearestOrEven), animated: true)
        print(sender.value)
    }
   
    @IBAction func shareButtonClicked(_ sender: UIButton) {
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
