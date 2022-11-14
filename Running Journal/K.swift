//
//  K.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-09-19.
//

import UIKit

struct K
{
    struct userDefaults {
        static let distance = "distanceUnits"
        static let temperature = "temperatureUnits"
        static let read = "readDict"
        static let recentDate = "recentDate"
        
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let discoverability = "discoverability"
        
        static let nameSaved = "nameSaved"
        
        static let unread = "unread"
        
        static let appRunsCount = "appRunsCount"
        static let lastVersionPromptedForReview = "lastVersionPromptedForReview"
    }
    
    static var reloadSharing = false
}
