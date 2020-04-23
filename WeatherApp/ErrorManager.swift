 //
//  ErrorManager.swift
//  WeatherApp
//
//  Created by Мария Матичина on 4/15/20.
//  Copyright © 2020 Мария Матичина. All rights reserved.
//

 // файл для обработки ошибок из интернета
import Foundation

 public let SWINetworkingErrorDomain = "ru.swiftbook.WeatherApp.NetworkingError"
// при использовании сторонних библиотек у них тоже мб такая ошибка, таким образом у наc получится что мы используем не ту ошибку, когда пытаемся описать проблему, чтобы пространство имен соблюдалось напишем 3 буквы SWI

 public let MissingHTTPResponeError = 100 // возможная ошибка. Отсутствует HTTPRespon
 public let UnexpectedResponseError = 200
