//
//  CacheManager.swift
//  WeatherUIKit
//
//  Created by Maciej on 12/04/2023.
//

import Foundation

struct CacheManager {
    private let vault = UserDefaults.standard
    
    private enum Key: String {
        case city
    }
    
    func cacheCity(_ city: String) {
        vault.set(city, forKey: Key.city.rawValue)
    }
    
    func getCachedCity() -> String? {
        return vault.value(forKey: Key.city.rawValue) as? String
    }
}
