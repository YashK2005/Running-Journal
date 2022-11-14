//
//  TabBarController.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-08-18.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(UserDefaults.standard.bool(forKey: K.userDefaults.unread))
        if (UserDefaults.standard.bool(forKey: K.userDefaults.unread)) == true
        {
            self.tabBar.items?[1].badgeColor = .systemRed
            tabBar.items?[1].badgeValue = ""
        }
        
        
        self.selectedIndex = 0
        //sets the pastruns tab as the default when app is opened
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
