//
//  Pt2AddRunInfoVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-08-26.
//

import UIKit


class Pt2AddRunInfoVC: UIViewController {
    

    
    @IBOutlet weak var runTypeButton: UIButton!
    
    var selectedRunType = ""
    
    
    @IBOutlet weak var shoeUsedButton: UIButton!
    let shoeDict: [String: Double] = ["Asics" : 200, //get from database
                                   "Nike"  : 150,
                                   "Hoka"  : 12]
    let units = "km" //get from database
    
    @IBOutlet weak var dietTextView: UITextView!
    @IBOutlet weak var dietTimePicker: UIDatePicker!
    
    @IBOutlet weak var sorenessBeforeTextView: UITextView!
    @IBOutlet weak var sorenessDuringTextView: UITextView!
    @IBOutlet weak var sorenessAfterTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        //creating menus
        runTypeMenuSetup()
        shoeMenuSetup()
        
        //for text view border
        for textview in [dietTextView, sorenessBeforeTextView, sorenessDuringTextView, sorenessAfterTextView] {
            textview?.layer.borderColor = UIColor.lightGray.cgColor
            textview?.layer.borderWidth = 1
        }
        
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        addRunHelp.backButton(self: self, back: true)
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) { //TODO: segue to next page
        
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
        print(runOptionsMenu.children)
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
        print(tagName)
        runTypeButton.setTitle("\(tagName)", for: .normal)
        selectedRunType = tagName
    }
    
//MARK: - Shoe Menu Setup
    func shoeMenuSetup() { //add functionality for adding a new shoe
        var menuOptions:[UIAction] = []
        for (key, value) in shoeDict {
            menuOptions.append(UIAction(title: "\(key) - \(value)\(units)") { [self] (action) in self.shoeUsedButton.setTitle("\(key) - \(value)\(units)", for: .normal)
            })}
        
        let shoeMenu = UIMenu(children: menuOptions)
        print(shoeMenu.children)
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
