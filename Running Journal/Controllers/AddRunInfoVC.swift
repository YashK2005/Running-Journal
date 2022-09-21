//
//  AddRunInfoVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-08-22.
//

import UIKit
import CoreData


class AddRunInfoVC: UIViewController, UITextFieldDelegate {
    
    let userDefaults = UserDefaults.standard
    var distanceUnits = "km"
    var temperatureUnits = "°C"
    
    var run = [String: Any]()
    
    
    var edit : Bool = false //false if run is being added, true if run is being edited
//    var keys : [String] = [] //already entered fields
//    var values : [Any] = [] //already entered values
    var dict = [String : Any]()
    var dictKeys = ["distance", "runTimeSeconds", "secondsPerKm", "runType", "runIntensity", "location", "temperature", "weather", "shoe", "lastMeal", "sorenessBefore", "sorenessDuring", "sorenessAfter", "publicNotes", "privateNotes", "runDate"]
    var coreDataRun: NSManagedObject = NSManagedObject()
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var unitSelector: UISegmentedControl!
    @IBOutlet weak var runTimePicker: UIPickerView!
    //for runTimePicker
    var hour:Int = 0
    var minutes:Int = 0
    var seconds:Int = 0
    
    @IBOutlet weak var paceLabel: UILabel!
    // @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextView!
    @IBOutlet weak var temperatureTextField: UITextField!
    @IBOutlet weak var tempSelector: UISegmentedControl!
    @IBOutlet weak var weatherTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        distanceUnits = userDefaults.string(forKey: K.userDefaults.distance) ?? "km"
        temperatureUnits = userDefaults.string(forKey: K.userDefaults.temperature) ?? "°C"
        if distanceUnits == "km"
        {
            unitSelector.selectedSegmentIndex = 0
        }
        else
        {
            unitSelector.selectedSegmentIndex = 1
        }
        if temperatureUnits == "°C"
        {
            tempSelector.selectedSegmentIndex = 0
        }
        else
        {
            tempSelector.selectedSegmentIndex = 1
        }
        
        if edit == false {self.distanceTextField.becomeFirstResponder()}
        
        
        // Do any additional setup after loading the view.
        self.distanceTextField.delegate = self
        self.runTimePicker.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        datePicker.maximumDate = Date()
        
        
        distanceTextField.addTarget(self, action: #selector(AddRunInfoVC.distanceTextFieldDidChange(_:)), for: .editingChanged)
        unitSelector.addTarget(self, action: #selector(AddRunInfoVC.unitsChanged(_:)), for:.allEvents)
        
        temperatureTextField.addNumericAccessory(addPlusMinus: true)
        
        //for text view border
        for textView in [weatherTextView, locationTextField, temperatureTextField]
        {
            textView?.layer.borderColor = UIColor.lightGray.cgColor
            textView?.layer.borderWidth = 1
        }
        
        if edit == true {
            editingSetup()
        }
        
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        run.removeAll() //in case user goes back an then clear a field
    }
    //Back button clicked
    @IBAction func backButtonClicked(_ sender: UIButton) {
        if edit == false {addRunHelp.backButton(self: self, back: false)}
        else {addRunHelp.editingBackButton(self: self, back: false)}
        
    }
    
    //Textfield delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { // return NO to not change text
        
        switch string {
        case "0","1","2","3","4","5","6","7","8","9":
            return true
        case ".":
            let array = Array(textField.text!)
            var decimalCount = 0
            for character in array {
                if character == "." {
                    decimalCount+=1
                    
                }
            }
            
            if decimalCount == 1 {
                return false
            } else {
                return true
            }
        default:
            let array = Array(string)
            if array.count == 0 {
                return true
            }
            return false
        }
    }
    
    //when distance is updated, pace is recalculated
    @objc func distanceTextFieldDidChange(_ textField: UITextField) {
        updatePace()
    }
    
    @objc func unitsChanged(_ segment: UISegmentedControl) {
        updatePace()
    }
    
