//
//  HomeEmptyFeedView.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol HomeEmptyFeedViewDelegate {
    func discoverButtonTapped()
}

class HomeEmptyFeedView: UIView {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var discoverButton: UIButton!
    
    var homeEmptyFeedViewDelegate: HomeEmptyFeedViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textLabel.text = "There are no posts on your feed. Discover profeeys and see what they are up to."
    }

    // MARK: IBActions
    
    @IBAction func discoverButtonTapped(_ sender: AnyObject) {
        self.homeEmptyFeedViewDelegate?.discoverButtonTapped()
    }

}
