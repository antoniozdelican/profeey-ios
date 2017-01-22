//
//  HomeNoNetworkView.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

protocol HomeNoNetworkViewDelegate: class {
    func noNetworkViewTapped()
}

class HomeNoNetworkView: UIView {
    
    weak var homeNoNetworkViewDelegate: HomeNoNetworkViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.noNetworkViewTapped(_:))))
    }
    
    // MARK: Tappers
    
    func noNetworkViewTapped(_ sender: AnyObject) {
        self.homeNoNetworkViewDelegate?.noNetworkViewTapped()
    }

}
