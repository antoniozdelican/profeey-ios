//
//  CommentTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol CommentTableViewCellDelegate {
    // A bit different sending entire cell.
    func userTapped(_ cell: CommentTableViewCell)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var preferredUsernameLabel: UILabel!
    @IBOutlet weak var professionNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameStackView: UIStackView!
    
    var commentTableViewCellDelegate: CommentTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        
        let imageViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profilePicImageViewTapped(_:)))
        self.profilePicImageView.addGestureRecognizer(imageViewTapGestureRecognizer)
        let nameStackViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profilePicImageViewTapped(_:)))
        self.nameStackView.addGestureRecognizer(nameStackViewTapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Tappers
    
    @objc fileprivate func profilePicImageViewTapped(_ sender: AnyObject) {
        self.commentTableViewCellDelegate?.userTapped(self)
    }
    
    @objc fileprivate func nameStackViewTapped(_ sender: AnyObject) {
        self.commentTableViewCellDelegate?.userTapped(self)
    }
}
