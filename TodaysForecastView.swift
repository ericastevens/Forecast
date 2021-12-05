//
//  TodaysForecastView.swift
//  Forecast
//
//  Created by Erica Stevens on 12/5/21.
//

import Foundation
import UIKit

class TodaysForecastView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var todaysWeatherDescription: UILabel!
    @IBOutlet weak var sunsetTimeLabel: UILabel!
    @IBOutlet weak var sunriseTimeLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var todaysForecastIconImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        configureContentView()
        setshadow()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TodaysForecastView", owner: self, options: nil)
        addSubview(contentView)
    }
    
    private func configureContentView() {
        self.backgroundColor = .offWhite
        contentView.backgroundColor = .offWhite
        contentView.frame = self.bounds
        self.layer.cornerRadius = 15
        self.contentView.layer.cornerRadius = 15
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    
    private func setshadow() {
        // https://medium.com/@mail2sajalkaushik/swift-creating-custom-neumorphic-view-using-uikit-fe94c60aedc1
        let darkShadow = CALayer()
        let lightShadow = CALayer()
        darkShadow.frame = CGRect(origin: self.bounds.origin, size: CGSize(width: self.bounds.width * 0.95, height: self.bounds.height * 0.85))
        darkShadow.cornerRadius = 15
        darkShadow.backgroundColor = UIColor.offWhite.cgColor
        darkShadow.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        darkShadow.shadowOffset = CGSize(width: 10, height: 10)
        darkShadow.shadowOpacity = 1
        darkShadow.shadowRadius = 15
        self.layer.insertSublayer(darkShadow, at: 0)
        lightShadow.frame = CGRect(origin: self.bounds.origin, size: CGSize(width: self.bounds.width * 0.95, height: self.bounds.height * 0.85))
        lightShadow.cornerRadius = 15
        lightShadow.backgroundColor = UIColor.offWhite.cgColor
        lightShadow.shadowColor = UIColor.white.withAlphaComponent(0.9).cgColor
        lightShadow.shadowOffset = CGSize(width: -15, height: -15)
        lightShadow.shadowOpacity = 1
        lightShadow.shadowRadius = 15
        self.layer.insertSublayer(lightShadow, at: 0)
    }
}
