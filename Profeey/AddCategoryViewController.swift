//
//  AddCategoryViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB

protocol AddCategoryDelegate {
    func addCategory(category: Category)
}

// While searching user can add category that not yet exists.
protocol CustomCategoryNameDelegate {
    func addCustomCategoryname(customCategoryName: String?)
}

class AddCategoryViewController: UIViewController {
    
    @IBOutlet weak var addCategoryTextField: UITextField!
    
    var addCategoryDelegate: AddCategoryDelegate?
    private var searchCategoriesDelegate: SearchCategoriesDelegate?
    private var customCategoryNameDelegate: CustomCategoryNameDelegate?
    private var searchedCategories: [Category] = []

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
            self.searchCategoriesDelegate = destinationViewController
            self.customCategoryNameDelegate = destinationViewController
            destinationViewController.addCategoryDelegate = self.addCategoryDelegate
            destinationViewController.scrollViewDelegate = self
        }
    }
    
    // MARK: IBActions
    
    @IBAction func addCategoryTextFieldChanged(sender: AnyObject) {
        guard let text = self.addCategoryTextField.text else {
            return
        }
        let searchText = text.trimm()
        if searchText.isEmpty {
            self.searchCategoriesDelegate?.toggleSearchCategories([], isSearching: false)
            self.customCategoryNameDelegate?.addCustomCategoryname(nil)
        } else {
            self.scanCategoriesByCategoryName(searchText)
            self.customCategoryNameDelegate?.addCustomCategoryname(searchText)
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: AWS
    
    private func scanCategoriesByCategoryName(searchText: String) {
        let searchCategoryName = searchText.lowercaseString
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.searchCategoriesDelegate?.toggleSearchCategories([], isSearching: true)
        PRFYDynamoDBManager.defaultDynamoDBManager().scanCategoriesByCategoryNameDynamoDB(searchCategoryName, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("scanCategoriesByCategoryName error: \(error)")
                    self.searchCategoriesDelegate?.toggleSearchCategories([], isSearching: false)
                } else {
                    if let awsCategories = response?.items as? [AWSCategory] {
                        
                        // Clear for fresh search.
                        self.searchedCategories = []
                        for awsCategory in awsCategories {
                            let category = Category(categoryName: awsCategory._categoryName, numberOfPosts: awsCategory._numberOfPosts)
                            self.searchedCategories.append(category)
                        }
                        self.searchCategoriesDelegate?.toggleSearchCategories(self.searchedCategories, isSearching: false)
                    }
                }
            })
        })
    }
}

extension AddCategoryViewController: ScrollViewDelegate {
    
    func scrollViewWillBeginDragging() {
        self.addCategoryTextField.resignFirstResponder()
    }
}
