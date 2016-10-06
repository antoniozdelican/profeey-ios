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
    
    override func attach(to vc: UIViewController!, withFrame frame: CGRect) {
        vc.addChildViewController(self)
        self.view.frame = frame
        vc.view.insertSubview(self.view, at: 0)
        self.didMove(toParentViewController: vc)
    }
    
    func setCustomFocusBox() {
        let focusBox = CALayer()
        focusBox.cornerRadius = 4.0
        focusBox.bounds = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
        focusBox.borderWidth = 4.0
        focusBox.borderColor = UIColor.white.cgColor
        focusBox.opacity = 0.0
        self.view.layer.addSublayer(focusBox)
        
        let focusBoxAnimation = CABasicAnimation(keyPath: "opacity")
        focusBoxAnimation.duration = 0.75
        focusBoxAnimation.autoreverses = false
        focusBoxAnimation.repeatCount = 0.0
        focusBoxAnimation.fromValue = NSNumber(value: 1.0 as Float)
        focusBoxAnimation.toValue = NSNumber(value: 0.0 as Float)
        
        self.alterFocusBox(focusBox, animation: focusBoxAnimation)
    }
    
}
