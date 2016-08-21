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
//        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//        self.navigationBar.shadowImage = UIImage()
//        self.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationBar.tintColor = Colors.black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
