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
        self.navigationBar.backgroundColor = UIColor.whiteColor()
        self.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationBar.tintColor = Colors.black
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.black]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
