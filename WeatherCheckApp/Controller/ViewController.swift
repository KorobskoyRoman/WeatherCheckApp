//
//  ViewController.swift
//  WeatherCheckApp
//
//  Created by Roman Korobskoy on 18.12.2021.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet var conditionImageView: UIImageView!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherManager.delegate = self
        setupTextField()
    }
    
    private func setupTextField() {
        searchTextField.delegate = self
        searchTextField.returnKeyType = .go
        searchTextField.autocapitalizationType = .words
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //для нажатия на кнопку go
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) { //очищаем строку поиска когда endEditing = true
        
        if let city = searchTextField.text {
            weatherManager.fetchWearher(cityName: city)
        }
        searchTextField.text = ""
    }   
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Введите что-нибудь!"
            return false
        }
    }
}

extension ViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManger: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = String(weather.temperature)
            self.cityLabel.text = weather.cityName
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error.localizedDescription)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locations = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = locations.coordinate.latitude
            let lon = locations.coordinate.longitude
            weatherManager.fetchWeatherCoords(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
