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
    fileprivate var recentProfessions: [Profession] = []
    fileprivate var searchedProfessions: [Profession] = []
    fileprivate var showRecentProfessions: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.scanProfessions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showRecentProfessions {
            return self.recentProfessions.count
        } else {
            return self.searchedProfessions.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profession = self.showRecentProfessions ? self.recentProfessions[indexPath.row] : self.searchedProfessions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfession", for: indexPath) as! ProfessionTableViewCell
        cell.professionNameLabel.text = profession.professionName
        cell.numberOfUsersLabel.text = profession.numberOfUsersString
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! HeaderTableViewCell
        cell.headerTitle.text = self.showRecentProfessions ? "RECENT" : "BEST MATCHES"
        cell.contentView.backgroundColor = UIColor.white
        return cell.contentView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let profession = self.showRecentProfessions ? self.recentProfessions[indexPath.row] : self.searchedProfessions[indexPath.row]
            self.addProfessionTextField.text = profession.professionName
            
            // Clear table.
            self.showRecentProfessions = false
            self.searchedProfessions = []
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        guard let text = self.addProfessionTextField.text else {
            return
        }
        let professionName = text.trimm()
        if professionName.isEmpty {
            let alertController = UIAlertController(title: "Empty profession", message: "Are you sure you don't want to pick a profession?", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
                (alertAction: UIAlertAction) in
                self.redirectToMain()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.view.endEditing(true)
            FullScreenIndicator.show()
            self.saveUserProfession(professionName)
        }
    }
    
    
    @IBAction func addProfessionTextFieldChanged(_ sender: AnyObject) {
        guard let text = self.addProfessionTextField.text else {
            return
        }
        let searchText = text.trimm()
        if searchText.isEmpty {
            self.showRecentProfessions = true
            self.tableView.reloadData()
        } else {
            self.showRecentProfessions = false
            // Clear searched.
            self.searchedProfessions = []
            self.tableView.reloadData()
            self.scanProfessionsByProfessionName(searchText)
        }
    }
    
    // MARK: Helpers
    
    fileprivate func redirectToMain() {
        guard let window = UIApplication.shared.keyWindow,
            let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
                return
        }
        window.rootViewController = initialViewController
    }
    
    // MARK: AWS
    
    fileprivate func scanProfessions() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanProfessionsDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
    
    fileprivate func scanProfessionsByProfessionName(_ professionName: String) {
        let searchProfessionName = professionName.lowercased()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanProfessionsByProfessionNameDynamoDB(searchProfessionName, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
    
    fileprivate func saveUserProfession(_ professionName: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserProfessionDynamoDB(professionName, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    FullScreenIndicator.hide()
                    print("saveUserProfession error: \(error)")
                    let alertController = UIAlertController(title: "Save profession failed", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    FullScreenIndicator.hide()
                    self.redirectToMain()
                }
            })
            return nil
        })
    }
}
