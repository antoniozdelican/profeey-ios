//
//  OnboardingViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class OnboardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension OnboardingViewController: AWSCognitoIdentityPasswordAuthentication {
    
    func getPasswordAuthenticationDetails(authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource) {
        // Do nothing.
    }
    
    func didCompletePasswordAuthenticationStepWithError(error: NSError) {
        // Do nothing.
    }
}
