//
//  ViewController.swift
//  Forecast
//
//  Created by Erica Stevens on 11/27/21.
//

import UIKit

enum Section {
    case forecast
}

class ViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet private weak var forecastsCollectionView: UICollectionView!
    @IBOutlet weak var todaysForecastIconImageView: UIImageView!
    @IBOutlet weak var todaysWeatherDescription: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var sunriseTimeLabel: UILabel!
    @IBOutlet weak var sunsetTimeLabel: UILabel!

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
        configureCollectionViewLayout()
    }
    
    // MARK: Helper Methods
    
    // Formats ISO date strings into an `H:mm A` format
    private func formattedTime(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        var formattedDateString: String = ""
        if let date = formatter.date(from: dateString) {
            let formattedDate = date.formatted(.dateTime)
            let dateString = formattedDate.description
            var dateStringComponents = dateString.components(separatedBy: " ")
            dateStringComponents.removeFirst()
            for component in dateStringComponents {
                formattedDateString.append(contentsOf: component)
            }
        }
        return formattedDateString
    }
    
    /// Configures collection view cell using Dffable Data Source cell provider
    private func configureDiffableDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<Section, Forecast>(collectionView: forecastsCollectionView, cellProvider: { collectionView, indexPath, forecast in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forecastCell", for: indexPath)
            let icon = UIImage(imageLiteralResourceName: "\(forecast.icon)@2x")
            let iconImageView = UIImageView(image: icon)
            cell.contentView.addSubview(iconImageView)
            cell.backgroundColor = .purple
            
            return cell
        })
        forecastsCollectionView.dataSource = diffableDataSource
    }
    
    /// Configures the collection view compostitional layout
    private func configureCollectionViewLayout() {
        let itemSize = NSCollectionLayoutSize(widthDimension:  .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.25))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize:  groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        forecastsCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
    }
    
    /// Adds Forecast Items to DataSourceSnapshot, and applies snapshot of current data set to our diffabable data source, configures Today's Forecase view
    private func loadCollectionViewData() {
        guard let endpointURL = URL(string: forecastsEndpoint) else { return }
        requestWeeklyForecast(from: endpointURL) { forecasts in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                var forecasts = forecasts
                
                // Configure Today's Weather View
                let todaysForecast = forecasts.removeFirst()
                self.todaysForecastIconImageView.image = UIImage(imageLiteralResourceName: "\(todaysForecast.icon)@2x")
                self.todaysWeatherDescription.text = todaysForecast.weather
                self.lowTempLabel.text = "\(todaysForecast.minTempF)\u{00B0}F"
                self.highTempLabel.text = "\(todaysForecast.maxTempF)\u{00B0}F"
                self.sunriseTimeLabel.text = self.formattedTime(from: todaysForecast.sunriseISO)
                self.sunsetTimeLabel.text = self.formattedTime(from: todaysForecast.sunsetISO)
  
                // Configure and apply snapshots to data source
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

