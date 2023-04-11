//
//  Int+Extension.swift
//  WeatherUIKit
//
//  Created by Maciej on 09/04/2023.
//

import Foundation

extension Int {
    var toString: String {
        return String(self)
    }
    
    var toTempString: String {
        return String(self) + "°C"
    }
}
