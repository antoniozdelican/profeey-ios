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
        self.toolbar.tintColor = Colors.black
        self.toolbar.barTintColor = Colors.whiteDark
        self.toolbar.isTranslucent = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
