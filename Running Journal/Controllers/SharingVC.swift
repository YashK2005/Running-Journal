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
    
    struct recordsByFullName {
        var fullName:String
        var records:[CKRecord]
        var recentUpload:Date
    
    }
    var recordArray:[recordsByFullName] = []
    
    @IBOutlet weak var sharingTableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        sharingTableView.dataSource = self
        sharingTableView.dataSource = self
        sharingTableView.rowHeight = 70
        
        // Do any additional setup after loading the view.
        print("sharing")
        getZoneOwnerNames()
    }
    
    @IBAction func sharingSettingsButtonClicked(_ sender: UIButton) {

    }
    
    @IBAction func addFriendButtonClicked(_ sender: UIButton) {
        presentUICloudSharingController()

    }
    
    func getZoneOwnerNames()
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
                for i in 0..<recordZones.count
                {
                    if recordZones[i].zoneID.zoneName == "com.apple.coredata.cloudkit.zone"
                    {
                        id = recordZones[i].zoneID
                        print("IIII: \(id)")
                        
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
                                        print(currentDate)
                                        if currentDate > recentDate{
                                            recentDate = currentDate
                                        }
                                    }
                                    
                                    
                                    print(recentDate)
                                   
                                    let fullRecord = recordsByFullName(fullName: fullName, records: records, recentUpload: recentDate)
                                    self.recordArray.append(fullRecord)
                                    DispatchQueue.main.async {
                                        self.sharingTableView.reloadData()
                                    }
                                }
                                catch
                                {
                                    print(error.localizedDescription)
                                }
                                
                            })
                        
                            DispatchQueue.main.async {
                                self.sharingTableView.reloadData()
                            }
                        })
                    }
                }
            }
        })
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
        
        let share = CKShare(recordZoneID: zoneID)
        print(share)
        print(share.creationDate)
        print("urla: \(share.url)")
        share.publicPermission = .readOnly
        
        
        
        print(share.owner)
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

extension SharingVC: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me!")
        
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
        
        
        
        let date = record.recentUpload
        //print(record)

        let relativeFormatter = DateFormatter()
        relativeFormatter.timeStyle = .none
        relativeFormatter.dateStyle = .medium
        relativeFormatter.doesRelativeDateFormatting = true

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"

        var dateString = ""
        let string = relativeFormatter.string(from: date)
        if let _ = string.rangeOfCharacter(from: .decimalDigits)
        {
            dateString = formatter.string(from: date)
        }
        else
        {
            dateString = string
        }

        
        
        cell.recentRunLabel.text = "Last Upload: \(dateString)"
        cell.selectionStyle = .none
        
        return cell
    }
}
