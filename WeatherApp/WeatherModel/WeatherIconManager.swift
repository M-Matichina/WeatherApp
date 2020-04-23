//
//  WeatherIconManager.swift
//  WeatherApp
//
//  Created by Мария Матичина on 4/13/20.
//  Copyright © 2020 Мария Матичина. All rights reserved.
//

import Foundation
import UIKit

enum WeatherIconManager: String { // Исходное знчение enum - String
    
    // MARK:- варианты иконок
    // Переписываем все вар. icon
    case ClearDay = "clear-day"
    case ClearNight = "clear-night"
    case Rain = "rain"
    case Snow = "snow"
    case Sleet = "sleet" // дождь со снегом
    case Wind = "wind"
    case Fog = "fog"
    case Cloudy = "cloudy"
    case PartlyCloudyDay = "partly-cloudy-day"
    case PartlyCloudyNight = "partly-cloudy-night"
    case UnpredictedIcon = "unpredicted-icon" // Вдруг пришло значение иконки, которой у нас нет
    
    // MARK:- какое значение иконки нам приходит
    // У enum есть инициализатор, который инициализирует все его члены, чтобы приходило все без ошибок, нужно определить этот init
    init(rawValue: String) {
        switch rawValue {
        case "clear-day": self = .ClearDay
        case "clear-night": self = .ClearNight
        case "rain": self = .Rain
        case "snow": self = .Snow
        case "wind": self = .Wind
        case "cloudy": self = .Cloudy
        case "partly-cloudy-day": self = .PartlyCloudyDay
        case "partly-cloudy-night": self = .PartlyCloudyNight
        default: self = .UnpredictedIcon
        }
    }
}

// MARK:- св-во присваиваемое значение икнонки
// введем расширение, чтобы не загромождать enum
extension WeatherIconManager {
    var image: UIImage {
        return UIImage(named: self.rawValue)!
    }
}
