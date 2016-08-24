//
//  EditCategoriesViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 22/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol CategoriesTextFieldDelegate {
    func textFieldChanged(text: String)
}

protocol CategoriesAddDelegate {
    func addCategory(category: String)
}

class EditCategoriesViewController: UIViewController {

    @IBOutlet weak var addCategoryTextField: UITextField!
    
    var oldCategories: [String]?
    var categories: [String] = []
    var categoriesTextFieldDelegate: CategoriesTextFieldDelegate?
    var categoriesAddDelegate: CategoriesAddDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let oldCategories = self.oldCategories {
            self.categories = oldCategories
        }
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
        if let destinationViewController = segue.destinationViewController as? EditCategoriesTableViewController {
            self.categoriesTextFieldDelegate = destinationViewController
            destinationViewController.categoriesTableViewControllerDelegate = self
        }
        if let destinationViewController = segue.destinationViewController as? EditCategoriesCollectionViewController {
            self.categoriesAddDelegate = destinationViewController
            destinationViewController.categoriesCollectionViewControllerDelegate = self
            destinationViewController.oldCategories = self.oldCategories
        }
    }
    
    // MARK: IBActions
    
    @IBAction func addCategoryTextFieldChanged(sender: AnyObject) {
        guard let textField = sender as? UITextField else {
            return
        }
        guard let text = textField.text else {
            return
        }
        self.categoriesTextFieldDelegate?.textFieldChanged(text)
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("segueUnwindToEditPostVc", sender: self)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension EditCategoriesViewController: CategoriesTableViewControllerDelegate {
    
    func scrollViewWillBeginDragging() {
        self.addCategoryTextField.resignFirstResponder()
    }
    
    func didSelectRowAtIndexPath(category: String) {
        self.addCategoryTextField.text = ""
        self.categoriesAddDelegate?.addCategory(category)
        self.categories.insert(category, atIndex: 0)
    }
}

extension EditCategoriesViewController: CategoriesCollectionViewControllerDelegate {
    
    func didSelectItemAtIndexPath(index: Int) {
        self.categories.removeAtIndex(index)
    }
}
