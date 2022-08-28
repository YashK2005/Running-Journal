//
//  AddRunInfoVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-08-22.
//

import UIKit

class AddRunInfoVC: UIViewController, UITextFieldDelegate {

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
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var temperatureTextField: UITextField!
    @IBOutlet weak var tempSelector: UISegmentedControl!
    @IBOutlet weak var weatherTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.distanceTextField.delegate = self
        self.runTimePicker.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        datePicker.maximumDate = Date()
        
        
        distanceTextField.addTarget(self, action: #selector(AddRunInfoVC.distanceTextFieldDidChange(_:)), for: .editingChanged)
        unitSelector.addTarget(self, action: #selector(AddRunInfoVC.unitsChanged(_:)), for:.allEvents)
        
        temperatureTextField.addNumericAccessory(addPlusMinus: true)
        
        //for text view border
        weatherTextView.layer.borderColor = UIColor.lightGray.cgColor
        weatherTextView.layer.borderWidth = 1
        
    }
    //Back button clicked
    @IBAction func backButtonClicked(_ sender: UIButton) {
        addRunHelp.backButton(self: self, back: false)
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
        var distanceRan = Double(distanceTextField.text ?? "0")
        var distance = distanceRan ?? 0.0
        print(distance)
        if distance != 0 //perform segue
        {
            performSegue(withIdentifier: "addRunPage1-2", sender: sender)
        }
        else //remind user to input distance through pop up
        {
            let refreshAlert = UIAlertController(title: "Error", message: "Enter distance before proceeding", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
               //   print("Handle Cancel Logic here")
            }))
            present(refreshAlert, animated: true, completion: nil)
            
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

    accessories.append(UIBarButtonItem(title: "Clear", style: UIBarButtonItem.Style.plain, target: self, action: #selector(numberPadClear)))
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
