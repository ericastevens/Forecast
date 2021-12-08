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
    
    var darkShadow = CALayer()
    var lightShadow = CALayer()
    
    override func prepareForReuse() {
        iconImageView.image = nil
        darkShadow.removeFromSuperlayer()
        lightShadow.removeFromSuperlayer()
    }
    
    class func commonInit() {
        Bundle.main.loadNibNamed("ForecastCollectionViewCell", owner: self, options: nil)
    }
}
