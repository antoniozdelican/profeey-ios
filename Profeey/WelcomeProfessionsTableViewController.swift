//
//  WelcomeProfessionsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB

class WelcomeProfessionsTableViewController: UITableViewController {
    
    @IBOutlet weak var addProfessionTextField: UITextField!
    private var recentProfessions: [Profession] = []
    private var searchedProfessions: [Profession] = []
    private var showRecentProfessions: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.scanProfessions()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showRecentProfessions {
            return self.recentProfessions.count
        } else {
            return self.searchedProfessions.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let profession = self.showRecentProfessions ? self.recentProfessions[indexPath.row] : self.searchedProfessions[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cellProfession", forIndexPath: indexPath) as! ProfessionTableViewCell
        cell.professionNameLabel.text = profession.professionName
        cell.numberOfUsersLabel.text = profession.numberOfUsersString
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader") as! HeaderTableViewCell
        cell.headerTitle.text = self.showRecentProfessions ? "RECENT" : "BEST MATCHES"
        cell.contentView.backgroundColor = UIColor.whiteColor()
        return cell.contentView
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            let profession = self.showRecentProfessions ? self.recentProfessions[indexPath.row] : self.searchedProfessions[indexPath.row]
            self.self.addProfessionTextField.text = profession.professionName
            
            // Clear table.
            self.showRecentProfessions = false
            self.searchedProfessions = []
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        guard let text = self.addProfessionTextField.text else {
            return
        }
        let professionName = text.trimm()
        if professionName.isEmpty {
            let alertController = UIAlertController(title: "Empty profession", message: "Are you sure you don't want to pick a profession?", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
                (alertAction: UIAlertAction) in
                self.redirectToMain()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.view.endEditing(true)
            FullScreenIndicator.show()
            self.saveUserProfession(professionName)
        }
    }
    
    
    @IBAction func addProfessionTextFieldChanged(sender: AnyObject) {
        guard let text = self.addProfessionTextField.text else {
            return
        }
        if text.trimm().isEmpty {
            self.showRecentProfessions = true
            self.tableView.reloadData()
        } else {
            self.showRecentProfessions = false
            // Clear searched.
            self.searchedProfessions = []
            self.tableView.reloadData()
            self.scanProfessionsByProfessionName(text)
        }
    }
    
    // MARK: Helpers
    
    private func redirectToMain() {
        guard let window = UIApplication.sharedApplication().keyWindow,
            let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
    
    // MARK: AWS
    
    private func scanProfessions() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanProfessionsDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("scanProfessions error: \(error)")
                } else {
                    guard let awsProfessions = response?.items as? [AWSProfession] else {
                        return
                    }
                    guard awsProfessions.count > 0 else {
                        return
                    }
                    for awsProfession in awsProfessions {
                        let profession = Profession(professionName: awsProfession._professionName, numberOfUsers: awsProfession._numberOfUsers)
                        self.recentProfessions.append(profession)
                    }
                    self.tableView.reloadData()
                    
                }
            })
        })
    }
    
    private func scanProfessionsByProfessionName(professionName: String) {
        let searchProfessionName = professionName.lowercaseString
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanProfessionsByProfessionNameDynamoDB(searchProfessionName, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print("scanProfessionsByProfessionName error: \(error)")
                } else {
                    guard let awsProfessions = response?.items as? [AWSProfession] else {
                        return
                    }
                    guard awsProfessions.count > 0 else {
                        // Clear searched.
                        self.searchedProfessions = []
                        self.tableView.reloadData()
                        return
                    }
                    // Clear searched.
                    self.searchedProfessions = []
                    for awsProfession in awsProfessions {
                        let profession = Profession(professionName: awsProfession._professionName, numberOfUsers: awsProfession._numberOfUsers)
                        self.searchedProfessions.append(profession)
                    }
                    self.tableView.reloadData()
                }
            })
        })
    }
    
    private func saveUserProfession(professionName: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserProfessionDynamoDB(professionName, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = task.error {
                    FullScreenIndicator.hide()
                    print("saveUserProfession error: \(error)")
                    let alertController = UIAlertController(title: "Save profession failed", message: error.userInfo["message"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    FullScreenIndicator.hide()
                    self.redirectToMain()
                }
            })
            return nil
        })
    }
}