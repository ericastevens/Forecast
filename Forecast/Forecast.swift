//
//  Forecast.swift
//  Forecast
//
//  Created by Erica Stevens on 11/27/21.
//

import Foundation

struct ForecastsResponse: Decodable {
    var success: Bool
    var forecasts: [ForecastsResponse.Forecast]
    
    enum ResponseCodingKeys: String, CodingKey {
        case forecasts = "response"
        case error, success
    }
    
    private struct InnerResponse: Decodable {
        var periods: [ForecastsResponse.Forecast]
        var interval: String
        
        enum InnerCodingKeys: String, CodingKey {
            case periods, interval
        }
        
        init(from decoder: Decoder) throws {
            let innerResponseContainer = try decoder.container(keyedBy: InnerCodingKeys.self)
            self.interval = try innerResponseContainer.decode(String.self, forKey: .interval)
            self.periods = try innerResponseContainer.decode([Forecast].self, forKey: .periods)
        }
    }
    
    struct Forecast: Decodable {
        // To-Do: Extract 'isDay" Bool from json so that we can add dark/light mode settings
        var maxTempF: Int
        var minTempF: Int
        var icon: String
        var sunriseISO: String
        var sunsetISO: String
        var weather: String
    }
    
    init(from decoder: Decoder) throws {
        let responseContainer = try decoder.container(keyedBy: ResponseCodingKeys.self)
        self.success = try responseContainer.decode(Bool.self, forKey: .success)
        let innerResponse = try responseContainer.decode([ForecastsResponse.InnerResponse].self, forKey: .forecasts)
        var forecasts: [ForecastsResponse.Forecast] = []
        for infoDict in innerResponse {
            for forecast in infoDict.periods {
                forecasts.append(forecast)
            }
        }
        self.forecasts = forecasts
    }
}
