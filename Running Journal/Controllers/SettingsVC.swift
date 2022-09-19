//
//  SettingsVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-09-18.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableViewSetup()
        
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableViewSetup()
    {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
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
    }
    
    
}

extension SettingsVC: UITableViewDataSource
{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! settingsUnitsCell
        cell.settingNameLabel.text = "Distance Units"
        
        cell.segmentControl.setTitle("km", forSegmentAt: 0)
        cell.segmentControl.setTitle("mi", forSegmentAt: 1)
        
        return cell
        
        
    }
        
    
}
