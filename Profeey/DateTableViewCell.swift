//
//  DateTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 19/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class DateTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    fileprivate func setMonospacedFont() {
        let features = [
            [
                UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
                UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
            ]
        ]
        let fontDescriptor = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightRegular).fontDescriptor.addingAttributes(
            [UIFontDescriptorFeatureSettingsAttribute: features]
        )
        self.yearLabel.font = UIFont(descriptor: fontDescriptor, size: UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightRegular).pointSize)
    }

}
