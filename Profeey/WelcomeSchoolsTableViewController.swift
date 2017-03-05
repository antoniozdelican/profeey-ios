//
//  WelcomeSchoolsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 05/03/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class WelcomeSchoolsTableViewController: UITableViewController {
    
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var addSchoolTextField: UITextField!
    
    fileprivate var popularSchools: [School] = []
    fileprivate var regularSchools: [School] = []
    fileprivate var isSearchingPopularSchools: Bool = false
    fileprivate var isSearchingRegularSchools: Bool = false
    fileprivate var isShowingPopularSchools: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        self.tableView.register(UINib(nibName: "TableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "tableSectionHeader")
        self.configureNavigationBar()
        
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    // MARK: Configuration
    
    fileprivate func configureNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = Colors.greyIcons
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.black, NSFontAttributeName: UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightMedium)]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "ic_navbar_shadow_resizable")
        self.skipButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
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
            let school = self.isShowingPopularSchools ? self.popularSchools[indexPath.row] : self.regularSchools[indexPath.row]
            if let schoolId = school.schoolId, let schoolName = school.schoolName {
                self.view.endEditing(true)
                self.saveUserSchool(schoolId, schoolName: schoolName)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "tableSectionHeader") as? TableSectionHeader
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
    
    // MARK: IBActions
    
    @IBAction func addSchoolTextFieldChanged(_ sender: AnyObject) {
        guard let text = self.addSchoolTextField.text else {
            return
        }
        let schoolName = text.trimm().replacingOccurrences(of: "_", with: " ")
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
            // Start search for existing schools.
            self.filterSchools(schoolName)
        }
    }
    
    @IBAction func skipButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        let alertController = UIAlertController(title: "School not selected", message: "Are you sure you want to skip selecting your school? Some friends might be there already.", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "Skip", style: UIAlertActionStyle.default, handler: {
            (alertAction: UIAlertAction) in
            self.performSegue(withIdentifier: "segueToWelcomeProfessionsVc", sender: self)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Helpers
    
    fileprivate func filterSchools(_ name: String) {
        // Clear old.
        self.regularSchools = []
        self.regularSchools = self.popularSchools.filter({
            (school: School) in
            if let searchSchoolName = school.schoolName?.lowercased(), searchSchoolName.contains(name.lowercased()) {
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
    
    fileprivate func saveUserSchool(_ schoolId: String, schoolName: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        PRFYDynamoDBManager.defaultDynamoDBManager().updateUserSchoolDynamoDB(schoolId, schoolName: schoolName, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("saveUserSchool error: \(error)")
                    let alertController = UIAlertController(title: "Save school failed", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: "segueToWelcomeProfessionsVc", sender: self)
                }
            })
            return nil
        })
    }
}
