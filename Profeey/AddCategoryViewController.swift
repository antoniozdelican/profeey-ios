//
//  AddCategoryViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol AddCategoryTextFieldDelegate {
    func textFieldChanged(text: String)
}

protocol AddCategoryDelegate {
    func addCategory(category: String)
}

class AddCategoryViewController: UIViewController {
    
    @IBOutlet weak var addCategoryTextField: UITextField!
    var addCategoryTextFieldDelegate: AddCategoryTextFieldDelegate?
    var addCategoryDelegate: AddCategoryDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addCategoryTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.addCategoryTextField.resignFirstResponder()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? CategoriesTableViewController {
            self.addCategoryTextFieldDelegate = destinationViewController
            destinationViewController.addCategoryDelegate = self.addCategoryDelegate
            destinationViewController.scrollViewDelegate = self
        }
    }
    
    // MARK: IBActions
    
    @IBAction func addCategoryTextFieldChanged(sender: AnyObject) {
        guard let categoryText = self.addCategoryTextField.text else {
            return
        }
        self.addCategoryTextFieldDelegate?.textFieldChanged(categoryText)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension AddCategoryViewController: ScrollViewDelegate {
    
    func scrollViewWillBeginDragging() {
        self.addCategoryTextField.resignFirstResponder()
    }
}
