//
//  AddCityViewController.swift
//  WeatherUIKit
//
//  Created by Maciej on 31/03/2023.
//

import UIKit

protocol WeatherViewControllerDelegate: AnyObject {
    func didUpdateWeatherFromSearch(model: WeatherModel)
}

final class AddCityViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var cityTextField: UITextField!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var statusLabel: UILabel!
    
    // MARK: - Properties
    private let weatherService = WeatherService()
    weak var delegate: WeatherViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupGestures()
    }
    
    // MARK: - Actions
    @IBAction private func searchButtonTapped(_ sender: Any) {
        statusLabel.isHidden = true
        
        guard let cityText = cityTextField.text, !cityText.isEmpty else {
            handleSearchError("City is empty!\nPlease try again")
            return
        }
        
        handleCitySearch(cityText)
    }
}

private extension AddCityViewController {
    func setupUI() {
        view.backgroundColor = UIColor.init(white: 0.3, alpha: 0.4)
        cityTextField.becomeFirstResponder()
        statusLabel.isHidden = true
        
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    func handleCitySearch(_ city: String) {
        print("[DEBUG] Searching for \(city)..")
        
        view.endEditing(true)
        activityIndicator.startAnimating()
        weatherService.fetchWeather(byCity: city) { [weak self] result in
            self?.activityIndicator.stopAnimating()
            switch result {
            case .success(let model):
                self?.handleSearchSuccess(model)
            case .failure(let error):
                self?.handleSearchError(error.localizedDescription)
            }
        }
    }
    
    func handleSearchError(_ errorText: String) {
        statusLabel.isHidden = false
        statusLabel.textColor = .systemRed
        statusLabel.text = errorText
    }
    
    func handleSearchSuccess(_ model: WeatherModel) {
        statusLabel.isHidden = false
        statusLabel.textColor = .systemGreen
        statusLabel.text = "Success!"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            self?.delegate?.didUpdateWeatherFromSearch(model: model)
        }
    }
    
    @objc
    func dismissViewController() {
        dismiss(animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AddCityViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.view /// It means it only works on the parent (main) view, which is the background
    }
}
