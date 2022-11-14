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
        //asking user for notificatin permission
        print(UIApplication.shared.isRegisteredForRemoteNotifications)
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                //UIApplication.registerForRemoteNotifications()
            }
        }
        
        let acceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
        acceptSharesOperation.queuePriority = .veryHigh
        acceptSharesOperation.perShareCompletionBlock = {metadata, share, error in
            if error != nil {
                
                print(error?.localizedDescription)
            }
            print(share?.url)
            print("HIHI \(share?[CKShare.SystemFieldKey.title])")
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
            //setting up userdefaults for read/unread
            var name = share?.owner.userIdentity.nameComponents
            let fullName = (name?.givenName ?? "First") + " " + (name?.familyName ?? "Last") //TODO: public database
            let defaults = UserDefaults.standard
            var dict = defaults.dictionary(forKey: K.userDefaults.read) ?? [:]
            dict[fullName] = "unread"
            defaults.set(dict, forKey: K.userDefaults.read)
            
            //setting up notifications
            let database = CKContainer.default().sharedCloudDatabase
            //database.fetch
            database.fetchAllSubscriptions { result, error in
                if error != nil{
                    print(error?.localizedDescription)
                }
                else if true
                {
                    var check = true
//                    for res in result!
//                    {
//
//                        let reszone = res as! CKRecordZoneSubscription
//                        if reszone.zoneID == share?.recordID.zoneID
//                        {
//                            check = false
//                        }
//                    }
                    if result!.isEmpty  //if check == true
                    {
            
                        
//                        let subscription = CKDatabaseSubscription()
//                        subscription.recordType = "CD_UserRun"
                        
                        
                        //let subscription = CKQuerySubscription(recordType: "CD_UserRun", predicate: predicate, options: .firesOnRecordCreation)
                        let notification = CKSubscription.NotificationInfo()
//                        notification.desir
                        
                        notification.alertBody = "A friend uploaded a run!" //"\(share?.owner.userIdentity.nameComponents?.givenName ?? "A Friend") uploaded a run!"
                        //notification.
                        let sub = CKDatabaseSubscription() //CKRecordZoneSubscription(zoneID: (share?.recordID.zoneID)!)
                        
                        
                        sub.recordType = "CD_UserRun"
                        sub.notificationInfo = notification
                      //  sub.
                        
                       // subscription.notificationInfo = notification
                        
                        CKContainer.default().sharedCloudDatabase.save(sub) { Result, error in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
            
            
//            let subscription = CKDatabaseSubscription()
//            subscription.recordType = "CD_UserRun"
//            //let subscription = CKQuerySubscription(recordType: "CD_UserRun", predicate: predicate, options: .firesOnRecordCreation)
//            let notification = CKSubscription.NotificationInfo()
//            name = share?.owner.userIdentity.nameComponents
//            notification.alertBody = "\(name?.givenName ?? "A friend") uploaded a run!"
//           // notification.setValue(name?.givenName ?? "First" + (name?.familyName ?? "Last"), forKey: "name")
//            //notification.selector
//            //subscription.val
//            subscription.notificationInfo = notification
//
//            CKContainer.default().sharedCloudDatabase.save(subscription) { Result, error in
//                if let error = error {
//                    print(error.localizedDescription)
//                }
//            }
        }
        CKContainer(identifier: cloudKitShareMetadata.containerIdentifier).add(acceptSharesOperation)
    }
}

