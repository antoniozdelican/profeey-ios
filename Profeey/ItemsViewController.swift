//
//  EditProfessionsViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol EditItemsDelegate {
    func itemsUpdated(items: [String]?, itemType: ItemType?)
}

protocol ItemTextFieldDelegate {
    func textFieldChanged(searchText: String)
}

protocol ItemsAddDelegate {
    func add(item: String)
}

// This Vc (and its children) are re-used for different item types.
enum ItemType {
    case Profession
    case Category
    case User
}

class ItemsViewController: UIViewController {
    
    @IBOutlet weak var addItemTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var itemsLabel: UILabel!
    
    var items: [String]?
    var itemsArray: [String] = []
    var delegate: EditItemsDelegate?
    var itemTextFieldDelegate: ItemTextFieldDelegate?
    var itemsAddDelegate: ItemsAddDelegate?
    var itemType: ItemType?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add items into array if there are some(not nil).
        if let items = self.items {
            self.itemsArray = items
        }
        self.addItemTextField.addTarget(self, action: #selector(ItemsViewController.addItemTextFieldChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        // Determine which item type.
        if let itemType = self.itemType {
            switch itemType {
            case .Profession:
                self.navigationItem.title = "Professions"
                self.saveButton.title = "Save"
                self.itemsLabel.text = "PROFESSIONS"
                self.addItemTextField.placeholder = "Add profession"
            case .Category:
                self.navigationItem.title = "Categories"
                self.saveButton.title = "Done"
                self.itemsLabel.text = "CATEGORIES"
                self.addItemTextField.placeholder = "Add category"
            case .User:
                self.navigationItem.title = "Recommend"
                self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.green]
                self.saveButton.title = "Done"
                self.itemsLabel.text = "PEOPLE"
                self.addItemTextField.placeholder = "Search people"
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addItemTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.addItemTextField.resignFirstResponder()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if let itemType = self.itemType where itemType == .Profession {
            return false
        } else {
            return true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? ItemsCollectionViewController {
            destinationViewController.items = self.items
            // Add item to collection view delegate.
            self.itemsAddDelegate = destinationViewController
            // Set remove delegate.
            destinationViewController.itemsRemoveDelegate = self
            destinationViewController.itemType = self.itemType
        }
        if let destinationViewController = segue.destinationViewController as? ItemsTableViewController {
            // Set textField delegate.
            self.itemTextFieldDelegate = destinationViewController
            // Set didSelectRow delegate.
            destinationViewController.itemsDidSelectRowDelegate = self
        }
    }
    
    // MARK: Tappers
    
    func addItemTextFieldChanged(sender: UITextField) {
        guard let searchText = sender.text else {
            return
        }
        self.itemTextFieldDelegate?.textFieldChanged(searchText)
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        if self.itemType == ItemType.Profession {
            self.setProfessions()
        } else {
            self.setOthers()
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: AWS
    
    private func setProfessions() {
        // Set nil if empty to comply with DynamoDB!
        self.items = (self.itemsArray.isEmpty ? nil : self.itemsArray)
        FullScreenIndicator.show()
        AWSRemoteService.defaultRemoteService().saveUserProfessions(self.items, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                FullScreenIndicator.hide()
                if let error = task.error {
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    if self.presentedViewController == nil {
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                } else {
                    // Cache locally.
                    LocalService.setProfessionsLocal(self.items)
                    // Inform delegate.
                    self.delegate?.itemsUpdated(self.items, itemType: self.itemType)
                    self.performSegueWithIdentifier("segueUnwindToEditProfileTableVc", sender: self)
                }
            })
            return nil
        })
    }
    
    private func setOthers() {
        self.items = (self.itemsArray.isEmpty ? nil : self.itemsArray)
        // Inform delegate.
        self.delegate?.itemsUpdated(self.items, itemType: self.itemType)
        self.performSegueWithIdentifier("segueUnwindToEditTableVc", sender: self)
    }

}

extension ItemsViewController: ItemsDidSelectRowDelegate {
    
    func didSelectRow(item: String) {
        self.addItemTextField.text = ""
        self.itemsAddDelegate?.add(item)
        self.itemsArray.insert(item, atIndex: 0)
    }
}

extension ItemsViewController: ItemsRemoveDelegate {
    
    func removeAtIndex(itemIndex: Int) {
        self.itemsArray.removeAtIndex(itemIndex)
    }
}
