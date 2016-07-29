//
//  CaptureNavigationController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 12/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class CaptureNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.translucent = true
        self.navigationBar.tintColor = UIColor.whiteColor()
//        self.view.backgroundColor = UIColor.clearColor()
//        self.navigationBar.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
