//
//  ForecastCollectionViewCell.swift
//  Forecast
//
//  Created by Erica Stevens on 12/5/21.
//

import Foundation
import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var sunriseTimeLabel: UILabel!
    @IBOutlet weak var sunsetTimeLabel: UILabel!

    override var reuseIdentifier: String? {
        return "forecastCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        print("*******")
    
        print("Icon Image View is nil: \(self.iconImageView == nil)")
//        configureContentView()
//        setshadow()
    }
//
    private func commonInit() {
        Bundle.main.loadNibNamed("ForecastCollectionViewCell", owner: self, options: nil)
//        addSubview(contentView)
    }
}
