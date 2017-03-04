//
//  SchoolsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

protocol SchoolsTableViewControllerDelegate: class {
    func didSelectSchool(_ school: School)
}

class SchoolsTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var schoolName: String?
    weak var schoolsTableViewControllerDelegate: SchoolsTableViewControllerDelegate?
    
    fileprivate var popularSchools: [School] = []
    fileprivate var regularSchools: [School] = []
    fileprivate var isSearchingPopularSchools: Bool = false
    fileprivate var isSearchingRegularSchools: Bool = false
    fileprivate var isShowingPopularSchools: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "SearchTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchTableSectionHeader")
        
        // Configure SearchBar.
        self.searchBar.text = self.schoolName
        self.searchBar.delegate = self
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.backgroundColor = Colors.greyLighter
        
        // Query.
        self.isShowingPopularSchools = true
        self.isSearchingPopularSchools = true
        self.scanSchools()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isShowingPopularSchools {
            if self.isSearchingPopularSchools {
                return 1
            }
            if self.popularSchools.count == 0 {
                return 1
            }
            return self.popularSchools.count
        } else {
            if self.isSearchingRegularSchools {
                return 1
            }
            if self.regularSchools.count == 0 {
                return 1
            }
            return self.regularSchools.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isShowingPopularSchools {
            if self.isSearchingPopularSchools {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                cell.activityIndicator.startAnimating()
                // TODO update text.
                return cell
            }
            if self.popularSchools.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSchool", for: indexPath) as! SchoolTableViewCell
            let school = self.popularSchools[indexPath.row]
            cell.schoolNameLabel.text = school.schoolName
            cell.numberOfUsersLabel.text = school.numberOfUsersString
            return cell
        } else {
            if self.isSearchingRegularSchools {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                cell.activityIndicator.startAnimating()
                // TODO update text.
                return cell
            }
            if self.regularSchools.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSchool", for: indexPath) as! SchoolTableViewCell
            let school = self.regularSchools[indexPath.row]
            cell.schoolNameLabel.text = school.schoolName
            cell.numberOfUsersLabel.text = school.numberOfUsersString
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
        if cell is SchoolTableViewCell {
            let selectedSchool = self.isShowingPopularSchools ? self.popularSchools[indexPath.row] : self.regularSchools[indexPath.row]
            self.schoolsTableViewControllerDelegate?.didSelectSchool(selectedSchool)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "searchTableSectionHeader") as? SearchTableSectionHeader
        header?.titleLabel.text = self.isShowingPopularSchools ? "POPULAR" : "BEST MATCHES"
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helpers
    
    fileprivate func filterSchools(_ namePrefix: String) {
        // Clear old.
        self.regularSchools = []
        self.regularSchools = self.popularSchools.filter({
            (school: School) in
            if let searchSchoolName = school.schoolName?.lowercased(), searchSchoolName.hasPrefix(namePrefix.lowercased()) {
                return true
            } else {
                return false
            }
        })
        self.regularSchools = self.sortSchools(self.regularSchools)
        self.isSearchingRegularSchools = false
        self.tableView.reloadData()
    }
    
    fileprivate func sortSchools(_ schools: [School]) -> [School] {
        return schools.sorted(by: {
            (school1, school2) in
            return school1.numberOfUsersInt > school2.numberOfUsersInt
        })
    }
    
    // MARK: AWS
    
    fileprivate func scanSchools() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanSchoolsDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingPopularSchools = false
                if let error = error {
                    print("scanSchools error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsSchools = response?.items as? [AWSSchool] else {
                        self.tableView.reloadData()
                        return
                    }
                    for awsSchool in awsSchools {
                        let school = School(schoolId: awsSchool._schoolId, schoolName: awsSchool._schoolName, numberOfUsers: awsSchool._numberOfUsers)
                        self.popularSchools.append(school)
                    }
                    self.popularSchools = self.sortSchools(self.popularSchools)
                    self.tableView.reloadData()
                }
            })
        })
    }
}

extension SchoolsTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let schoolName = searchText.trimm()
        if schoolName.isEmpty {
            self.isShowingPopularSchools = true
            // Clear old.
            self.regularSchools = []
            self.isSearchingRegularSchools = false
            self.tableView.reloadData()
        } else {
            self.isShowingPopularSchools = false
            // Clear old.
            self.regularSchools = []
            self.isSearchingRegularSchools = true
            self.tableView.reloadData()
            // Start search.
            self.filterSchools(schoolName)
        }
    }
}
