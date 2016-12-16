//
//  OnboardingNavigationController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class OnboardingNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.barTintColor = Colors.turquoise
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
}

//extension OnboardingNavigationController: AWSCognitoIdentityPasswordAuthentication {
//    
//    func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
//        // Do nothing.
//    }
//    
//    func didCompleteStepWithError(_ error: Error?) {
//        // Do nothing.
//    }
//}
