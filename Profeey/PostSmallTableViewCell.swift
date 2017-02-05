//
//  PostSmallTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class PostSmallTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var numberOfLikesContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = self.numberOfLikesContainerView.backgroundColor
        super.setSelected(selected, animated: animated)
        if(selected) {
            self.numberOfLikesContainerView.backgroundColor = color
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = self.numberOfLikesContainerView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        if(highlighted) {
            self.numberOfLikesContainerView.backgroundColor = color
        }
    }

}
