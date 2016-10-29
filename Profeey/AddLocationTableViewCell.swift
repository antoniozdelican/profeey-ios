//
//  AddLocationTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol AddLocationTableViewCellDelegate {
    func clearButtonTapped(_ button: UIButton)
}

class AddLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    var addLocationTableViewCellDelegate: AddLocationTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setIncativeLocation() {
        self.locationImageView.image = UIImage(named: "ic_location_disabled")
        self.locationNameLabel.textColor = Colors.greyDark
        self.clearButton.isHidden = true
    }
    
    func setActiveLocation() {
        self.locationImageView.image = UIImage(named: "ic_location_black")
        self.locationNameLabel.textColor = Colors.black
        self.clearButton.isHidden = false
    }
    
    // MARK: IBActions

    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        guard let button = sender as? UIButton else {
            return
        }
        self.addLocationTableViewCellDelegate?.clearButtonTapped(button)
    }
}
