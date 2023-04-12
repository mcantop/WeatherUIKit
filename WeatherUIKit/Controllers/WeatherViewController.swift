//
//  ViewController.swift
//  WeatherUIKit
//
//  Created by Maciej on 30/03/2023.
//

import UIKit
import CoreLocation
import SkeletonView
import Loaf

private enum Constants {
    static let showAddCityIdentifier = "ShowAddCity"
}

final class WeatherViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private var conditionImageView: UIImageView!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var conditionLabel: UILabel!
    
    // MARK: - Properties
    private let defaultCity = "Warsaw"
    private let weatherService = WeatherService()
    private let cacheManager = CacheManager()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let city = cacheManager.getCachedCity() ?? defaultCity
        
        fetchWeather(byCity: city)
    }
    
    // MARK: - Actions
    @IBAction private func addCityButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: Constants.showAddCityIdentifier, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.showAddCityIdentifier {
            if let destination = segue.destination as? AddCityViewController {
                destination.delegate = self
            }
        }
    }
    
    @IBAction private func getLocationButtonTapped(_ sender: Any) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        default:
            locationPermissionAlert()
        }
    }
}

// MARK: - Private Helpers
private extension WeatherViewController {
    func fetchWeather(byLocation location: CLLocation) {
        showAnimation()
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        weatherService.fetchWeather(lat: lat, lon: lon) { [weak self] result in
            self?.handleWeatherResult(result)
        }
    }
    
    func fetchWeather(byCity city: String) {
        showAnimation()
        
        weatherService.fetchWeather(byCity: city) { [weak self] result in
            self?.handleWeatherResult(result)
        }
    }
    
    func handleWeatherResult(_ result: Result<WeatherModel, Error>) {
        switch result {
        case .success(let model):
            self.updateUI(with: model)
        case .failure(let error):
            handleError(error)
        }
    }
    
    func showAnimation() {
        conditionImageView.showAnimatedGradientSkeleton()
        temperatureLabel.showAnimatedGradientSkeleton()
        conditionLabel.showAnimatedGradientSkeleton()
    }
    
    func hideAnimation() {
        conditionImageView.hideSkeleton()
        temperatureLabel.hideSkeleton()
        conditionLabel.hideSkeleton()
    }
    
    func updateUI(with model: WeatherModel) {
        hideAnimation()
        
        navigationItem.title = model.name
        
        conditionImageView.image = model.conditionImage
        temperatureLabel.text = model.temperature.toTempString
        conditionLabel.text = model.conditionDescription.capitalized
    }
    
    func locationPermissionAlert() {
        let alertController = UIAlertController(
            title: "Location Permission Required",
            message: "Would you like to enable location permission in Settings?",
            preferredStyle: .alert
        )
        
        let enableAction = UIAlertAction(
            title: "Go to Settings",
            style: .default
        ) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL)
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel
        )
        
        alertController.addAction(enableAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    func handleError(_ error: Error) {
        hideAnimation()
        
        navigationItem.title = ""
        conditionImageView.image = UIImage(systemName: "exclamationmark.bubble.circle")
        conditionImageView.tintColor = .systemRed
        temperatureLabel.text = "Oops!"
        conditionLabel.text = "Something went wrong.\nPlease try again"
        
        Loaf(error.localizedDescription, state: .error, location: .bottom, sender: self).show()
    }
}

// MARK: - WeatherViewControllerDelegate
extension WeatherViewController: WeatherViewControllerDelegate {
    func didUpdateWeatherFromSearch(model: WeatherModel) {
        presentedViewController?.dismiss(animated: true) { [weak self] in
            self?.updateUI(with: model)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        manager.stopUpdatingLocation()
        
        fetchWeather(byLocation: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleError(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus != .notDetermined else { return }
        manager.requestLocation()
    }
}
