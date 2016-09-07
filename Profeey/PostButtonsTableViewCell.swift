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
    @IBOutlet weak var numberOfLikesButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setSelectedLikeButton() {
        self.likeButton.setImage(UIImage(named: "ic_like_blue_big_selected"), forState: UIControlState.Normal)
    }
    
    func setUnselectedLikeButton() {
        self.likeButton.setImage(UIImage(named: "ic_like_blue_big"), forState: UIControlState.Normal)
    }

}
