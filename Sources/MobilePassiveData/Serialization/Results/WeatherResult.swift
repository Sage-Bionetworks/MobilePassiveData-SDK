//
//  WeatherResult.swift
//  
//
//  Copyright © 2020-2021 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation
import JsonModel

extension SerializableResultType {
    public static let weather: SerializableResultType = "weather"
}

/// A `WeatherResult` includes results for both weather and air quality in a consolidated result.
/// Because this result must be mutable, it is defined as a class.
public final class WeatherResult : SerializableResultData {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case identifier, serializableType = "type", startDate, endDate, weather, airQuality
    }
    public private(set) var serializableType: SerializableResultType = .weather

    public let identifier: String
    public var startDate: Date = Date()
    public var endDate: Date = Date()
    public var weather: WeatherServiceResult?
    public var airQuality: AirQualityServiceResult?
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    public func deepCopy() -> WeatherResult {
        let copy = WeatherResult(identifier: identifier)
        copy.startDate = startDate
        copy.endDate = endDate
        copy.weather = weather?.deepCopy()
        copy.airQuality = airQuality?.deepCopy()
        return copy
    }
}

extension WeatherResult : DocumentableStruct {

    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        switch key {
        case .identifier, .serializableType, .startDate:
            return true
        default:
            return false
        }
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .serializableType:
            return .init(constValue: SerializableResultType.weather)
        case .identifier:
            return .init(propertyType: .primitive(.string))
        case .startDate, .endDate:
            return .init(propertyType: .format(.dateTime))
        case .airQuality:
            return .init(propertyType: .reference(AirQualityServiceResult.documentableType()))
        case .weather:
            return .init(propertyType: .reference(WeatherServiceResult.documentableType()))
        }
    }
    
    public static func examples() -> [WeatherResult] {
        let example = WeatherResult(identifier: "weather")
        example.airQuality = AirQualityServiceResult.examples().first
        example.weather = WeatherServiceResult.examples().first
        return [example]
    }
}

public struct WeatherServiceResult : Codable, Equatable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case serviceType = "type", identifier, providerName = "provider", startDate,
             temperature, seaLevelPressure, groundLevelPressure, humidity, clouds, rain, snow, wind
    }
    public private(set) var serviceType: WeatherServiceType = .weather

    public let identifier: String
    public let providerName: WeatherServiceProviderName
    public var startDate: Date
    
    /// Current average temperature. Unit: Celsius
    public let temperature: Double?
    
    /// Atmospheric pressure at sea level. Unit: hPa
    public let seaLevelPressure: Double?
    
    /// Atmospheric pressure at ground level. Unit: hPa
    public let groundLevelPressure: Double?
    
    /// % Humidity.
    public let humidity: Double?
    
    /// % Cloudiness.
    public let clouds: Double?
    
    /// Recent rainfall.
    public let rain: Precipitation?
    
    /// Recent snowfall.
    public let snow: Precipitation?
    
    /// Current wind conditions.
    public let wind: Wind?
    
    public init(identifier: String,
                providerName: WeatherServiceProviderName,
                startDate: Date,
                temperature: Double?,
                seaLevelPressure: Double?,
                groundLevelPressure: Double?,
                humidity: Double?,
                clouds: Double?,
                rain: Precipitation?,
                snow: Precipitation?,
                wind: Wind?) {
        self.identifier = identifier
        self.providerName = providerName
        self.startDate = startDate
        self.temperature = temperature
        self.seaLevelPressure = seaLevelPressure
        self.groundLevelPressure = groundLevelPressure
        self.humidity = humidity
        self.clouds = clouds
        self.rain = rain
        self.snow = snow
        self.wind = wind
    }
    
    public struct Precipitation: Codable, Equatable {
        private enum CodingKeys : String, CodingKey, CaseIterable {
            case pastHour, pastThreeHours
        }
        /// Amount of precipitation in the past hour.
        public let pastHour: Double?
        /// Amount of precipitation in the past three hours.
        public let pastThreeHours: Double?
        
        public init(pastHour: Double?, pastThreeHours: Double?) {
            self.pastHour = pastHour
            self.pastThreeHours = pastThreeHours
        }
    }

    public struct Wind : Codable, Equatable {
        private enum CodingKeys : String, CodingKey, CaseIterable {
            case speed, degrees, gust
        }
        /// Wind speed. Unit: meter/sec
        public let speed: Double
        /// Wind direction, degrees (meteorological)
        public let degrees: Double?
        /// Wind gust. Unit: meter/sec
        public let gust: Double?
        
        public init(speed: Double, degrees: Double?, gust: Double?) {
            self.speed = speed
            self.degrees = degrees
            self.gust = gust
        }
    }
}

