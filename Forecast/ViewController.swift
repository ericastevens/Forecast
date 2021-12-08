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
    
    @IBOutlet private weak var todaysForecastView: TodaysForecastView!
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
        view.backgroundColor = .offWhite
        forecastsCollectionView.backgroundColor = .offWhite
        forecastsCollectionView.register(UINib(nibName: "ForecastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "forecastCell")
        loadCollectionViewData()
        configureDiffableDataSource()
        configureCollectionViewLayout()
    }
    
    // MARK: Helper Methods
    
    /// Formats ISO date strings into an `H:mm A` format
    private func format(iso dateString: String, isDate: Bool = false) -> String {
        let formatter = ISO8601DateFormatter()
        var formattedDateString: String = ""
        
        if isDate {
            if let date = formatter.date(from: dateString) {
                let formattedDate = date.formatted(.dateTime)
                let dateString = formattedDate.description
                let dateStringComponents = dateString.components(separatedBy: "/")
                let month = dateStringComponents[0]
                let day = dateStringComponents[1]
                formattedDateString = "\(month)/\(day)"
            }
            return formattedDateString
        } else {
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
    }

    
    /// Configures collection view cell using Dffable Data Source cell provider
    private func configureDiffableDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<Section, Forecast>(collectionView: forecastsCollectionView, cellProvider: { collectionView, indexPath, forecast in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forecastCell", for: indexPath) as! ForecastCollectionViewCell
            
            // Add nuemorphism to cells
            // To-Do: Refactor this, so that it's cleaner
            cell.backgroundColor = .clear
            cell.contentView.frame = cell.bounds
            cell.layer.cornerRadius = 15
            cell.contentView.layer.cornerRadius = 15
            cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            cell.darkShadow.frame = CGRect(origin: cell.bounds.origin, size: CGSize(width: cell.bounds.width * 0.98, height: cell.bounds.height * 0.92))
            cell.darkShadow.cornerRadius = 15
            cell.darkShadow.backgroundColor = UIColor.offWhite.cgColor
            cell.darkShadow.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
            cell.darkShadow.shadowOffset = CGSize(width: 5, height: 5)
            cell.darkShadow.shadowOpacity = 1
            cell.darkShadow.shadowRadius = 15
            cell.layer.insertSublayer(cell.darkShadow, at: 0)
            cell.lightShadow.frame = CGRect(origin: cell.bounds.origin, size: CGSize(width: cell.bounds.width * 0.98, height: cell.bounds.height * 0.92))
            cell.lightShadow.cornerRadius = 15
            cell.lightShadow.backgroundColor = UIColor.offWhite.cgColor
            cell.lightShadow.shadowColor = UIColor.white.withAlphaComponent(0.9).cgColor
            cell.lightShadow.shadowOffset = CGSize(width: -5, height: -5)
            cell.lightShadow.shadowOpacity = 1
            cell.lightShadow.shadowRadius = 15
            cell.layer.insertSublayer(cell.lightShadow, at: 0)
            
            let icon = UIImage(imageLiteralResourceName: "\(forecast.icon)@2x")
            cell.weatherDescriptionLabel.text = forecast.weather
            cell.sunriseTimeLabel.text = self.format(iso: forecast.sunriseISO)
            cell.sunsetTimeLabel.text = self.format(iso: forecast.sunsetISO)
            cell.iconImageView.image = icon
            cell.highTempLabel.text = "\(forecast.maxTempF)\u{00B0}F"
            cell.lowTempLabel.text = "\(forecast.minTempF)\u{00B0}F"
            cell.dateLabel.text = self.format(iso: forecast.dateTimeISO, isDate: true)

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
        // Load xib from bundle
        ForecastCollectionViewCell.commonInit()
        
        // Make request from API for weekly forecast
        guard let endpointURL = URL(string: forecastsEndpoint) else { return }
        requestWeeklyForecast(from: endpointURL) { forecasts in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                var forecasts = forecasts
                
                // Configure Today's Weather View
                let todaysForecast = forecasts.removeFirst()
                self.todaysForecastView.todaysForecastIconImageView.image = UIImage(imageLiteralResourceName: "\(todaysForecast.icon)@2x")
                self.todaysForecastView.todaysWeatherDescription.text = todaysForecast.weather
                self.todaysForecastView.lowTempLabel.text = "\(todaysForecast.minTempF)\u{00B0}F"
                self.todaysForecastView.highTempLabel.text = "\(todaysForecast.maxTempF)\u{00B0}F"
                self.todaysForecastView.sunriseTimeLabel.text = self.format(iso: todaysForecast.sunriseISO)
                self.todaysForecastView.sunsetTimeLabel.text = self.format(iso: todaysForecast.sunsetISO)
  
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

extension UIColor {
    static let offWhite = UIColor.init(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
}

