//
//  NoResultsRequestTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 28/02/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

protocol NoResultsRequestTableViewCellDelegate: class {
    func requestButtonTapped()
}

class NoResultsRequestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var noResultsMessageLabel: UILabel!
    @IBOutlet weak var requestButton: UIButton!
    
    weak var noResultsRequestTableViewCellDelegate: NoResultsRequestTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.requestButton.setBackgroundImage(UIImage(named: "btn_follow_resizable"), for: UIControlState.normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setProfessionButton() {
        UIView.performWithoutAnimation {
            self.requestButton.setTitle("Request", for: UIControlState.normal)
            self.requestButton.layoutIfNeeded()
        }
    }
    
    func setSkillButton() {
        UIView.performWithoutAnimation {
            self.requestButton.setTitle("Request", for: UIControlState.normal)
            self.requestButton.layoutIfNeeded()
        }
    }
    
    // MARK: IBActions
    
    @IBAction func requestButtonTapped(_ sender: AnyObject) {
        self.noResultsRequestTableViewCellDelegate?.requestButtonTapped()
    }

}
