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
    
    fileprivate var professions: [Profession] = []
    fileprivate var popularProfessions: [Profession] = []
    var professionName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let professionName = self.professionName {
            self.professionTextField.text = professionName
            self.scanProfessionsByProfessionName(professionName)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.professionTextField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let text = self.professionTextField.text else {
            return 0
        }
        return text.isEmpty ? self.popularProfessions.count : self.professions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let text = self.professionTextField.text else {
            return UITableViewCell()
        }
        let searchText = text.trimm()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfession", for: indexPath) as! ProfessionTableViewCell
        let profession = searchText.isEmpty ? self.popularProfessions[(indexPath as NSIndexPath).row] : self.professions[(indexPath as NSIndexPath).row]
        cell.professionNameLabel.text = profession.professionName
        cell.numberOfUsersLabel.text = profession.numberOfUsersString
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let text = self.professionTextField.text else {
            return nil
        }
        let searchText = text.trimm()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! HeaderTableViewCell
        cell.headerTitle.text = searchText.isEmpty ? "POPULAR" : "BEST MATCHES"
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is ProfessionTableViewCell {
            // Update profession and unwind to EditProfileVc
            self.professionName = self.professions[(indexPath as NSIndexPath).row].professionName
            self.performSegue(withIdentifier: "segueUnwindToEditProfileVc", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.professionTextField.resignFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        // Update profession and unwind to EditProfileVc
        self.professionName = self.professionTextField.text?.trimm()
        self.performSegue(withIdentifier: "segueUnwindToEditProfileVc", sender: self)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func professionTextFieldChanged(_ sender: AnyObject) {
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
    
    fileprivate func scanProfessionsByProfessionName(_ searchText: String) {
        let searchProfessionName = searchText.lowercased()
        
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
                    var searchedProfessions: [Profession] = []
                    for awsProfession in awsProfessions {
                        let profession = Profession(professionName: awsProfession._professionName, numberOfUsers: awsProfession._numberOfUsers)
                        searchedProfessions.append(profession)
                    }
                    self.professions = searchedProfessions
                    self.tableView.reloadData()
                }
            })
        })
        
    }
}
