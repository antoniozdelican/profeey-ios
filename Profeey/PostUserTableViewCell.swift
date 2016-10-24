//
//  PostUserTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol PostUserTableViewCellDelegate {
    func expandButtonTapped(_ button: UIButton)
}

class PostUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var preferredUsernameLabel: UILabel!
    @IBOutlet weak var professionNameLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    
    var postUserTableViewCellDelegate: PostUserTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 20.0
        self.profilePicImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func expandButtonTapped(_ sender: AnyObject) {
        guard let button = sender as? UIButton else {
            return
        }
        self.postUserTableViewCellDelegate?.expandButtonTapped(button)
    }

}
