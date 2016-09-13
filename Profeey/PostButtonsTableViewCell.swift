//
//  PostButtonsTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class PostButtonsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var likeButton: UIButton!
    
    // Invisible button.
    @IBOutlet weak var numberOfLikesButton: UIButton!
    @IBOutlet weak var numberOfLikesLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setMonospacedFont()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // Using monospaced for number of likes for smooth increment/decrement.
    private func setMonospacedFont() {
        let features = [
            [
                UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
                UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
            ]
        ]
        let fontDescriptor = UIFont.systemFontOfSize(14.0, weight: UIFontWeightRegular).fontDescriptor().fontDescriptorByAddingAttributes(
            [UIFontDescriptorFeatureSettingsAttribute: features]
        )
        self.numberOfLikesLabel.font = UIFont(descriptor: fontDescriptor, size: UIFont.systemFontOfSize(14.0, weight: UIFontWeightRegular).pointSize)
    }
    
    func setSelectedLikeButton() {
        self.likeButton.setImage(UIImage(named: "ic_heart_blue_big_selected"), forState: UIControlState.Normal)
    }
    
    func setUnselectedLikeButton() {
        self.likeButton.setImage(UIImage(named: "ic_heart_blue_big"), forState: UIControlState.Normal)
    }

}
