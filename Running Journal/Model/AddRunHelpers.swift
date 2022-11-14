//
//  SortHelpers.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-08-21.
//

import Foundation
import UIKit
import StoreKit


class addRunHelp {
    static func backButton(self: UIViewController, back: Bool) {
        let refreshAlert = UIAlertController(title: "Are You Sure?", message: "All data will be lost.", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Delete Run", style: .destructive, handler: { (action: UIAlertAction!) in
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            
        }))
        
        if back {
            refreshAlert.addAction(UIAlertAction(title: "Back to Previous Page", style: .default, handler: { (action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            }))
        }
        
        
        

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
           //   print("Handle Cancel Logic here")
        }))

        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    static func editingBackButton(self: UIViewController, back: Bool)
    {
        let refreshAlert = UIAlertController(title: "Are You Sure?", message: "All edits will be lost.", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Delete Changes", style: .destructive, handler: { (action: UIAlertAction!) in
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            
        }))
        
        if back {
            refreshAlert.addAction(UIAlertAction(title: "Back to Previous Page", style: .default, handler: { (action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            }))
        }
        
        
        

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
           //   print("Handle Cancel Logic here")
        }))

        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    static func requestReview() {
    var count = UserDefaults.standard.integer(forKey: K.userDefaults.appRunsCount)
        count += 1
        UserDefaults.standard.set(count, forKey: K.userDefaults.appRunsCount)
       
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
            else { fatalError("Expected to find a bundle version in the info dictionary") }

        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: K.userDefaults.lastVersionPromptedForReview)
       
        if count % 5 == 0 && currentVersion != lastVersionPromptedForReview {
         
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                    UserDefaults.standard.set(currentVersion, forKey: K.userDefaults.lastVersionPromptedForReview)
               }
           }
       }
   }
    
    static func requestReviewManually() {
        // Note: Replace the placeholder value below with the App Store ID for your app.
        //       You can find the App Store ID in your app's product URL.
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id6444382884?action=write-review")
            else { fatalError("Expected a valid URL") }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
    
    
   
}
