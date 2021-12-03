//
//  ViewController.swift
//  Forecast
//
//  Created by Erica Stevens on 11/27/21.
//

import UIKit

// Learning Objectives:
// Learn best way to store private keys & api endpoints ✅
// Determine best architecture/design pattern for networking class (Coordinator?)
// Experiment with async/await
// Learn to use Codable to extract Swift objects from data ✅
// Add robust error handling for networking class
// Handle trait changes successfully

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var forecastsCollectionView: UICollectionView!
    var forecasts: [ForecastsResponse.Forecast] = []
    
    private var forecastsEndpoint: String {
        guard let clientID = Bundle.main.infoDictionary?["CLIENT_ID"],
              let clientSecret = Bundle.main.infoDictionary?["CLIENT_SECRET"] else {
            return ""
        }
        return "http://api.aerisapi.com/forecasts/11235?client_id=\(clientID)&client_secret=\(clientSecret)"
    }
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCollectionViewData()
    }
    
    // MARK: Helper Methods
    
    func loadCollectionViewData() {
        guard let endpointURL = URL(string: forecastsEndpoint) else { return }
        requestWeeklyForecast(from: endpointURL) { forecasts in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.forecasts = forecasts
                self.forecastsCollectionView.reloadData()
            }
        }
        forecastsCollectionView.dataSource = self
    }
    
    // MARK: Networking
    
    func requestWeeklyForecast(from endpointURL: URL, completion: @escaping ([ForecastsResponse.Forecast]) -> ()) {
        let forecastsRequest = URLRequest(url: endpointURL)
        
        let _ = URLSession.shared.dataTask(with: forecastsRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data,
                  error == nil else {
                      print("Error downlading data from server: \(error!)")
                      return
                  }
            do {
                let forecastData = try JSONDecoder().decode(ForecastsResponse.self, from: data)
                var forecasts: [ForecastsResponse.Forecast] = []
                for forecast in forecastData.forecasts {
                    forecasts.append(forecast)
                }
                completion(forecasts)
            } catch let error {
                print("Error decoding JSON: \(error)")
            }
        }).resume()
    }
    
    // MARK: CollectionView Data Source Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.forecasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forecastCell", for: indexPath)
        let icon = UIImage(imageLiteralResourceName: forecasts[indexPath.row].icon)
        let iconImageView = UIImageView(image: icon)
        cell.contentView.addSubview(iconImageView)
        
        return cell
    }
}

