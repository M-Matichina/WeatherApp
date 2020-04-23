//
//  APIWeatherManager.swift
//  WeatherApp
//
//  Created by Мария Матичина on 4/16/20.
//  Copyright © 2020 Мария Матичина. All rights reserved.
//

// APIWeatherManager - его суть, вернуть текущую погоду
import Foundation

 struct Coordinates {
    let latitude: Double
    let longitude: Double
}

// MARK:- какой прогноз погоды мы хотим знать
enum ForecastType: FinalURLPoint {
    case Current(apiKey: String, coordinates: Coordinates)
    
    var baseURL: URL {
        return URL(string: "https://api.darksky.net")! // адрес точно правильный
    }
    var path: String { // в зависимосьт от того какой прогноз погоды мы хотим знать, у нас будет свой адрес
        //  т.к. 1 case, то switch с однис адресом
        switch self {
        case .Current(let apiKey, let coordinates): // когда захотим узнать погоду для типа .Current, мы по умолчанию будем использовать
            return "/forecast/\(apiKey)/\(coordinates.latitude),\(coordinates.longitude)" // вот такой составной адрес
        }
    }
    
    var request: URLRequest {
        if let url = URL(string: baseURL.absoluteString + path) {
            return URLRequest(url: url)
        } else {
            let url = URL(fileURLWithPath: path, relativeTo: baseURL)
            return URLRequest(url: url)
        }
    }
}


final class APIWeatherManager: APIManager {
    func fetch<T>(request: URLRequest, parse: @escaping ([String : AnyObject]?) -> T?, completionHandler: (APIResult<T>) -> Void) where T : JSONDecodable {
    }
    
    func JSONTaskWith(request: URLRequest, completionHandler: @escaping ([String : AnyObject]?, URLResponse?, Error?) -> Void) -> JSONTask {
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            // вдруг это будет не HTTPURLResponse
            guard let HTTPURLResponse = response as? HTTPURLResponse else {
                
                let userInfo = [
                    NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "")
                ]
                
                let error = NSError(domain: SWINetworkingErrorDomain, code: 100, userInfo: userInfo)
                /*
                 domain - категория
                 code - код ошибки
                 userInfo - пояснение ошибки
                 */
                
                completionHandler(nil, nil, error)
                return
            }
            
            // MARK:- рассмотрим вариант, что мы получили ответ и пришедшие данные = nil
            if data == nil {
                if let error = error {
                    completionHandler(nil, HTTPURLResponse, error)
                }
            } else { // если пришедшие данные не = nil
                switch HTTPURLResponse.statusCode {
                case 200:
                    do { // пытаемся поймать ошибку
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                        completionHandler(json, HTTPURLResponse, nil)
                    } catch let error as NSError {
                        completionHandler(nil, HTTPURLResponse, error)
                    }
                default:
                    print("We have got response status \(HTTPURLResponse.statusCode)")
                }
            }
        }
        return dataTask
    }
    
    
    // class, который никто не будет наследовать
    // подписались под протокол, чтобы реализовать методы
    
    let sessionConfiguration: URLSessionConfiguration
    lazy var session: URLSession = { // ленивое св-во, потому что будет создаваться с помощью SessionConfiguration, и она будет создаваться в тот момент, когда будем к ней обращаться
        return URLSession(configuration: self.sessionConfiguration)
    } () // вызовем клоужер
    
    // MARK: init
    let apiKey: String
    init(sessionConfiguration: URLSessionConfiguration, apiKey: String) {
        self.sessionConfiguration = sessionConfiguration
        self.apiKey = apiKey
    }
    
    // MARK: convenience init
    // вносим в него только apiKey, потому что в 90% случаев будем использовать стандартеый sessionConfiguration т.е. default, чтобы лишний раз не вписывать в него никакое значение, будем использовать его по умолчанию
    convenience init(apiKey: String) {
        self.init(sessionConfiguration: URLSessionConfiguration.default, apiKey: apiKey)
    }
    
    // MARK:- вернуть текущую погоду
    func fetchCurrentWeatherWith(coordinates: Coordinates, complitionHandler: @escaping (CurrentWeather?) -> Void) {
        /*
         coordinates - какая погода по заданныи координатам
         complitionHandler должен вернуть экземпляр нашнй погоды или ошибку
         в кажестве входного параметра <CurrentWeather>
         */
        
        // Request который можем получить, чтобы потом вставить в fetch
        let request = ForecastType.Current(apiKey: self.apiKey, coordinates: coordinates).request
        
        fetch(request: request, parse: { (json) -> JSONDecodable? in
            if let dictionary = json?["currently"] as? [String: AnyObject]  { // сможем ли получить словарь. кастим его в новый словарь
                // из этого словаря надо получить currentWeather, но пока не можем это сделать, нужно воспользоваться протколом
                complitionHandler(CurrentWeather(JSON: dictionary))
                return CurrentWeather(JSON: dictionary)
            } else {
                complitionHandler(nil)
                return nil
            }
        }) { (result) in
            
//            print(result)
//            complitionHandler(nil)
        }
    }
}
