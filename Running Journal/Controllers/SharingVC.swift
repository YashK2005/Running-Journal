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
    var userIDs:[CKRecord.ID] = []
    var userNames:[String] = []
    var records:[CKRecord] = []
    var uniqueIndexes:[Int] = []
    var zoneIDS:[CKRecordZone.ID] = []
    
    @IBOutlet weak var sharingTableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        sharingTableView.dataSource = self
        sharingTableView.dataSource = self
        sharingTableView.rowHeight = 70
        
        // Do any additional setup after loading the view.
        print("sharing")
        
        Task{
            do {
                let id = await getZoneID()
                let runRecords = try await getAllRuns(zoneID: id)
                print("E", runRecords)
                for record in runRecords
                {
                    records.append(record)
                    userIDs.append(record.creatorUserRecordID!)
                }
                userNames = try await getParticipantNames()
                print(userNames)
                removeDuplicates()
                print(userNames, records)
                
                sharingTableView.reloadData()
            }
            catch
            {
                print(error)
            }
            //var indexesToDelete:[Int] = []
            
        }
        
        
    }
    
    @IBAction func sharingSettingsButtonClicked(_ sender: UIButton) {
       
//        let privateDB = CKContainer.default().privateCloudDatabase
//        let predicate = NSPredicate(format: "CD_distance = %@", 5)
//        let query = CKQuery(recordType: "CD_UserRun", predicate: predicate)
//        privateDB.fetch(withQuery: query, completionHandler: {_ in
//
//        })
   
      
    }
    
    @IBAction func addFriendButtonClicked(_ sender: UIButton) {
        presentUICloudSharingController()
        
        print("hi")
        
    }
    
    
    func getAllRuns(zoneID: CKRecordZone.ID) async throws -> [CKRecord]
    {
       // let zoneID = getZoneID()
        
        let container = CKContainer.default()
       // container.shareParticipant(forUserRecordID: <#T##CKRecord.ID#>)
        let cloudDB = container.sharedCloudDatabase
        let pred = NSPredicate(value: true)
        
  //      let descriptors = NSSortDescriptor(keyPath:, ascending: <#T##Bool#>)
        let query = CKQuery(recordType: "CD_UserRun", predicate: pred)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        
        query.sortDescriptors = [sortDescriptor]
        
//        for id in zoneIDS
//        {
//            print(container.shareParticipant(forUserRecordID: id))
//        }
        let (runResults, _) = try await cloudDB.records(matching: query, inZoneWith: zoneID, resultsLimit: 1)
    
        return runResults
            .compactMap { _, result in
                guard let record = try? result.get()
                       // print(result),
                      
                   //     let runUser = record.value(forKeyPath: "createdUserRecordName") as? String
                        
                else {return nil}
                
             //   print(CKUserIdentity().nameComponents?.givenName)
                return record
            }
    }
    
    func getParticipantNames() async throws -> [String] //adds full name of participants to array
    {
        var participantNames:[String] = []
        let container = CKContainer.default()
        for userID in userIDs {
            let participant = try await container.shareParticipant(forUserRecordID: userID)
            let participantFirstName = participant.userIdentity.nameComponents?.givenName ?? ""
            let participantLastName = participant.userIdentity.nameComponents?.familyName ?? ""
            let participantFullName = participantFirstName + " " + participantLastName
            //print(participant.userIdentity.nameComponents?.familyName)
            participantNames.append(participantFullName)
        }
      //  let participants = try await container.share
       // await print(try container.shareParticipants(forUserRecordIDs: userIDs))
        return participantNames
    }
    
    func getZoneID() async  -> CKRecordZone.ID
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
                       // print(recordZones[i].share.)
                        self.zoneIDS.append(id)
                        print(id.ownerName)
                       // print(container.share)
                        
                        
                    }
                }
                
            }
        })
        
      //  try await print(container.shareParticipant(forUserRecordID: ckrecordid))
        
        while id.zoneName != "com.apple.coredata.cloudkit.zone" {
           // print("stucl")
        }
        
        return id
        
                        
    }
    
    func removeDuplicates() //gets the indexes of unique first names
    {
        var result:[String] = []
        for (index, name) in userNames.enumerated()
        {
            if result.contains(name) == false{
                result.append(name)
                uniqueIndexes.append(index)
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
        return uniqueIndexes.count //TODO: get sharing people count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sharingTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! sharingPeopleCell
        let index = uniqueIndexes[indexPath.row]
        cell.nameLabel.text = userNames[index]
        let date = records[index].creationDate!
        
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
