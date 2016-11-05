//
//  PostButtonsTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol PostButtonsTableViewCellDelegate {
    func likeButtonTapped(_ button: UIButton)
    func commentButtonTapped(_ button: UIButton)
    func numberOfLikesButtonTapped(_ button: UIButton)
    func numberOfCommentsButtonTapped(_ button: UIButton)
}

class PostButtonsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var numberOfLikesButton: UIButton!
    @IBOutlet weak var numberOfCommentsButton: UIButton!
    
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
        self.numberOfCommentsButton.titleLabel?.font = UIFont(descriptor: fontDescriptor, size: UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightRegular).pointSize)
    }
    
    func setSelectedLikeButton() {
        self.likeButton.setImage(UIImage(named: "ic_heart_red"), for: UIControlState())
    }
    
    func setUnselectedLikeButton() {
        self.likeButton.setImage(UIImage(named: "ic_heart_grey"), for: UIControlState())
    }
    
    @IBAction func likeButtonTapped(_ sender: AnyObject) {
        guard let button = sender as? UIButton else {
            return
        }
        self.postButtonsTableViewCellDelegate?.likeButtonTapped(button)
    }
    
    @IBAction func commentButtonTapped(_ sender: AnyObject) {
        guard let button = sender as? UIButton else {
            return
        }
        self.postButtonsTableViewCellDelegate?.commentButtonTapped(button)
    }
    
    @IBAction func numberOfLikesButtonTapped(_ sender: AnyObject) {
        guard let button = sender as? UIButton else {
            return
        }
        self.postButtonsTableViewCellDelegate?.numberOfLikesButtonTapped(button)
    }
    
    @IBAction func numberOfCommentsButtonTapped(_ sender: AnyObject) {
        guard let button = sender as? UIButton else {
            return
        }
        self.postButtonsTableViewCellDelegate?.numberOfCommentsButtonTapped(button)
    }

}
