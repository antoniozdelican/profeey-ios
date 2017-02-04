//
//  PRFYNavigationController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 05/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

class PRFYNavigationController: UINavigationController {
    
    fileprivate var currentBanner : UIView?
    fileprivate var bannerHeight: CGFloat = 36.0
    fileprivate var isAnimatingBanner: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Custom Banner
    
    // The banner is placed behind navigationBar and slided with animation below it.
    func showBanner(_  message: String) {
        guard !self.isAnimatingBanner else {
            return
        }
        // Clear it first in case it was already shown.
        self.removeBanner()
        
        var frame: CGRect
        
        // In case on HomeVc, navigationBar is hidden so adjust banner frame.
        if self.navigationBar.isHidden {
            frame = CGRect(x: self.navigationBar.frame.origin.x, y: 0.0 - self.bannerHeight, width:
                self.navigationBar.frame.width, height: self.bannerHeight)
        } else {
            frame = CGRect(x: self.navigationBar.frame.origin.x, y: self.navigationBar.frame.origin.y + self.navigationBar.frame.height - self.bannerHeight, width:
                self.navigationBar.frame.width, height: self.bannerHeight)
        }
        
        print("HERE IT IS navigationBar:")
        print(self.navigationBar.frame)
        
        // Create banner.
        let banner = UIView(frame: frame)
        banner.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.insertSubview(banner, belowSubview: navigationBar)
        
        // Create message.
        let label = UILabel()
        label.text = message
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.sizeToFit()
        label.center = CGPoint(x: banner.bounds.width / 2.0, y: banner.bounds.height / 2.0)
        banner.addSubview(label)
        
        self.currentBanner = banner
        
        // Animate banner from top.
        self.isAnimatingBanner = true
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: {
                if self.navigationBar.isHidden {
                    self.currentBanner?.frame.origin.y = 20.0
                } else {
                    self.currentBanner?.frame.origin.y = self.navigationBar.frame.origin.y + self.navigationBar.frame.height
                }
                
        }, completion: {
            (finished: Bool) in
            // Animate banner behind navigationBar.
            UIView.animate(
                withDuration: 0.2,
                delay: 2.0,
                options: UIViewAnimationOptions.curveEaseIn,
                animations: {
                    if self.navigationBar.isHidden {
                        self.currentBanner?.frame.origin.y = 0.0 - self.bannerHeight
                    } else {
                        self.currentBanner?.frame.origin.y = self.navigationBar.frame.origin.y + self.navigationBar.frame.height - self.bannerHeight
                    }
                    
            }, completion: {
                (finished: Bool) in
                self.isAnimatingBanner = false
                self.removeBanner()
            })
        })
        
        //self.currentBanner = banner
    }

    fileprivate func removeBanner() {
        if self.currentBanner != nil {
            self.currentBanner?.removeFromSuperview()
            self.currentBanner =  nil
        }
    }
}
