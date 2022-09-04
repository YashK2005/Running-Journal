//
//  Pt3AddRunInfoVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-08-30.
//

import UIKit

class Pt3AddRunInfoVC: UIViewController {

    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var publicTextField: UITextView!
    @IBOutlet weak var privateTextField: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }))

        self.present(refreshAlert, animated: true, completion: nil)
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
