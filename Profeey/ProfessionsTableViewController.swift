//
//  ProfessionsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB

protocol ProfessionsTableViewControllerDelegate {
    func didSelectProfession(_ professionName: String?)
}

class ProfessionsTableViewController: UITableViewController {
    
    var professionName: String?
    var professionsTableViewControllerDelegate: ProfessionsTableViewControllerDelegate?
    fileprivate var professions: [Profession] = []
    fileprivate var allProfessions: [Profession] = []
    fileprivate var searchedProfessions: [Profession] = []
    fileprivate var isSearching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        
        self.isSearching = true
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if self.isSearching {
                return 1
            }
            if self.professions.count == 0 {
                return 1
            }
            return self.professions.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellAddProfession", for: indexPath) as! AddProfessionTableViewCell
            if self.professionName != nil {
                cell.addProfessionTextField.text = self.professionName
            }
            cell.addProfessionTableViewCellDelegate = self
            return cell
        case 1:
            if self.isSearching {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                cell.activityIndicator.startAnimating()
                return cell
            }
            if self.professions.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfession", for: indexPath) as! ProfessionTableViewCell
            let profession = self.professions[indexPath.row]
            cell.professionNameLabel.text = profession.professionName
            cell.numberOfUsersLabel.text = profession.numberOfUsersString
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is ProfessionTableViewCell {
            self.professionsTableViewControllerDelegate?.didSelectProfession(self.professions[indexPath.row].professionName)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 52.0
        case 1:
            return 64.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 52.0
        case 1:
            return 64.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1.0
        }
        return 12.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        self.professionsTableViewControllerDelegate?.didSelectProfession(self.professionName)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: AWS
    
    fileprivate func scanProfessions() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanProfessionsDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearching = false
                if let error = error {
                    print("scanProfessions error: \(error)")
                    self.reloadProfessionsSection()
                } else {
                    guard let awsProfessions = response?.items as? [AWSProfession] else {
                        self.reloadProfessionsSection()
                        return
                    }
                    for awsProfession in awsProfessions {
                        let profession = Profession(professionName: awsProfession._professionName, searchProfessionName: awsProfession._searchProfessionName, numberOfUsers: awsProfession._numberOfUsers)
                        self.allProfessions.append(profession)
                    }
                    self.professions = self.allProfessions
                    self.reloadProfessionsSection()
                }
            })
        })
    }
    
    // MARK: Helper
    
    fileprivate func filterProfessions(_ searchText: String) {
        self.searchedProfessions = self.allProfessions.filter({
            (profession: Profession) in
            if let searchProfessionName = profession.searchProfessionName, searchProfessionName.hasPrefix(searchText.lowercased()) {
                return true
            } else {
                return false
            }
        })
        self.professions = self.searchedProfessions
        self.isSearching = false
        self.reloadProfessionsSection()
    }
    
    fileprivate func reloadProfessionsSection () {
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
        }
    }
}

extension ProfessionsTableViewController: AddProfessionTableViewCellDelegate {
    
    func addProfessionTextFieldChanged(_ text: String) {
        let professionName = text.trimm()
        if professionName.isEmpty {
//            self.isSearching = false
            self.professions = self.allProfessions
            self.reloadProfessionsSection()
            self.professionName = nil
        } else {
//            self.isSearching = true
            self.filterProfessions(professionName)
            self.professionName = professionName
        }
    }
}
