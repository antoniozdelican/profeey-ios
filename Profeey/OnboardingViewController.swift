//
//  OnboardingViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.configureButtons()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureButtons() {
        self.facebookButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.normal)
        self.facebookButton.setBackgroundImage(UIImage(named: "btn_white_active_resizable"), for: UIControlState.highlighted)
        self.facebookButton.setTitleColor(Colors.turquoise, for: UIControlState.normal)
        self.signUpButton.setBackgroundImage(UIImage(named: "btn_white_resizable"), for: UIControlState.normal)
        self.signUpButton.setBackgroundImage(UIImage(named: "btn_white_resizable"), for: UIControlState.highlighted)
        
        self.termsButton.setAttributedTitle(NSAttributedString(string: "Terms", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue, NSForegroundColorAttributeName: UIColor.white]), for: UIControlState.normal)
        self.privacyPolicyButton.setAttributedTitle(NSAttributedString(string: "Privacy and Policy.", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue, NSForegroundColorAttributeName: UIColor.white]), for: UIControlState.normal)
        self.logInButton.setAttributedTitle(NSAttributedString(string: "Log in.", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue, NSForegroundColorAttributeName: UIColor.white]), for: UIControlState.normal)
    }
}
