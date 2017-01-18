//
//  ConversationTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var preferredUsernameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var unseenConversationView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        self.unseenConversationView.layer.cornerRadius = 2.5
    }

    // Preserve subviews color.
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = self.unseenConversationView.backgroundColor
        super.setSelected(selected, animated: animated)
        if(selected) {
            self.unseenConversationView.backgroundColor = color
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = self.unseenConversationView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        if(highlighted) {
            self.unseenConversationView.backgroundColor = color
        }
    }

}
