//
//  PastRunsVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-08-18.
//

import UIKit

class PastRunsVC: UIViewController {

    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var sortOptionsMenu: UIMenu!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        menuSetup()
        print("past runs")
        
        
        
    }
    
    //MARK: - Sort Menu
    
    func menuSetup() {
//
        let tagsSubMenuOptions = [UICommand(title: "Race", action: #selector(tagRaceSort)),
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
        let tagsSubMenu = UIMenu(title: "Run Type", children: tagsSubMenuOptions)
        
        
        
        let date = UICommand(title: "Date", action: #selector(dateSort))
        
        let distance = UICommand(title: "Distance", action: #selector(distanceSort))
        let pace = UICommand(title: "Pace", action: #selector(paceSort))
        
        let menu = UIMenu(children: [date, distance, pace, tagsSubMenu])
        
      
        
        //handler to intercept event related to UIActions.
        
        
        sortButton.menu = menu
        
        
    }
    
    @objc func dateSort() {
        print("date")
        sortButton.setTitle("Sort By: Date", for: .normal)
    }
    @objc func distanceSort() {
        print("distance")
        sortButton.setTitle("Sort By: Distance", for: .normal)
    }
    @objc func paceSort() {
        sortButton.setTitle("Sort By: Pace", for: .normal)
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
        sortButton.setTitle("Sort By: Run Type (\(tagName))", for: .normal)
    }

    
    
    //MARK: - Add Run
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue)
    {
        
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
