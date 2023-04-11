//
//  Double+Extension.swift
//  WeatherUIKit
//
//  Created by Maciej on 31/03/2023.
//

import Foundation

extension Double {
    var toTempString: String {
        return String(format: "%.1f", self) + "°C"
    }
    
    var toInt: Int {
        return Int(self)
    }
}
