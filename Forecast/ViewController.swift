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
// Add thorough code documentation
// Practice unit testing
// NEXT: Move to DiffableDataSource

enum Section {
    case forecast
}

class ViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet private weak var forecastsCollectionView: UICollectionView!
    
    // MARK: Properties
    
    private var snapshot = NSDiffableDataSourceSnapshot<Section, Forecast>()
    private var diffableDataSource: UICollectionViewDiffableDataSource<Section, Forecast>?
    
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
        configureDiffableDataSource()
    }
    
    // MARK: Helper Methods
    
    /// Configures collection view cell with using Dffable Data Source configurations
    private func configureDiffableDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<Section, Forecast>(collectionView: forecastsCollectionView, cellProvider: { collectionView, indexPath, forecast in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forecastCell", for: indexPath)
            let icon = UIImage(imageLiteralResourceName: forecast.icon)
            let iconImageView = UIImageView(image: icon)
            cell.contentView.addSubview(iconImageView)
            
            return cell
        })
        forecastsCollectionView.dataSource = diffableDataSource
    }
    
    /// Configures the collection view as a group list type
    private func configureCollectionViewLayout() {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        forecastsCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: config)
    }
    
    /// Adds Forecast Items to DataSourceSnapshot, and applies snapshot of current data set to our diffabable data source
    private func loadCollectionViewData() {
        guard let endpointURL = URL(string: forecastsEndpoint) else { return }
        requestWeeklyForecast(from: endpointURL) { forecasts in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.snapshot.appendSections([Section.forecast])
                self.snapshot.appendItems(forecasts, toSection: .forecast)
                self.diffableDataSource?.apply(self.snapshot)
            }
        }
    }
    
    // MARK: Networking
    
    /// Loads 7-day orecast data from Aeries API, completion contains array of Forecast objects
    private func requestWeeklyForecast(from endpointURL: URL, completion: @escaping ([Forecast]) -> ()) {
        let forecastsRequest = URLRequest(url: endpointURL)
        
        URLSession.shared.dataTask(with: forecastsRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data,
                  error == nil else {
                      print("Error downlading data from server: \(error!)")
                      return
                  }
            do {
                let forecastData = try JSONDecoder().decode(ForecastsResponse.self, from: data)
                var forecasts: [Forecast] = []
                for forecast in forecastData.forecasts {
                    forecasts.append(forecast)
                }
                completion(forecasts)
            } catch let error {
                print("Error decoding JSON: \(error)")
            }
        }).resume()
    }
}

