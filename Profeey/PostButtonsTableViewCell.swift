//
//  PostButtonsTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol PostButtonsTableViewCellDelegate {
    func likeButtonTapped(indexPath: IndexPath?)
    func numberOfLikesButtonTapped(indexPath: IndexPath?)
}

class PostButtonsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var numberOfLikesButton: UIButton!
    
    var indexPath: IndexPath?
    var postButtonsTableViewCellDelegate: PostButtonsTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setMonospacedFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // Using monospaced for number of likes for smooth increment/decrement.
    fileprivate func setMonospacedFont() {
        let features = [
            [
                UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
                UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
            ]
        ]
        let fontDescriptor = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightRegular).fontDescriptor.addingAttributes(
            [UIFontDescriptorFeatureSettingsAttribute: features]
        )
        self.numberOfLikesButton.titleLabel?.font = UIFont(descriptor: fontDescriptor, size: UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightRegular).pointSize)
    }
    
    func setSelectedLikeButton() {
        self.likeButton.setImage(UIImage(named: "ic_heart_red"), for: UIControlState())
    }
    
    func setUnselectedLikeButton() {
        self.likeButton.setImage(UIImage(named: "ic_heart_grey"), for: UIControlState())
    }
    
    @IBAction func likeButtonTapped(_ sender: AnyObject) {
        self.postButtonsTableViewCellDelegate?.likeButtonTapped(indexPath: self.indexPath)
    }
    
    @IBAction func numberOfLikesButtonTapped(_ sender: AnyObject) {
        self.postButtonsTableViewCellDelegate?.numberOfLikesButtonTapped(indexPath: self.indexPath)
    }
    

}
