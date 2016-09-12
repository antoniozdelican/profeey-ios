//
//  ProfessionsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB

class ProfessionsTableViewController: UITableViewController {

    @IBOutlet weak var professionTextField: UITextField!
    
    private var professions: [Profession] = []
    private var popularProfessions: [Profession] = []
    var professionName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let professionName = self.professionName {
            self.professionTextField.text = professionName
            self.scanProfessionsByProfessionName(professionName)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.professionTextField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let text = self.professionTextField.text else {
            return 0
        }
        return text.isEmpty ? self.popularProfessions.count : self.professions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let text = self.professionTextField.text else {
            return UITableViewCell()
        }
        let searchText = text.trimm()
        let cell = tableView.dequeueReusableCellWithIdentifier("cellProfession", forIndexPath: indexPath) as! ProfessionTableViewCell
        let profession = searchText.isEmpty ? self.popularProfessions[indexPath.row] : self.professions[indexPath.row]
        cell.professionNameLabel.text = profession.professionName
        cell.numberOfUsersLabel.text = profession.numberOfUsersString
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let text = self.professionTextField.text else {
            return nil
        }
        let searchText = text.trimm()
        let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader") as! HeaderTableViewCell
        cell.headerTitle.text = searchText.isEmpty ? "POPULAR" : "BEST MATCHES"
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is ProfessionTableViewCell {
            // Update profession and unwind to EditProfileVc
            self.professionName = self.professions[indexPath.row].professionName
            self.performSegueWithIdentifier("segueUnwindToEditProfileVc", sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.professionTextField.resignFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        // Update profession and unwind to EditProfileVc
        self.professionName = self.professionTextField.text?.trimm()
        self.performSegueWithIdentifier("segueUnwindToEditProfileVc", sender: self)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func professionTextFieldChanged(sender: AnyObject) {
        guard let text = self.professionTextField.text else {
            return
        }
        let searchText = text.trimm()
        if searchText.isEmpty {
            // Show popularProfessions.
            self.tableView.reloadData()
        } else {
            // Do the search!
            self.scanProfessionsByProfessionName(searchText)
        }
    }
    
    // MARK: AWS
    
    private func scanProfessionsByProfessionName(searchText: String) {
        let searchProfessionName = searchText.lowercaseString
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanProfessionsByProfessionNameDynamoDB(searchProfessionName, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("scanProfessionsByProfessionName error: \(error)")
                } else {
                    if let awsProfessions = response?.items as? [AWSProfession] {
                        var searchedProfessions: [Profession] = []
                        for awsProfession in awsProfessions {
                            let profession = Profession(professionName: awsProfession._professionName, numberOfUsers: awsProfession._numberOfUsers)
                            searchedProfessions.append(profession)
                        }
                        self.professions = searchedProfessions
                        self.tableView.reloadData()
                    }
                }
            })
        })
        
    }
    
}
