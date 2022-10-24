//
//  SharingSettingsVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-10-22.
//

import UIKit
import CloudKit

class SharingSettingsVC: UIViewController {
    
    var records: [SharingVC.recordsByFullName] = []
    var editMode = true
    
    @IBOutlet weak var peopleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(records.count)
        
        records.sort { $0.fullName > $1.fullName }
        
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
       checkForNoRecords()
    }
    
    func checkForNoRecords()
    {
        if records.count == 0
        {
            let alert = UIAlertController(title: "No one is sharing with you", message: "Ask a friend for their sharing link to view their runs", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                self.dismiss(animated: true)
            }))
            present(alert, animated: true)
        }
    }
    
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SharingSettingsVC: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("you tapped me!")
    }
    
}

extension SharingSettingsVC: UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
         //TODO: get sharing people count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = peopleTableView.dequeueReusableCell(withIdentifier: "deleteCell", for: indexPath) as! deleteCell
        cell.nameLabel.text = records[indexPath.row].fullName
        cell.deleteButton.tintColor = .red
        
        let confirmation = UIAction(title: "Delete") { action in
            print("HI")
            let name = self.records[indexPath.row].fullName
            let confirmationAlert = UIAlertController(title: "Remove \(name)?", message: "You will no longer be able to view \(name)'s runs", preferredStyle: .alert)
            
            confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            }))
                                        
            confirmationAlert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { action in
                let shareRecordID = CKRecord.ID(recordName: CKRecordNameZoneWideShare, zoneID: self.records[indexPath.row].zoneID)
                
                let container = CKContainer.default()
                container.sharedCloudDatabase.delete(withRecordID: shareRecordID) { record, error in
                    print("DELETED")
                    self.records.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.checkForNoRecords()
                        self.peopleTableView.reloadData()
                    }
                    K.reloadSharing = true
                }
            }))
            self.present(confirmationAlert, animated: true)
        }
        cell.deleteButton.addAction(confirmation, for: .touchUpInside)
      //  cell.selectionStyle = .none
        return cell
    }

}


