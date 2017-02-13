//
//  CaptureNavigationController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 31/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

class CaptureNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = UIColor.white
        self.navigationBar.isTranslucent = false
        self.navigationBar.tintColor = Colors.greyIcons
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.black]
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage(named: "ic_navbar_shadow_resizable")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