extension WeatherServiceResult : SerializableResultData {
    public var serializableType: SerializableResultType {
        .init(rawValue: self.serviceType.rawValue)
    }
    
    public var endDate: Date {
        get { startDate }
        set { }
    }
    
    public func deepCopy() -> WeatherServiceResult {
        self
    }
}

extension WeatherServiceResult : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        switch key {
        case .identifier,.serviceType,.providerName,.startDate:
            return true
        default:
            return false
        }
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .identifier:
            return .init(propertyType: .primitive(.string), propertyDescription: "Result identifier")
        case .serviceType:
            return .init(constValue: WeatherServiceType.weather)
        case .providerName:
            return .init(propertyType: .reference(WeatherServiceProviderName.documentableType()))
        case .startDate:
            return .init(propertyType: .format(.dateTime))
        case .clouds, .temperature, .groundLevelPressure, .seaLevelPressure, .humidity:
            return .init(propertyType: .primitive(.number))
        case .rain, .snow:
            return .init(propertyType: .reference(Precipitation.documentableType()))
        case .wind:
            return .init(propertyType: .reference(Wind.documentableType()))
        }
    }
    
    public static func examples() -> [WeatherServiceResult] {
        [WeatherServiceResult(identifier: "weather", providerName: .openWeather, startDate: Date(), temperature: 20, seaLevelPressure: nil, groundLevelPressure: nil, humidity: 0.9, clouds: 0.4, rain: nil, snow: nil, wind: nil)]
    }
}

extension WeatherServiceResult.Precipitation : DocumentableStruct {

    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        false
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .pastHour:
            return .init(propertyType: .primitive(.number), propertyDescription: "Precipitation in the past hour.")
        case .pastThreeHours:
            return .init(propertyType: .primitive(.number), propertyDescription: "Precipitation in the past 3 hours.")
        }
    }
    
    public static func examples() -> [WeatherServiceResult.Precipitation] {
        [.init(pastHour: 5.0, pastThreeHours: 12.0)]
    }
}

extension WeatherServiceResult.Wind : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        (codingKey as? CodingKeys) == .speed
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .speed, .degrees, .gust:
            return .init(propertyType: .primitive(.number))
        }
    }
    
    public static func examples() -> [WeatherServiceResult.Wind] {
        [.init(speed: 5, degrees: 20, gust: 1)]
    }
}

public struct AirQualityServiceResult : Codable, Equatable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case serviceType = "type", identifier, providerName = "provider", startDate, aqi, category
    }
    public private(set) var serviceType: WeatherServiceType = .airQuality
    
    public let identifier: String
    public let providerName: WeatherServiceProviderName
    public var startDate: Date
    public let aqi: Int?
    public let category: Category?
    
    public init(identifier: String,
                providerName: WeatherServiceProviderName,
                startDate: Date,
                aqi: Int?,
                category: Category?) {
        self.identifier = identifier
        self.providerName = providerName
        self.startDate = startDate
        self.aqi = aqi
        self.category = category
    }

    public struct Category : Codable, Equatable {
        private enum CodingKeys : String, CodingKey, CaseIterable {
            case number, name
        }
        public let number: Int
        public let name: String
        public init(number: Int, name: String) {
            self.number = number
            self.name = name
        }
    }
}

extension AirQualityServiceResult : SerializableResultData {
    public var serializableType: SerializableResultType {
        .init(rawValue: serviceType.rawValue)
    }

    public var endDate: Date {
        get { startDate }
        set {} // ignored
    }
    
    public func deepCopy() -> AirQualityServiceResult {
        self
    }
}

extension AirQualityServiceResult.Category : DocumentableStruct {

    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        true
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .name:
            return .init(propertyType: .primitive(.string))
        case .number:
            return .init(propertyType: .primitive(.number))
        }
    }
    
    public static func examples() -> [AirQualityServiceResult.Category] {
        [AirQualityServiceResult.Category(number: 1, name: "Good")]
    }
}

extension AirQualityServiceResult : DocumentableStruct {

    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        true
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .identifier:
            return .init(propertyType: .primitive(.string))
        case .startDate:
            return .init(propertyType: .format(.dateTime))
        case .serviceType:
            return .init(constValue: WeatherServiceType.airQuality)
        case .providerName:
            return .init(propertyType: .reference(WeatherServiceProviderName.documentableType()))
        case .aqi:
            return .init(propertyType: .primitive(.number), propertyDescription: "Air Quality Index")
        case .category:
            return .init(propertyType: .reference(Category.documentableType()))
        }
    }
    
    public static func examples() -> [AirQualityServiceResult] {
        [AirQualityServiceResult(identifier: "airQuality", providerName: "airNow", startDate: Date(), aqi: 2, category: .init(number: 2, name: "Moderate"))]
    }
}
