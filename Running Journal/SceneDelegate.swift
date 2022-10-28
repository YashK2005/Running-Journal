//
//  SceneDelegate.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-08-18.
//

import UIKit
import CloudKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        //TODO: present UIAlert to ask user if they would like to confirm adding person as a friend
        
        let acceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
        acceptSharesOperation.queuePriority = .veryHigh
        acceptSharesOperation.perShareCompletionBlock = {metadata, share, error in
            if error != nil {
                print(error?.localizedDescription)
            }
            DispatchQueue.main.async {
                print(self.window?.rootViewController)
                self.window?.rootViewController?.dismiss(animated: false, completion: nil)
                if let tabBarController = self.window!.rootViewController as? UITabBarController {
                    K.reloadSharing = true
                    if tabBarController.selectedIndex != 1
                    {
                        tabBarController.selectedIndex = 1
                    }
                    else
                    {
                        tabBarController.selectedIndex = 0
                        tabBarController.selectedIndex = 1
                        
                    }
                }
            }
        }
        
        
    
        
        CKContainer(identifier: cloudKitShareMetadata.containerIdentifier).add(acceptSharesOperation)
        
        
        let container = CKContainer.default()
        let privateDB = container.privateCloudDatabase
        let zoneID = CKRecordZone.ID(zoneName: "com.apple.coredata.cloudkit.zone")
//        privateDB.fetch(withRecordZoneID: zoneID) { zone, error in
//            if zone?.share != nil
//            {
//                privateDB.fetch(withRecordID: (zone?.share!.recordID)!) { record, error in
//                    let share = record as! CKShare
//                    let owner = cloudKitShareMetadata.ownerIdentity.userRecordID
//                   // cloudKitShareMetadata.share.owner
//                    share.addParticipant(cloudKitShareMetadata.share.owner)
//                }
//
//            }
//            else
//            {
//                let share = CKShare(recordZoneID: zoneID)
//                share.publicPermission = .none
//                privateDB.save(share) { record, error in
//                    let share = record as! CKShare
//                    share.addParticipant(cloudKitShareMetadata.share.owner)
//                }
//
//            }
//        }
        let persistentContainer = NSPersistentCloudKitContainer(name: "Running_Journal")
      //  persistentContainer.acceptShareInvitations(from: [cloudKitShareMetadata], into: sha)
        
        
    }
    
}

