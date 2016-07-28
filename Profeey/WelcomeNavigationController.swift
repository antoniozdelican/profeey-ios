//
//  WelcomeNavigationController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class WelcomeNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.translucent = true
        self.navigationBar.tintColor = Colors.blue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
