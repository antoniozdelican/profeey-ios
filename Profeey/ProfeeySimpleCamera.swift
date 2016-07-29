//
//  ProfeeySimpleCamera.swift
//  Profeey
//
//  Created by Antonio Zdelican on 19/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

// This class adds customization over LLSimpleCamera library

import UIKit

class ProfeeySimpleCamera: LLSimpleCamera {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomFocusBox()
    }
    
    override func attachToViewController(vc: UIViewController!, withFrame frame: CGRect) {
        vc.addChildViewController(self)
        self.view.frame = frame
        vc.view.insertSubview(self.view, atIndex: 0)
        self.didMoveToParentViewController(vc)
    }
    
    func setCustomFocusBox() {
        let focusBox = CALayer()
        focusBox.cornerRadius = 4.0
        focusBox.bounds = CGRectMake(0.0, 0.0, 80.0, 80.0)
        focusBox.borderWidth = 4.0
        focusBox.borderColor = UIColor.whiteColor().CGColor
        focusBox.opacity = 0.0
        self.view.layer.addSublayer(focusBox)
        
        let focusBoxAnimation = CABasicAnimation(keyPath: "opacity")
        focusBoxAnimation.duration = 0.75
        focusBoxAnimation.autoreverses = false
        focusBoxAnimation.repeatCount = 0.0
        focusBoxAnimation.fromValue = NSNumber(float: 1.0)
        focusBoxAnimation.toValue = NSNumber(float: 0.0)
        
        self.alterFocusBox(focusBox, animation: focusBoxAnimation)
    }
    
}
