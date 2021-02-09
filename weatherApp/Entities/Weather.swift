//
//  Weather.swift
//  weatherApp
//
//  Created by dato on 1/29/21.
//

import Foundation

struct FiveDayWeather: Codable{
    let city: city
    let list: [list]
}

struct city: Codable{
    let name: String
    let coord: coord
}

struct list: Codable {
    let dt_txt: String
    let dt: Double
    let weather: [weather]
    let main: main
}

struct Weather: Codable {
    let coord: coord
    let weather: [weather]
    let base: String
    let main: main
    let visibility: Int
    let wind: wind
    let clouds: clouds
    let dt: Int64
    let sys: sys
    let timezone: Int
    let id: Int32
    let name: String
    let cod: Int
}
/*
 common structs
 ----------------------------
 */
struct coord: Codable {
    let lon: Double
    let lat: Double
}

struct weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
    
}
/*
 ----------------------------
 */

struct main: Codable  {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Double
    let humidity: Double
}

struct wind: Codable{
    let speed: Double
    let deg: Int
}

struct clouds: Codable{
    let all: Int
}

struct sys: Codable{
    let type: Int
    let id: Int
    let country: String
    let sunrise: Int32
    let sunset: Int32
}
