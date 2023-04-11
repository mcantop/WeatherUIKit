//
//  WeatherModel.swift
//  WeatherUIKit
//
//  Created by Maciej on 31/03/2023.
//

import UIKit

struct WeatherData: Decodable {
    let name: String
    let main: Main
    let weather: [Weather]
    
    var model: WeatherModel {
        return .init(
            name: name,
            temperature: main.temp.toInt,
            conditionId: weather.first?.id ?? 0,
            conditionDescription: weather.first?.description ?? ""
        )
    }
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
}

struct WeatherModel {
    let name: String
    let temperature: Int
    let conditionId: Int
    let conditionDescription: String
    
    var conditionImage: UIImage? {
        switch conditionId {
        case 200...299:
            return .thunderstorm
        case 300...399:
            return .drizzle
        case 500...599:
            return .rain
        case 600...699:
            return .snow
        case 700...799:
            return .atmosphere
        case 800:
            return .clear
        case 800...899:
            return .clouds
        default:
            return .clear
        }
    }
}
