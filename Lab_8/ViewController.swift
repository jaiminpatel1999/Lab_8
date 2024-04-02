//
//  ViewController.swift
//  Lab_8
//
//  Created by user237118 on 3/31/24.
//



import UIKit
import CoreLocation

class WeatherResponse: Codable {
    var name: String
    var weather: [Weather]
    var main: Main
    var wind: Wind
    
    init(name: String, weather: [Weather], main: Main, wind: Wind) {
        self.name = name
        self.weather = weather
        self.main = main
        self.wind = wind
    }
}

class Weather: Codable {
    var description: String
    var icon: String
    
    init(description: String, icon: String) {
        self.description = description
        self.icon = icon
    }
}

class Main: Codable {
    var temp: Double
    var humidity: Double
    
    init(temp: Double, humidity: Double) {
        self.temp = temp
        self.humidity = humidity
    }
}

class Wind: Codable {
    var speed: Double
    
    init(speed: Double) {
        self.speed = speed
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var weather: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var weatherHumidity: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    
    
    
    let locationManager = CLLocationManager()
    let apiKey = "6d50f8f0231c273edef5470cba2df58f"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func fetchWeatherData(latitude: Double, longitude: Double) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching weather data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.updateUI(with: weatherResponse)
                }
            } catch let error {
                print("Error decoding weather data: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func updateUI(with weatherResponse: WeatherResponse?) {
        guard let weatherResponse = weatherResponse else {
            
            return
        }
        location.text = weatherResponse.name
        weather.text = weatherResponse.weather.first?.description
        weatherTemp.text = "\(Int(weatherResponse.main.temp)) °C"
        weatherHumidity.text = "Humidity: \(weatherResponse.main.humidity) %"
        windSpeed.text = "Wind: \(weatherResponse.wind.speed) km/h"
        
    
        if let iconCode = weatherResponse.weather.first?.icon {
            let iconURLString = "https://openweathermap.org/img/w/\(iconCode).png"
            if let iconURL = URL(string: iconURLString), let iconData = try? Data(contentsOf: iconURL) {
                weatherIcon.image = UIImage(data: iconData)
            }
        }
    }
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        fetchWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
