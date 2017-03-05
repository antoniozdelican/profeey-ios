//
//  SearchProfessionsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

protocol SearchProfessionsTableViewControllerDelegate: class {
    func professionsTableViewWillBeginDragging()
}

class SearchProfessionsTableViewController: UITableViewController {
    
    weak var searchProfessionsTableViewControllerDelegate: SearchProfessionsTableViewControllerDelegate?
    
    fileprivate var professions: [Profession] = []
    fileprivate var isSearchingProfessions: Bool {
        return self.isSearchingPopularProfessions
    }
    
    fileprivate var popularProfessions: [Profession] = []
    fileprivate var isSearchingPopularProfessions: Bool = false
    fileprivate var isShowingPopularProfessions: Bool = true
    
    fileprivate var isSchoolActive: Bool = false
    fileprivate var school: School?
    
    fileprivate var noNetworkConnection: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "SearchTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchTableSectionHeader")
        
        // Adjust school.
        self.isShowingPopularProfessions = true
        self.isSearchingPopularProfessions = true
        self.scanProfessions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfessionTableViewController,
            let cell = sender as? SearchProfessionTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.profession = self.professions[indexPath.row]
            destinationViewController.isSchoolActive = self.isSchoolActive
            destinationViewController.school = self.school
        }
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.noNetworkConnection {
            return 1
        }
        if self.isSearchingProfessions {
            return 1
        }
        if self.professions.count == 0 {
            return 1
        }
        return self.professions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.noNetworkConnection {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoNetwork", for: indexPath) as! NoNetworkTableViewCell
            return cell
        }
        if self.isSearchingProfessions {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        }
        if self.professions.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearchProfession", for: indexPath) as! SearchProfessionTableViewCell
        let profession = self.professions[indexPath.row]
        cell.professionNameLabel.text = profession.professionNameWhitespace
        cell.numberOfUsersLabel.text = profession.numberOfUsersString
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if cell is NoResultsTableViewCell {
            cell.separatorInset = UIEdgeInsetsMake(0.0, 12.0, 0.0, 0.0)
        }
        if cell is NoNetworkTableViewCell {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is SearchProfessionTableViewCell {
            self.performSegue(withIdentifier: "segueToProfessionVc", sender: cell)
        }
        if cell is NoNetworkTableViewCell {
            // Query.
            self.noNetworkConnection = false
            self.isSearchingPopularProfessions = true
            self.tableView.reloadData()
            if self.isSchoolActive, let schoolId = self.school?.schoolId {
                self.querySchoolProfessions(schoolId)
            } else {
                self.scanProfessions()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.noNetworkConnection {
            return 112.0
        }
        if self.isSearchingProfessions {
            return 64.0
        }
        if self.professions.count == 0 {
            return 64.0
        }
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.noNetworkConnection {
            return 112.0
        }
        if self.isSearchingProfessions {
            return 64.0
        }
        if self.professions.count == 0 {
            return 64.0
        }
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "searchTableSectionHeader") as? SearchTableSectionHeader
        var titleText = self.isShowingPopularProfessions ? "POPULAR" : "BEST MATCHES"
        if self.isSchoolActive, let schoolName = self.school?.schoolName {
            titleText = titleText + " at \(schoolName)"
        }
        header?.titleLabel.text = titleText
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        guard !self.isSearchingProfessions else {
            self.refreshControl?.endRefreshing()
            return
        }
        // Query.
        if self.isSchoolActive, let schoolId = self.school?.schoolId {
            self.querySchoolProfessions(schoolId)
        } else {
            self.scanProfessions()
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchProfessionsTableViewControllerDelegate?.professionsTableViewWillBeginDragging()
    }
    
    // MARK: Helpers
    
    fileprivate func filterProfessions(_ namePrefix: String) {
        let regularProfessions = self.popularProfessions.filter({
            (profession: Profession) in
            if let searchProfessionName = profession.professionName?.lowercased(), searchProfessionName.hasPrefix(namePrefix.lowercased()) {
                return true
            } else {
                return false
            }
        })
        self.professions = self.sortProfessions(regularProfessions)
        self.tableView.reloadData()
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
                guard error == nil else {
                    print("scanProfessions error: \(error!)")
                    self.isSearchingPopularProfessions = false
                    self.refreshControl?.endRefreshing()
                    if (error as! NSError).code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                    }
                    self.tableView.reloadData()
                    return
                }
                self.popularProfessions = []
                if let awsProfessions = response?.items as? [AWSProfession] {
                    for awsProfession in awsProfessions {
                        let profession = Profession(professionName: awsProfession._professionName, numberOfUsers: awsProfession._numberOfUsers)
                        self.popularProfessions.append(profession)
                    }
                }
                // Set popular professions.
                self.popularProfessions = self.sortProfessions(self.popularProfessions)
                self.professions = self.popularProfessions
                
                // Reset flags and animations that were initiated.
                self.isSearchingPopularProfessions = false
                self.refreshControl?.endRefreshing()
                self.noNetworkConnection = false
                
                // Reload tableView.
                self.tableView.reloadData()
            })
        })
    }
    
    fileprivate func querySchoolProfessions(_ schoolId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().querySchoolProfessions(schoolId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("querySchoolProfessions error: \(error!)")
                    self.isSearchingPopularProfessions = false
                    self.refreshControl?.endRefreshing()
                    if (error as! NSError).code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                    }
                    self.tableView.reloadData()
                    return
                }
                self.popularProfessions = []
                if let awsProfessionSchools = response?.items as? [AWSProfessionSchool] {
                    for awsProfessionSchool in awsProfessionSchools {
                        let profession = Profession(professionName: awsProfessionSchool._professionName, numberOfUsers: awsProfessionSchool._numberOfUsers)
                        self.popularProfessions.append(profession)
                    }
                }
                // Set popular professions.
                self.popularProfessions = self.sortProfessions(self.popularProfessions)
                self.professions = self.popularProfessions
                
                // Reset flags and animations that were initiated.
                self.isSearchingPopularProfessions = false
                self.refreshControl?.endRefreshing()
                self.noNetworkConnection = false
                
                // Reload tableView.
                self.tableView.reloadData()
            })
        })
    } 
}

extension SearchProfessionsTableViewController: SearchProfessionsDelegate {
    
    func addSchool(_ school: School) {
        guard let schoolId = school.schoolId else {
            return
        }
        self.school = school
        self.isSchoolActive = true
        // Clear old.
        self.professions = []
        self.isSearchingPopularProfessions = true
        self.tableView.reloadData()
        self.querySchoolProfessions(schoolId)
    }
    
    func removeSchool() {
        self.school = nil
        self.isSchoolActive = false
        // Clear old.
        self.professions = []
        self.isSearchingPopularProfessions = true
        self.tableView.reloadData()
        self.scanProfessions()
    }
    
    func searchBarTextChanged(_ searchText: String) {
        let professionName = searchText.trimm()
        if professionName.isEmpty {
            self.isShowingPopularProfessions = true
            self.professions = self.popularProfessions
            self.tableView.reloadData()
        } else {
            self.isShowingPopularProfessions = false
            self.filterProfessions(professionName)
        }
    }
    
    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint.zero, animated: true)
    }
}
