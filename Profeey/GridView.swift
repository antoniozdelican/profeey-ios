//
//  GridView.swift
//  Profeey
//
//  Created by Antonio Zdelican on 30/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class GridView: UIView {

    @IBOutlet weak var firstVerticalLineView: UIView!
    @IBOutlet weak var firstVerticalLineViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondVerticalLineView: UIView!
    @IBOutlet weak var secondVerticalLineViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstHorizontalLineView: UIView!
    @IBOutlet weak var firstHorizontalLineViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondHorizontalLineView: UIView!
    @IBOutlet weak var secondHorizontalLineViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.configureShadows()
    }
    
    // MARK: Configuration
    
    fileprivate func configureConstraints() {
        let lineViewsConstraints: [NSLayoutConstraint] = [self.firstVerticalLineViewWidthConstraint, self.secondVerticalLineViewWidthConstraint, self.firstHorizontalLineViewHeightConstraint, self.secondHorizontalLineViewHeightConstraint]
        for lineViewConstraint in lineViewsConstraints {
            lineViewConstraint.constant = 1.0 / UIScreen.main.scale
        }
    }
    
    fileprivate func configureShadows() {
        let lineViews: [UIView] = [self.firstVerticalLineView, self.secondVerticalLineView, self.firstHorizontalLineView, self.secondHorizontalLineView]
        for lineView in lineViews {
            lineView.layer.masksToBounds = false
            lineView.layer.shadowColor = UIColor.black.cgColor
            lineView.layer.shadowOffset = CGSize.zero
            lineView.layer.shadowOpacity = 0.5
            lineView.layer.shadowRadius = 1
            lineView.layer.shadowPath = UIBezierPath(rect: lineView.bounds).cgPath
        }
    }
}
