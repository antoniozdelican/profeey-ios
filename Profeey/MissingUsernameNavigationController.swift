//
//  MissingUsernameNavigationController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 16/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

/*
 This gets shown (as modal) if user doesn't have username in DynamoDB.
 This can only happen during Onboarding in between SignUpVc and UsernameVc (if user quits the app).
*/

class MissingUsernameNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.barTintColor = Colors.turquoise
        self.navigationBar.tintColor = UIColor.white
//        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightMedium)]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
    
}
