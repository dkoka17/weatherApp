//
//  Service.swift
//  Services
//
//  Created by Saba Khutsishvili on 12/18/20.
//

import Foundation

class Service {
    
    private let apiKey = "fe909c4849bdaecc28b2be78ed0576668570a416"
    private var components = URLComponents()

    
    init() {
        components.scheme = "https"
        components.host = "calendarific.com"
        components.path = "/api/v2/holidays"
    }
    
    
    func loadHolidays(for country: Country, year: Int = 2020, completion: @escaping (Result<[Holiday], Error>) -> ()) {
        let parameters = [
            "api_key": apiKey.description,
            "country": country.rawValue,
            "year": year.description
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
                        let result = try decoder.decode(ServiceResponse.self, from: data)
                        completion(.success(result.response.holidays))
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

enum Country: String {
    case usa = "US"
    case georgia = "GE"
    case greatBritain = "GB"
}
