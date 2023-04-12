//
//  WeatherService.swift
//  WeatherUIKit
//
//  Created by Maciej on 31/03/2023.
//

import Foundation
import Alamofire

enum WeatherError: Error, LocalizedError {
    case unknown
    case invalidCity
    case custom(description: String)
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Hey, this is an unknown error!"
        case .invalidCity:
            return "City's name is invalid.\nPlease try again"
        case .custom(let description):
            return description
        }
    }
}

struct WeatherService {
    private let apiKey = "9506d8971cedbd747700c868d5a4c549"
    private let cacheManager = CacheManager()
    
    func fetchWeather(byCity city: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city /// Handles if user types something with space
        let path = "https://api.openweathermap.org/data/2.5/weather?q=%@&appid=%@&units=metric"
        let urlString = String(format: path, query, apiKey)
        
        handleRequest(urlString: urlString, completion: completion)
    }
    
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        let path = "https://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=%@&units=metric"
        let urlString = String(format: path, lat, lon, apiKey)
        
        handleRequest(urlString: urlString, completion: completion)
    }
    
    private func getWeatherError(error: AFError, data: Data?) -> Error? {
        guard error.responseCode == 404,
              let data = data,
              let decodedError = try? JSONDecoder().decode(WeatherDataFailure.self, from: data) else {
                  return nil
              }
        
        return WeatherError.custom(description: decodedError.message.capitalized)
    }
    
    private func handleRequest(urlString: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        AF.request(urlString)
            .validate()
            .responseDecodable(of: WeatherData.self, queue: .main, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let weatherData):
                    cacheManager.cacheCity(weatherData.model.name)
                    completion(.success(weatherData.model))
                case .failure(let error):
                    if let customError = getWeatherError(error: error, data: response.data) {
                        completion(.failure(customError))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
    }
}
