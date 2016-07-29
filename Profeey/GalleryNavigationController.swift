//
//  GalleryNavigationController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 29/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class GalleryNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(UIImage(named: "bg_test"), forBarMetrics: .Default)
        self.navigationBar.shadowImage = UIImage(named: "sh_test")
        self.navigationBar.translucent = true
        self.navigationBar.tintColor = Colors.blue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
