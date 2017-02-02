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
        self.facebookButton.setTitleColor(Colors.turquoise.withAlphaComponent(0.2), for: UIControlState.highlighted)
        self.facebookButton.adjustsImageWhenHighlighted = false
        self.signUpButton.setBackgroundImage(UIImage(named: "btn_white_borders_resizable"), for: UIControlState.normal)
        self.signUpButton.setBackgroundImage(UIImage(named: "btn_white_borders_resizable"), for: UIControlState.highlighted)
        self.signUpButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.signUpButton.setTitleColor(UIColor.white.withAlphaComponent(0.2), for: UIControlState.highlighted)
        
        self.termsButton.setAttributedTitle(NSAttributedString(string: "Terms of Service", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue, NSForegroundColorAttributeName: UIColor.white]), for: UIControlState.normal)
        self.privacyPolicyButton.setAttributedTitle(NSAttributedString(string: "Privacy and Policy.", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue, NSForegroundColorAttributeName: UIColor.white]), for: UIControlState.normal)
        self.logInButton.setAttributedTitle(NSAttributedString(string: "Log in.", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue, NSForegroundColorAttributeName: UIColor.white]), for: UIControlState.normal)
    }
    
    // MARK: IBActions
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        UIView.transition(
            with: self.facebookButton,
            duration: 0.2,
            options: .transitionCrossDissolve,
            animations: {
                self.facebookButton.isHighlighted = true
        },
            completion: nil)
        let alertController = self.getSimpleAlertWithTitle("Profeey Beta is not on Facebook yet", message: "We're not on Facebook yet, but will be soon! Please use our normal Sign Up.", cancelButtonTitle: "Got it!")
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        UIView.transition(
            with: self.signUpButton,
            duration: 0.2,
            options: .transitionCrossDissolve,
            animations: {
                self.signUpButton.isHighlighted = true
        },
            completion: nil)
    }
    
    @IBAction func termsButtonTapped(_ sender: Any) {
        guard let termsUrl = URL(string: PRFYTermsUrl) else {
            return
        }
        UIApplication.shared.openURL(termsUrl)
    }
    
    @IBAction func privacyPolicyButtonTapped(_ sender: Any) {
        guard let privacyPolicyUrl = URL(string: PRFYPrivacyPolicyUrl) else {
            return
        }
        UIApplication.shared.openURL(privacyPolicyUrl)
    }
    
}
