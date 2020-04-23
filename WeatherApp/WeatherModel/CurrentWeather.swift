//
//  CurrentWeather.swift
//  WeatherApp
//
//  Created by Мария Матичина on 4/13/20.
//  Copyright © 2020 Мария Матичина. All rights reserved.
//

import Foundation
import UIKit

struct CurrentWeather {
    let temperature: Double
    let apparentTemperature: Double
    let humidity: Double
    let pressure: Double
    let icon: UIImage // из-за него импортируем UIKit, без него будет неизвестный класс
}

// MARK:- вставляем ключи из json который парсили
extension CurrentWeather: JSONDecodable {
    init?(JSON:[String: AnyObject]) { // инициализируем, проваливающийся init
        guard let temperature = JSON["temperature"] as? Double,
            let apparentTemperature = JSON["apparentTemperature"] as? Double,
            let humidity = JSON["humidity"] as? Double,
            let pressure = JSON["pressure"] as? Double,
            let iconString = JSON["icon"] as? String else {
                return nil
        }
        let icon = WeatherIconManager(rawValue: iconString).image
        
        // MARK: полученные значенив в св-ва
        self.temperature = temperature
        self.apparentTemperature = apparentTemperature
        self.humidity = humidity
        self.pressure = pressure
        self.icon = icon
    }
}

// MARK:- обновить UI (2 способ)
extension CurrentWeather {
    
    var temperatureString: String {
        return "\(Int((temperature - 32) * 5 / 9)) ºC"  // отображаем в ºC используя формулу
    }
    var apparentString: String {
        return "\(Int((apparentTemperature - 32) * 5 / 9)) ºC"
    }
    var humidityString: String {
        return "\(Int(humidity * 100)) %"
    }
    var pressureString: String {
        return "\(Int(pressure * 0.75006375541921)) mm"
    }
}

