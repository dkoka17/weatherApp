//
//  Service.swift
//  Services
//
//  Created by Saba Khutsishvili on 12/18/20.
//

import Foundation

class Service {
    
    private let apiKey = "00471134f17814f6da0072fbaa482189"
    private var components = URLComponents()
    private let unit = "metric"

    
    init() {
        components.scheme = "https"
        components.host = "api.openweathermap.org"
    }
    
    func loadTodayWeatherByCity(for city: String, completion: @escaping (Result<Weather, Error>) -> ()) {
        components.path = "/data/2.5/weather"
        let parameters = [
            "appid": apiKey.description,
            "units": unit.description,
            "q": city
        ]
        components.queryItems = parameters.map { key, value in
            return URLQueryItem(name: key, value: value)
        }
        
        if let url = components.url {
            let request = URLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let result = try decoder.decode(Weather.self, from: data)
                        completion(.success(result))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(ServiceError.noData))
                }
            })
            task.resume()
        } else {
            completion(.failure(ServiceError.invalidParameters))
        }
    }

    func loadTodayWeatherByCoordinats(for coor: coord, completion: @escaping (Result<Weather, Error>) -> ()) {
        let parameters = [
            "appid": apiKey.description,
            "units": unit.description,
            "lat": String(coor.lat),
            "lon": String(coor.lon)
        ]
        components.queryItems = parameters.map { key, value in
            return URLQueryItem(name: key, value: value)
        }
        
        if let url = components.url {
            let request = URLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let result = try decoder.decode(Weather.self, from: data)
                        completion(.success(result))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(ServiceError.noData))
                }
            })
            task.resume()
        } else {
            completion(.failure(ServiceError.invalidParameters))
        }
    }
    
    func loadFiveDayWeatherByCity(for city: String, completion: @escaping (Result<FiveDayWeather, Error>) -> ()) {
        components.path = "/data/2.5/forecast"
        let parameters = [
            "appid": apiKey.description,
            "units": unit.description,
            "q": city
        ]
        components.queryItems = parameters.map { key, value in
            return URLQueryItem(name: key, value: value)
        }
        
        if let url = components.url {
            let request = URLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let result = try decoder.decode(FiveDayWeather.self, from: data)
                        completion(.success(result))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(ServiceError.noData))
                }
            })
            task.resume()
        } else {
            completion(.failure(ServiceError.invalidParameters))
        }
    }

    
    
}


enum ServiceError: Error {
    case noData
    case invalidParameters
}

