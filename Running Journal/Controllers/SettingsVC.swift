//
//  SettingsVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-09-18.
//

import UIKit

class SettingsVC: UIViewController {

    let userDefaults = UserDefaults.standard
    let distanceUnits = "km"
    let tempUnits = "°C"
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableViewSetup()
        
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        //save user settings in userDefaults
        let distanceIndexPath = IndexPath(row: 0, section: 0)
        let distanceCell = settingsTableView.cellForRow(at: distanceIndexPath) as! settingsUnitsCell
        userDefaults.set(distanceCell.segmentControl.titleForSegment(at: distanceCell.segmentControl.selectedSegmentIndex), forKey: K.userDefaults.distance)
        
        let temperatureIndexPath = IndexPath(row: 1, section: 0)
        let temperatureCell = settingsTableView.cellForRow(at: temperatureIndexPath) as! settingsUnitsCell
        userDefaults.set(temperatureCell.segmentControl.titleForSegment(at: temperatureCell.segmentControl.selectedSegmentIndex), forKey: K.userDefaults.temperature)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableViewSetup()
    {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //save user settings in userDefaults
        let distanceIndexPath = IndexPath(row: 0, section: 0)
        let distanceCell = settingsTableView.cellForRow(at: distanceIndexPath) as! settingsUnitsCell
        userDefaults.set(distanceCell.segmentControl.titleForSegment(at: distanceCell.segmentControl.selectedSegmentIndex), forKey: K.userDefaults.distance)
        
        let temperatureIndexPath = IndexPath(row: 1, section: 0)
        let temperatureCell = settingsTableView.cellForRow(at: temperatureIndexPath) as! settingsUnitsCell
        userDefaults.set(temperatureCell.segmentControl.titleForSegment(at: temperatureCell.segmentControl.selectedSegmentIndex), forKey: K.userDefaults.temperature)
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


extension SettingsVC: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me!")
        if indexPath.row == 2
        {
            performSegue(withIdentifier: "settingsToShoes", sender: self)
        }
        if indexPath.row == 3
        {
            addRunHelp.requestReviewManually()
        }
    }
    
    
}

extension SettingsVC: UITableViewDataSource
{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 //km or mi
        {
            let distanceKey = K.userDefaults.distance
            
            let cell = settingsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! settingsUnitsCell
            cell.settingNameLabel.text = "Distance Units"
            
            cell.segmentControl.setTitle("km", forSegmentAt: 0)
            cell.segmentControl.setTitle("mi", forSegmentAt: 1)
            
            
            
            if userDefaults.string(forKey: distanceKey) == "km"
            {
                cell.segmentControl.selectedSegmentIndex = 0
            }
            else
            {
                cell.segmentControl.selectedSegmentIndex = 1
            }
            return cell
            
        }
        else if indexPath.row == 1 //celc or fahr
        {
            let temperatureKey = K.userDefaults.temperature
            
            let cell = settingsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! settingsUnitsCell
            cell.settingNameLabel.text = "Temperature Units"
            
            cell.segmentControl.setTitle("°C", forSegmentAt: 0)
            cell.segmentControl.setTitle("°F", forSegmentAt: 1)
            
            if userDefaults.string(forKey: temperatureKey) == "°C"
            {
                cell.segmentControl.selectedSegmentIndex = 0
            }
            else
            {
                cell.segmentControl.selectedSegmentIndex = 1
            }
            return cell
        }
        else if indexPath.row == 2
        {
            let cell = settingsTableView.dequeueReusableCell(withIdentifier: "newScreenCell", for: indexPath) as! settingsNewScreenCell
            cell.settingLabel.text = "Shoes"
            return cell
        }
        else if indexPath.row == 3
        {
            let cell = settingsTableView.dequeueReusableCell(withIdentifier: "newScreenCell", for: indexPath) as! settingsNewScreenCell
            cell.settingLabel.text = "Rate App in App Store"
            cell.settingLabel.textColor = .systemPurple
            cell.accessoryType = .none
            return cell
        }
        else
        {
            let cell = settingsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! settingsUnitsCell
            cell.settingNameLabel.text = "Default"
            
            cell.segmentControl.setTitle("1", forSegmentAt: 0)
            cell.segmentControl.setTitle("2", forSegmentAt: 1)
            return cell
        }
        
        
        
    }
        
    
}
