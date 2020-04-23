//
//  APIManager.swift
//  WeatherApp
//
//  Created by Мария Матичина on 4/15/20.
//  Copyright © 2020 Мария Матичина. All rights reserved.
//

import Foundation

typealias JSONTask = URLSessionDataTask // возвращает загруженные данные
typealias JSONcompletionHandler = ([String: AnyObject]?, URLResponse?, Error?) -> Void
// HTTPURLResponse - ответ мб различный, но т.к. мы работаем с HTTPProtocol, мы должны получать HTTPURLResponse

protocol JSONDecodable  {
    init?(JSON:[String: AnyObject]) // проваливающий init, который может вернуть nil
}

// MARK:- web адрес разобьем на базовый адрес и ту часть, которую добавляем к нему
protocol FinalURLPoint {
    var baseURL: URL { get }
    var path: String { get }
    var request: URLRequest { get } // запрос 
}

enum APIResult<T> {
    case Success(T) // когда будет success, передавал получившееся значение. Что бы success мог передавать currentWeather, мы должеы определить общий тип, чтобы этот interface мы могли использовать НЕ только в конкретном случаи
    case Failure(Error) // показывал ошибку
}

protocol APIManager {
    // MARK:- создание сессии, чтобы получить данные
    // сессия - обрашение к серверу
    var sessionConfiguration: URLSessionConfiguration { get } // конфигурация сессии
    var session: URLSession { get } // сессия, которая образуется за счет конфигурации сессии
    
    // default конфигурация может нам не подойти, предусмотрим, укажим свою 
    // init(sessionConfiguration: URLSessionConfiguration) - метод не нужен, напишем 2 init в самом APIWeatherManager
    
    // MARK:- получаем данные (1)
    func JSONTaskWith(request: URLRequest, completionHandler: @escaping JSONcompletionHandler) -> JSONTask
    // completionHandler - обработчик завершения
    // @escaping применяется для типов клоужера, потому что раньше наши аргументы клоужера были @escaping, т.е. мы могли передать в наши клоужеры что-то, теперь не можем, пока не поставим @escaping
    
    // MARK: получаем данные (2)
    func fetch<T: JSONDecodable>(request: URLRequest, parse: @escaping ([String: AnyObject]?) -> T?, completionHandler: (APIResult<T>) -> Void)  // могут прийти данные в другом формате
    // completionHandler должен что-то вернуть - success или failure
    // Когда мы вызываем метод fetch, хотим чтобы уневерсальный тип T тоже соот. протоколу JSONDecodable
    
    /*
     внутри fetch<T> используем JSONTaskWith,
     в метод fetch<T> мы передаем запрос request: URLRequest,
     запрос попадает внутрь JSONTaskWith
     внутри JSONTaskWith срабатывает completionHandler по завершению которого получаем ([String: AnyObject]?, HTTPURLResponse?, Error?)
     затем пытаемся преоброзавать полученные данные в формат T? - тут будет стоять currentWeather
     если все удается, срабатывает completionHandler: (APIResult<T>) -> Void, который передает текущий экземпляр currentWeather т.е. Success или Failure
     */
}


extension APIManager {
    /*
    func JSONTaskWith(request: URLRequest, completionHandler: @escaping JSONcompletionHandler) -> JSONTask {


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
 */
    
    // MARK:- проверяем не = ли json nil
    func fetch<T>(request: URLRequest, parse: @escaping ([String: AnyObject]?) -> T?, completionHandler: @escaping (APIResult<T>) -> Void) {
        
        let dataTask = self.JSONTaskWith(request: request) { (json, response, error) in
            DispatchQueue.main.async (execute: {
                guard let json = json else {
                    if let error = error { // если есть какая-то ошибка, то
                        completionHandler(.Failure(error)) // передаем ее сюда
                    }
                    return
                }
                
                // MARK: выйдя из guard, проверяем получается ли преобразовать ([String: AnyObject]?) -> в T?
                if let value = parse(json) { // если получилось
                    completionHandler(.Success(value)) // то передаем это значение
                } else { // если не получается
                    let error = NSError(domain: SWINetworkingErrorDomain, code: 200, userInfo: nil) // создаем ошибку
                    completionHandler(.Failure(error)) // передаем ее
                }
            })
        }
        dataTask.resume()
    }
}


