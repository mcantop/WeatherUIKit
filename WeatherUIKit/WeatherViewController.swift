//
//  ViewController.swift
//  WeatherUIKit
//
//  Created by Maciej on 30/03/2023.
//

import UIKit
import CoreLocation
import SkeletonView

private enum Constants {
    static let showAddCityIdentifier = "ShowAddCity"
}

final class WeatherViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private var conditionImageView: UIImageView!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var conditionLabel: UILabel!
    
    // MARK: - Properties
    private let weatherService = WeatherService()
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showAnimation()
        fetchWeather()
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
            locationManager.requestLocation()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        default:
            locationPermissionAlert()
        }
    }
}

// MARK: - Private Helpers
private extension WeatherViewController {
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
    
    func fetchWeather() {
        weatherService.fetchWeather(byCity: "Gizycko") { [weak self] result in
            switch result {
            case .success(let model):
                self?.updateUI(with: model)
            case .failure(let error):
                print("DEBUG: Error - \(error.localizedDescription)")
            }
        }
    }
    
    func updateUI(with model: WeatherModel) {
        hideAnimation()
        
        temperatureLabel.text = model.temperature.toTempString
        conditionLabel.text = model.conditionDescription.capitalized
        navigationItem.title = model.name
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
        if let location = locations.last {
            manager.stopUpdatingLocation()
            
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            weatherService.fetchWeather(lat: lat, lon: lon) { result in
                switch result {
                case .success(let model):
                    DispatchQueue.main.async {
                        self.updateUI(with: model)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { }
}
