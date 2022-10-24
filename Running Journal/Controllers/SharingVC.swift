//
//  SharingVC.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-08-18.
//

import UIKit
import Foundation
import CloudKit
import CoreData

class SharingVC: UIViewController {
    
    var zoneCount = 0
    
    
    struct recordsByFullName {
        var fullName:String
        var records:[CKRecord]
        var recentUpload:Date
        var zoneID: CKRecordZone.ID
    }
    
    var recordArray:[recordsByFullName] = []
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var sharingTableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  NotificationCenter.default.addObserver(self, selector: #selector(viewAppeared), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        
        //setupSettingsMenu()
        
        sharingTableView.dataSource = self
        sharingTableView.delegate = self
        sharingTableView.rowHeight = 70
        
        // Do any additional setup after loading the view.

    }
    
    @objc func viewAppeared()
    {
        print("VIEWAPPEARED")
        if zoneCount == 0 || K.reloadSharing == true
        {
            settingButton.isEnabled = false
            addFriendButton.isEnabled = false
            recordArray = []
            sharingTableView.reloadData()
            loadingIndicator.center = self.view.center
            loadingIndicator.startAnimating()
            getAllRuns()
            
            K.reloadSharing = false
        }
        else
        {
            settingButton.isEnabled = true
            addFriendButton.isEnabled = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("viewdidappear")
        if zoneCount == 0 || K.reloadSharing == true
        {
            settingButton.isEnabled = false
            addFriendButton.isEnabled = false
            recordArray = []
            sharingTableView.reloadData()
            loadingIndicator.center = self.view.center
            loadingIndicator.startAnimating()
            getAllRuns()
            
            K.reloadSharing == false
        }
        else
        {
            settingButton.isEnabled = true
            addFriendButton.isEnabled = true
        }
    }
    
    
    
    
    
    func setupSettingsMenu()
    {
        var menuOptions:[UIAction] = []
        print("Afaf")
        menuOptions.append(UIAction(title: "Manage who is sharing with me") { action in
           //TODO: add new screen with list of people sharing
            self.performSegue(withIdentifier: "sharingToSettings", sender: self)
        })
        menuOptions.append(UIAction(title: "Manage who I am sharing with") { action in
            self.presentUICloudSharingController()
        })
        let menu = UIMenu(children: menuOptions)
        settingButton.menu = menu
        settingButton.showsMenuAsPrimaryAction = true
        print(settingButton.menu)
    }
    
    
    
    
    
    @IBAction func sharingSettingsButtonClicked(_ sender: UIButton) {

    }
    
    @IBAction func addFriendButtonClicked(_ sender: UIButton) {
        presentUICloudSharingController()

    }
    
    func getAllRuns()
    {
        let container = CKContainer.default()
        let sharedDB = container.sharedCloudDatabase
        var id = CKRecordZone.ID()
        var ckrecordid = CKRecord.ID()
        sharedDB.fetchAllRecordZones(completionHandler: {(recordZone, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
            }
            if let recordZones = recordZone {
                print("CCC" + String(recordZones.count))
                self.zoneCount = recordZones.count
                if recordZones.count == 0
                {
                    self.reloadData()
                }
                for i in 0..<recordZones.count
                {
                    if recordZones[i].zoneID.zoneName == "com.apple.coredata.cloudkit.zone"
                    {
                        id = recordZones[i].zoneID
                        
                        let participantID = CKRecord.ID(recordName: id.ownerName)
                        container.fetchShareParticipant(withUserRecordID: participantID, completionHandler: {(record, error) in
                            if error != nil {print(error?.localizedDescription)}
                            
                            let fullName = (record?.userIdentity.nameComponents?.givenName ?? "First") + " " + (record?.userIdentity.nameComponents?.familyName ?? "Last")
                            let pred = NSPredicate(value: true)
                            let query = CKQuery(recordType: "CD_UserRun", predicate: pred)
                       //     let sortDescriptor = NSSortDescriptor(key: "createdTimestamp", ascending: false)
                          //  query.sortDescriptors = [sortDescriptor]
                            
                           
                            sharedDB.fetch(withQuery: query, inZoneWith: id, completionHandler: {(result) in
                                do {
                                    let betterResult = try result.get().matchResults
                                    var records:[CKRecord] = []
                                    var recentDate = Date(timeIntervalSince1970: TimeInterval(0))
                                    for rec in betterResult
                                    {
                                        let record = try rec.1.get()
                                        records.append(record)
                                       // print(record.value(forKey: "createdTimestamp"))
                                        let currentDate = record.creationDate!
                                        if currentDate > recentDate{
                                            recentDate = currentDate
                                        }
                                    }
                                    let fullRecord = recordsByFullName(fullName: fullName, records: records, recentUpload: recentDate, zoneID: id)
                                    self.recordArray.append(fullRecord)
                                    if self.recordArray.count == recordZones.count
                                    {
                                        self.reloadData()
                                    }
                                    
                                }
                                catch
                                {
                                    print(error.localizedDescription)
                                }
                                
                            })
                        })
                    }
                    print("RELOADING")
                }
            }
        })
    }
    
    func reloadData()
    {
        DispatchQueue.main.async {
           
           // self.loadingVC.removeFromSuperview()
            self.loadingIndicator.stopAnimating()
            self.settingButton.isEnabled = true
            self.addFriendButton.isEnabled = true
            self.setupSettingsMenu()
            print("REMOVED")
            self.recordArray.sort(by: { $0.recentUpload > $1.recentUpload })
            self.sharingTableView.reloadData()
            print("RELOAD DATA")
            if self.recordArray.count == 0
            {
                
                let alert = UIAlertController(title: "No one is sharing with you", message: "Click the add friend button to share your runs and ask your friends to share with you.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    self.dismiss(animated: true)
                }))
                self.present(alert, animated: true)
                
            }
        }
    }
  
    
    func presentUICloudSharingController()
    {
        let container = CKContainer.default()
        
        
        let privateDB = container.privateCloudDatabase
        let zoneID = CKRecordZone.ID(zoneName: "com.apple.coredata.cloudkit.zone")
        let zoneName = zoneID.zoneName
        let zone = CKRecordZone(zoneID: zoneID)
        print("\(zoneID) - \(zoneName)")
       // let zoneName = CKRecordZone.ID.defaultZoneName
        
        print("CKRECORDSHARE: \(CKRecordZone(zoneID: zoneID).share)")
        
        privateDB.fetch(withRecordZoneID: zoneID, completionHandler: {(zone, error) in
            if zone?.share != nil //share already created
            {
                
                let shareID = zone?.share?.recordID
                
                print(shareID!.zoneID.ownerName)
                
           //     print((zone.share.owner.userIdentity.nameComponents?.familyName ?? "") + (zone.share.owner.userIdentity.nameComponents?.givenName ?? ""))
                privateDB.fetch(withRecordID: shareID!, completionHandler: {(share, error) in
                    DispatchQueue.main.async {
                        let shareController = UICloudSharingController(share: share as! CKShare, container: container)
                        shareController.availablePermissions = [UICloudSharingController.PermissionOptions.allowReadOnly, UICloudSharingController.PermissionOptions.allowPrivate]
                        self.present(shareController, animated: true, completion: nil)
                    }
                    
                })
                
               // let sharingController = UICloudSharingController(share: zone.share!, container: container)
            }
            else //share doesn't exist and must be created
            {
                let share = CKShare(recordZoneID: zoneID)
                
                share.publicPermission = .readOnly
                
                DispatchQueue.main.async {
                    let sharingController = UICloudSharingController (preparationHandler: {(UICloudSharingController, handler:
                        @escaping (CKShare?, CKContainer?, Error?) -> Void) in
                        let modifyOp = CKModifyRecordsOperation(recordsToSave:
                            [share], recordIDsToDelete: nil)
                        modifyOp.modifyRecordsCompletionBlock = { (record, recordID,
                            error) in
                            handler(share, CKContainer.default(), error)
                        }
                        CKContainer.default().privateCloudDatabase.add(modifyOp)
                        print("urli: \(share.url)")
                    })

                    sharingController.availablePermissions = [UICloudSharingController.PermissionOptions.allowReadOnly, UICloudSharingController.PermissionOptions.allowPrivate]
                    
                    
                    self.present(sharingController, animated: true)
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sharingToPerson"
        {
            let destinationVC = segue.destination as! SharingPersonVC
            let index = sender as! Int
            let recordsToSend = recordArray[index].records
            destinationVC.runs = recordsToSend
            destinationVC.userFullName = recordArray[index].fullName
        }
        if segue.identifier == "sharingToSettings"
        {
            let destinationVC = segue.destination as! SharingSettingsVC
            destinationVC.records = recordArray
        }
    }
}

extension SharingVC: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("you tapped me!")
        performSegue(withIdentifier: "sharingToPerson", sender: indexPath.row)
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension SharingVC: UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordArray.count //TODO: get sharing people count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sharingTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! sharingPeopleCell
        let record = recordArray[indexPath.row]
        cell.nameLabel.text = record.fullName
        cell.recentRunLabel.text = getTableViewDate(record: record)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func getTableViewDate(record:recordsByFullName) -> String
    {
        var dateString = ""
        let date = record.recentUpload
        if date == Date(timeIntervalSince1970: TimeInterval(0))
        {
            return "N/A"
        }
        
        let relativeFormatter = DateFormatter()
        relativeFormatter.timeStyle = .none
        relativeFormatter.dateStyle = .medium
        relativeFormatter.doesRelativeDateFormatting = true

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"

        let string = relativeFormatter.string(from: date)
        if let _ = string.rangeOfCharacter(from: .decimalDigits)
        {
            dateString = formatter.string(from: date)
        }
        else
        {
            dateString = string
        }
        return dateString
    }
}


