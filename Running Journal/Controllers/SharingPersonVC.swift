//
//  SharingPersonVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-10-18.
//

import UIKit
import CloudKit

class SharingPersonVC: UIViewController {
    
    let userDefaults = UserDefaults.standard
    var distanceUnits = "km"
    var temperatureUnits = "°C"
    var runs: [CKRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        distanceUnits = userDefaults.string(forKey: K.userDefaults.distance) ?? "km"
        temperatureUnits = userDefaults.string(forKey: K.userDefaults.temperature) ?? "°C"

        // Do any additional setup after loading the view.
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
