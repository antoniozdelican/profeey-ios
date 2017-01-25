//
//  ProfessionsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB

protocol ProfessionsTableViewControllerDelegate: class {
    func didSelectProfession(_ professionName: String?)
}

class ProfessionsTableViewController: UITableViewController {
    
    @IBOutlet weak var addProfessionTextField: UITextField!
    
    var professionName: String?
    weak var professionsTableViewControllerDelegate: ProfessionsTableViewControllerDelegate?
    
    fileprivate var popularProfessions: [Profession] = []
    fileprivate var regularProfessions: [Profession] = []
    fileprivate var isSearchingPopularProfessions: Bool = false
    fileprivate var isSearchingRegularProfessions: Bool = false
    fileprivate var isShowingPopularProfessions: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        self.tableView.register(UINib(nibName: "TableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "tableSectionHeader")
        self.addProfessionTextField.text = self.professionName
        
        self.isShowingPopularProfessions = true
        self.isSearchingPopularProfessions = true
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
        if self.isShowingPopularProfessions {
            if self.isSearchingPopularProfessions {
                return 1
            }
            if self.popularProfessions.count == 0 {
                return 1
            }
            return self.popularProfessions.count
        } else {
            if self.isSearchingRegularProfessions {
                return 1
            }
            if self.regularProfessions.count == 0 {
                return 1
            }
            return self.regularProfessions.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isShowingPopularProfessions {
            if self.isSearchingPopularProfessions {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                cell.activityIndicator.startAnimating()
                // TODO update text.
                return cell
            }
            if self.popularProfessions.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfession", for: indexPath) as! ProfessionTableViewCell
            let profession = self.popularProfessions[indexPath.row]
            cell.professionNameLabel.text = profession.professionName
            cell.numberOfUsersLabel.text = profession.numberOfUsersString
            return cell
        } else {
            if self.isSearchingRegularProfessions {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                cell.activityIndicator.startAnimating()
                // TODO update text.
                return cell
            }
            if self.regularProfessions.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfession", for: indexPath) as! ProfessionTableViewCell
            let profession = self.regularProfessions[indexPath.row]
            cell.professionNameLabel.text = profession.professionName
            cell.numberOfUsersLabel.text = profession.numberOfUsersString
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is ProfessionTableViewCell {
            let selectedProfession = self.isShowingPopularProfessions ? self.popularProfessions[indexPath.row] : self.regularProfessions[indexPath.row]
            self.professionsTableViewControllerDelegate?.didSelectProfession(selectedProfession.professionName)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "tableSectionHeader") as? TableSectionHeader
        header?.titleLabel.text = self.isShowingPopularProfessions ? "POPULAR" : "BEST MATCHES"
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func addProfessionTextFieldChanged(_ sender: AnyObject) {
        guard let text = self.addProfessionTextField.text else {
            return
        }
        var professionName = text.trimm()
        professionName = professionName.replacingOccurrences(of: "_", with: " ")
        if professionName.isEmpty {
            self.isShowingPopularProfessions = true
            // Clear old.
            self.regularProfessions = []
            self.isSearchingRegularProfessions = false
            self.tableView.reloadData()
//            UIView.performWithoutAnimation {
//                self.tableView.beginUpdates()
//                self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
//                self.tableView.endUpdates()
//            }
            self.professionName = nil
        } else {
            self.isShowingPopularProfessions = false
            // Clear old.
            self.regularProfessions = []
            self.isSearchingRegularProfessions = true
            self.tableView.reloadData()
//            UIView.performWithoutAnimation {
//                self.tableView.beginUpdates()
//                self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
//                self.tableView.endUpdates()
//            }
            self.professionName = professionName
            // Start search for existing professions.
            self.filterProfessions(professionName)
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        // '_' is unallowed (CloudSearch professionNameId) so replace it with ' ' if user enters it.
        self.professionName = self.professionName?.replacingOccurrences(of: "_", with: " ")
        self.professionsTableViewControllerDelegate?.didSelectProfession(self.professionName)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helpers
    
    fileprivate func filterProfessions(_ namePrefix: String) {
        // Clear old.
        self.regularProfessions = []
        self.regularProfessions = self.popularProfessions.filter({
            (profession: Profession) in
            if let searchProfessionName = profession.professionName?.lowercased(), searchProfessionName.hasPrefix(namePrefix.lowercased()) {
                return true
            } else {
                return false
            }
        })
        self.regularProfessions = self.sortProfessions(self.regularProfessions)
        self.isSearchingRegularProfessions = false
        self.tableView.reloadData()
//        UIView.performWithoutAnimation {
//            self.tableView.beginUpdates()
//            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
//            self.tableView.endUpdates()
//        }
    }
    
    fileprivate func sortProfessions(_ professions: [Profession]) -> [Profession] {
        return professions.sorted(by: {
            (profession1, profession2) in
            return profession1.numberOfUsersInt > profession2.numberOfUsersInt
        })
    }
    
    // MARK: AWS
    
    fileprivate func scanProfessions() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanProfessionsDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingPopularProfessions = false
                if let error = error {
                    print("scanProfessions error: \(error)")
                    self.tableView.reloadData()
//                    UIView.performWithoutAnimation {
//                        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
//                    }
                } else {
                    guard let awsProfessions = response?.items as? [AWSProfession] else {
                        self.tableView.reloadData()
//                        UIView.performWithoutAnimation {
//                            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
//                        }
                        return
                    }
                    for awsProfession in awsProfessions {
                        let profession = Profession(professionName: awsProfession._professionName, numberOfUsers: awsProfession._numberOfUsers)
                        self.popularProfessions.append(profession)
                    }
                    self.popularProfessions = self.sortProfessions(self.popularProfessions)
                    self.tableView.reloadData()
//                    UIView.performWithoutAnimation {
//                        self.tableView.beginUpdates()
//                        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
//                        self.tableView.endUpdates()
//                    }
                }
            })
        })
    }
}
