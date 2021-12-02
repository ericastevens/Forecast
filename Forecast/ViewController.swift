//
//  ViewController.swift
//  Forecast
//
//  Created by Erica Stevens on 11/27/21.
//

import UIKit

// Learning Objectives:
// Learn best way to store private keys & api endpoints
// Determine best architecture/design pattern for networking class (Coordinator?)
// Learn to use Codable to extract Swift objects from data ✅
// Add robust error handling for networking class

class ViewController: UIViewController {
    
    private let clientID = "zYYyvxefumON5t3u9JVgB"
    private let clientSecret = "bMXflvpaACZi1pC0DU2N4KyuDOHDFxp94FsMm18J"
    private var forecastsEndpoint: String {
        return "http://api.aerisapi.com/forecasts/11235?client_id=\(clientID)&client_secret=\(clientSecret)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let endpointURL = URL(string: forecastsEndpoint) else {
            return
        }
        
        let forecastsRequest = URLRequest(url: endpointURL)
        
        let _ = URLSession.shared.dataTask(with: forecastsRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            
            guard let data = data,
                error == nil else {
                    print(error!)
                    return
                }
            
            do {
                let forecastData = try JSONDecoder().decode(ForecastsResponse.self, from: data)
                for forecast in forecastData.forecasts {
                    print(forecast)
                }
                
            } catch let error {
                print(error)
            }
        }).resume()
    }
}

