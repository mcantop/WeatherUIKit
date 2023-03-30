//
//  ViewController.swift
//  WeatherUIKit
//
//  Created by Maciej on 30/03/2023.
//

import UIKit

final class WeatherViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private var conditionImageView: UIImageView!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var conditionLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    @IBAction private func addLocationButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction private func getLocationButtonTapped(_ sender: Any) {
        
    }
}