    //calculates pace and updates pace label
    func updatePace() {
        //calculating pace
        if distanceTextField.hasText
        {
            let totalMinutes:Double = Double(hour)*60 + Double(minutes) + Double(seconds)/60
            var pace:Double = (totalMinutes / (Double(distanceTextField.text!) ?? 0) ?? 0)
            
            if (pace == Double.infinity) || pace.isNaN
            {
                pace = 0
            }
            
            var paceMinutes = Int(pace)
            var paceSeconds = String(format:"%02d", (Int(round(pace.truncatingRemainder(dividingBy: 1) * 60))))
            if paceSeconds == "60"
            {
                paceMinutes += 1
                paceSeconds = "00"
            }
            let paceText = ("\(paceMinutes):\(paceSeconds)")
            
            paceLabel.text = "Pace: \(paceText)/\(unitSelector.titleForSegment(at: unitSelector.selectedSegmentIndex) ?? "km")"
        }
    }
    
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        //check if distance field has been entered
        let distanceRan = Double(distanceTextField.text ?? "0")
        let distance = distanceRan ?? 0.0
        //  print(distance)
        if distance != 0 //perform segue
        {
            performSegue(withIdentifier: "addRunPage1-2", sender: sender)
        }
        else //remind user to input distance through pop up
        {
            let refreshAlert = UIAlertController(title: "Error", message: "Enter distance before proceeding", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                
                self.distanceTextField.becomeFirstResponder()
                //   print("Handle Cancel Logic here")
            }))
            present(refreshAlert, animated: true, completion: nil)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addRunPage1-2"
        {
            run["date"] = datePicker.date
            
            //distance stored in databse will always be in km (metric)
            let labeldistance = Double(distanceTextField.text!)!
            if unitSelector.titleForSegment(at: unitSelector.selectedSegmentIndex) == "mi"
            {
                run["distance"] = labeldistance * 1.60934
            }
            else
            {
                run["distance"] = labeldistance
            }
            let runTimeSeconds = Int(Double(hour)*3600 + Double(minutes)*60 + Double(seconds))
            
            if runTimeSeconds != 0
            {
                run["runTimeSeconds"] = runTimeSeconds
                let pace = (Double(runTimeSeconds) / (run["distance"] as! Double))
                
                print(pace)
                run["pace"] = Int(round(pace))
                print(run["pace"])
                //run["pace"] = paceLabel.text
            }
            
            if (locationTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) != ""
            {
                run["location"] = locationTextField.text
            }
            //temperature stored in database always in celcius (metric)
            if (temperatureTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) != "" && temperatureTextField.text != "-"
            {
                var temp = Int(temperatureTextField.text!)!
                
                if tempSelector.titleForSegment(at: tempSelector.selectedSegmentIndex) == "°F"
                {
                    
                    temp = temp - 32
                    temp = temp * 5 / 9
                }
                run["temperature"] = temp
                
            }
            if (weatherTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) != ""
            {
                run["weather"] = weatherTextView.text
            }
            print(run)
            
            let destinationVC = segue.destination as! Pt2AddRunInfoVC
            destinationVC.run = run
            
            if edit == true
            {
                destinationVC.edit = true
                destinationVC.coreDataRun = coreDataRun
                destinationVC.dict = dict
            }
        }
    }
    
    func editingSetup() {
        print("edit")
        
        for dictKey in dictKeys
        {
            if type(of: dict[dictKey]!) != type(of: NSNull())
            {
                let dictValue = (dict[dictKey]!)
                switch dictKey {
                    case "runDate":
                    print(dictValue)
                    datePicker.date = dictValue as! Date
                    
                    case "distance": //TODO: unit conversion
                        let distance = (dictValue) as! Double
                        if distanceUnits == "km"
                        {
                            distanceTextField.text = "\(distance)"
                        }
                        else
                        {
                            distanceTextField.text = "\(unitConversions.kmToMiles(km: distance))"
                        }
                        
                        print(dictValue)
                    case "runTimeSeconds":
                    let totalSeconds = Int("\(dictValue)") ?? 0
                    hour = totalSeconds / 3600
                    minutes = (totalSeconds % 3600) / 60
                    seconds = (totalSeconds % 3600) % 60
                    runTimePicker.selectRow(hour, inComponent: 0, animated: false)
                    runTimePicker.selectRow(minutes, inComponent: 1, animated: false)
                    runTimePicker.selectRow(seconds, inComponent: 2, animated: false)
                    updatePace()
                    
                //    case "secondsPerKm":
                        
                  //  case "runType":
                        
                  //  case "runIntensity":
                        
                    case "location":
                    locationTextField.text = "\(dictValue)"
                        
                    case "temperature": //TODO: unit conversion
                    if temperatureUnits == "°C"
                    {
                        temperatureTextField.text = "\(dictValue)"
                    }
                    else
                    {
                        temperatureTextField.text = "\(unitConversions.celToFahr(celcius: dictValue as! Int))"
                    }
                    
                        
                    case "weather":
                    weatherTextView.text = "\(dictValue)"
                        
                  //  case "shoe":
                        
                 //   case "lastMeal":
                        
                  //  case "sorenessBefore":
                        
                  //  case "sorenessDuring":
                        
                  //  case "sorenessAfter":
                        
                  //  case "publicNotes":
                        
                  //  case "privateNotes":
                        
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

//MARK: - runTimePicker Delegate Methods
extension AddRunInfoVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 25
        case 1, 2:
            return 60
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width/3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row) Hr"
        case 1:
            return "\(row) Min"
        case 2:
            return "\(row) Sec"
        default:
            return ""
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        switch component {
        case 0:
            hour = row
        case 1:
            minutes = row
        case 2:
            seconds = row
        default:
            break;
        }
        updatePace()
    }
}

// Automatically dismisses keyboard
extension AddRunInfoVC {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddRunInfoVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension UITextField {
    
    func addNumericAccessory(addPlusMinus: Bool) {
        let numberToolbar = UIToolbar()
        numberToolbar.barStyle = UIBarStyle.default
        
        var accessories : [UIBarButtonItem] = []
        
        
        if addPlusMinus {
            accessories.append(UIBarButtonItem(title: "+/-", style: UIBarButtonItem.Style.plain, target: self, action: #selector(plusMinusPressed)))
            accessories.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))   //add padding after
        }
        
        // accessories.append(UIBarButtonItem(title: "Clear", style: UIBarButtonItem.Style.plain, target: self, action: #selector(numberPadClear)))
        accessories.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))   //add padding space
        accessories.append(UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(numberPadDone)))
        
        numberToolbar.items = accessories
        numberToolbar.sizeToFit()
        
        inputAccessoryView = numberToolbar
    }
    
    @objc func numberPadDone() {
        self.resignFirstResponder()
    }
    
    @objc func numberPadClear() {
        self.text = ""
    }
    
    @objc func plusMinusPressed() {
        guard let currentText = self.text else {
            return
        }
        if currentText.hasPrefix("-") {
            let offsetIndex = currentText.index(currentText.startIndex, offsetBy: 1)
            let substring = currentText[offsetIndex...]  //remove first character
            self.text = String(substring)
        }
        else {
            self.text = "-" + currentText
        }
    }
    
}


