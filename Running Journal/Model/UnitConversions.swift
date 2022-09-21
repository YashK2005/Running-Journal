//
//  UnitConversions.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-09-10.
//

import Foundation
import UIKit

class unitConversions
{
    static func kmToMiles(km: Double) -> Double
    {
        return round(km * 0.621371 * 100) / 100
    }
    
    static func milesTokm(miles: Double) -> Double
    {
        return round(miles * 1.60934 * 100) / 100
    }
    
    static func celToFahr(celcius: Int) -> Int
    {
        var answer = celcius * 9 / 5
        return answer + 32
    }
    
    static func fahrToCel(fahrenheit: Int) -> Int
    {
        var answer = fahrenheit - 32
        answer = answer * 5 / 9
        return answer
    }
    
}
