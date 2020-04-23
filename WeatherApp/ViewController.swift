//
//  ViewController.swift
//  WeatherApp
//
//  Created by Мария Матичина on 4/13/20.
//  Copyright © 2020 Мария Матичина. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var apparentTemperatureLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton! // Пользователь нажал на обновить, кнопка недоступна, пока приложение не получит данные  от сервера
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var particlesView: ParticlesViewController!
    
    
    let locationManager = CLLocationManager() // Объект, который вы используете для запуска и остановки доставки событий, связанных с местоположением, в ваше приложение.

    lazy var weatherManager = APIWeatherManager(apiKey: "fdbbc79ea86c7a5956bf1b277811ee6d") // после создания API
    let coordinates = Coordinates(latitude: 56.149503, longitude: 44.174421) // получили координаты
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentWeatherData()
        switchActivityIndicator(on: true)
        
        // MARK: подписываемся, что будем реализововать методы данного протокола
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // desiredAccuracy - Точность данных о местоположении, // kCLLocationAccuracyBest - Наилучший уровень точности местоположения
        locationManager.requestWhenInUseAuthorization() // запрос местположения при запуске
        locationManager.startUpdatingLocation() // запускаем координаты
    }
    
    // MARK:- refreshButtonTapped
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
              getCurrentWeatherData()
          }
    
    // MARK:-
    // Когда происходит обновление нашей геопозиции, вызывается этот метод
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last! as CLLocation
        
        print("my location latitude: \(userLocation.coordinate.latitude), longitude: \(userLocation.coordinate.longitude )")
    }
    
    // MARK:- acitivityIndicator
    func switchActivityIndicator(on: Bool) {
        refreshButton.isHidden = on
        if on {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func getCurrentWeatherData() {
        weatherManager.fetchCurrentWeatherWith(coordinates: coordinates) { ( result ) in /* работает в фоновом режиме и все происходит в фоновом потоке, а мы пытаемся обновить interface, пытаемся отоброзить alertController. ВСЕ ОБНОВЛЕНИЕ ДОЛЖНО ПРОИСХОДИТЬ В ГЛАВНОМ ПОТОКЕ:
             1. каждый из этих кейсов поместить в гл.поток
             2. или в APIManager в func fetch<T> прописать
             */
            
            self.switchActivityIndicator(on: false)
            
            if let result = result {
                self.updateUIWith(currentWeather: result)
            } else {
                self.showAlert(title: "Unable to get data", message: "123")// "\(error.localizedDescription)")
            }
            
            //                            switch result {
            //                            case .Success(let currentWeather): // передаем экземпляр погода, который получили
            //                                //  MARK:- вызываем метод
            //                                self.updateUIWith(currentWeather: currentWeather)
            //                            case .Failure(let error as NSError):
            
            //             self.showAlert(title: "Unable to get data", message: "\(error.localizedDescription)")
            // }
        }
    }
    
    // MARK: функция, которая принимает 3 аргумента: title, message, error
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK:- внесем данные погоды - данные, которые придумали сами
    //        let icon = WeatherIconManager.Rain.image
    //        let currentWeather = CurrentWeather(temperature: 10.0, apparentTemperature: 5.0, humidity: 30, pressure: 750, icon: icon)
    
    
    
    /*
     //        let urlString = "https://api.darksky.net/forecast/7b7e2b196d54ff1a3174b24e313371a9/37.8267,-122.4233"
     let baseURL = URL(string: "https://api.darksky.net/forecast/7b7e2b196d54ff1a3174b24e313371a9/")
     let fullUrl = URL(string: "37.8267,-122.4233", relativeTo: baseURL)
     
     // MARK:- создание сессии, чтобы получить данные
     let sessionconfiguration = URLSessionConfiguration.default
     let session = URLSession(configuration: sessionconfiguration)
     
     // MARK:- создание запроса
     let request = URLRequest(url: fullUrl!)
     
     // MARK:- cоздает задачу, которая извлекает содержимое указанного URL
     let dataTask = session.dataTask(with: fullUrl!) { (data, response, error) in
     }
     dataTask.resume()
     */
    
    // MARK:- обновить UI (2 способ)
    func updateUIWith(currentWeather: CurrentWeather) {
        
        self.temperatureLabel.text = currentWeather.temperatureString
        self.apparentTemperatureLabel.text = currentWeather.apparentString
        self.humidityLabel.text = currentWeather.humidityString
        self.pressureLabel.text = currentWeather.pressureString
        self.imageView.image = currentWeather.icon
        
        self.particlesView.setParticles(currentWeather.icon)
    }
    
}


