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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setMonospacedFont() {
        let features = [
            [
                UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
                UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
            ]
        ]
        let fontDescriptor = UIFont.systemFontOfSize(16.0, weight: UIFontWeightRegular).fontDescriptor().fontDescriptorByAddingAttributes(
            [UIFontDescriptorFeatureSettingsAttribute: features]
        )
        self.yearLabel.font = UIFont(descriptor: fontDescriptor, size: UIFont.systemFontOfSize(16.0, weight: UIFontWeightRegular).pointSize)
    }

}
