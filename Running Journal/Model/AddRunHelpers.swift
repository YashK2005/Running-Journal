//
//  SortHelpers.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-08-21.
//

import Foundation
import UIKit


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
    
}
