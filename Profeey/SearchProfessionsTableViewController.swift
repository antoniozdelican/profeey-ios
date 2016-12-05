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

protocol SearchProfessionsTableViewControllerDelegate {
    func professionsTableViewWillBeginDragging()
}

class SearchProfessionsTableViewController: UITableViewController {
    
    var searchProfessionsTableViewControllerDelegate: SearchProfessionsTableViewControllerDelegate?
    fileprivate var popularProfessions: [Profession] = []
    fileprivate var regularProfessions: [Profession] = []
    fileprivate var isSearchingPopularProfessions: Bool = false
    fileprivate var isSearchingRegularProfessions: Bool = false
    fileprivate var isShowingPopularProfessions: Bool = true
    
    fileprivate var isLocationActive: Bool = false
    fileprivate var locationName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "SearchTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchTableSectionHeader")
        
        self.isShowingPopularProfessions = true
        self.isSearchingPopularProfessions = true
        self.getAllProfessions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfessionTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.profession = self.isShowingPopularProfessions ? self.popularProfessions[indexPath.row] : self.regularProfessions[indexPath.row]
            destinationViewController.isLocationActive = self.isLocationActive
            destinationViewController.locationName = self.locationName
        }
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            guard self.isShowingPopularProfessions else {
                return 0
            }
            if self.isSearchingPopularProfessions {
                return 1
            }
            if self.popularProfessions.count == 0 {
                return 1
            }
            return self.popularProfessions.count
        case 1:
            guard !self.isShowingPopularProfessions else {
                return 0
            }
            if self.isSearchingRegularProfessions {
                return 1
            }
            if self.regularProfessions.count == 0 {
                return 1
            }
            return self.regularProfessions.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearchProfession", for: indexPath) as! SearchProfessionTableViewCell
            let profession = self.popularProfessions[indexPath.row]
            cell.professionNameLabel.text = profession.professionName
            cell.numberOfUsersLabel.text = profession.numberOfUsersString
            return cell
        case 1:
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearchProfession", for: indexPath) as! SearchProfessionTableViewCell
            let profession = self.regularProfessions[indexPath.row]
            cell.professionNameLabel.text = profession.professionName
            cell.numberOfUsersLabel.text = profession.numberOfUsersString
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if cell is NoResultsTableViewCell {
            cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is SearchProfessionTableViewCell {
            self.performSegue(withIdentifier: "segueToProfessionVc", sender: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if self.isSearchingPopularProfessions {
                return 64.0
            }
            if self.popularProfessions.count == 0 {
                return 64.0
            }
            return 72.0
        case 1:
            if self.isSearchingRegularProfessions {
                return 64.0
            }
            if self.regularProfessions.count == 0 {
                return 64.0
            }
            return 72.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if self.isSearchingPopularProfessions {
                return 64.0
            }
            if self.popularProfessions.count == 0 {
                return 64.0
            }
            return 72.0
        case 1:
            if self.isSearchingRegularProfessions {
                return 64.0
            }
            if self.regularProfessions.count == 0 {
                return 64.0
            }
            return 72.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "searchTableSectionHeader") as? SearchTableSectionHeader
            var titleText = "POPULAR"
            if self.isLocationActive, let locationName = self.locationName {
                titleText = titleText + " in \(locationName)"
            }
            header?.titleLabel.text = titleText
            return header
        case 1:
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "searchTableSectionHeader") as? SearchTableSectionHeader
            var titleText = "BEST MATCHES"
            if self.isLocationActive, let locationName = self.locationName {
                titleText = titleText + " in \(locationName)"
            }
            header?.titleLabel.text = titleText
            return header
        default:
            return UIView()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            guard self.isShowingPopularProfessions else {
                return 0.0
            }
            return 32.0
        case 1:
            guard !self.isShowingPopularProfessions else {
                return 0.0
            }
            return 32.0
        default:
            return 0.0
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchProfessionsTableViewControllerDelegate?.professionsTableViewWillBeginDragging()
    }
    
    // MARK: AWS
    
    fileprivate func getAllProfessions() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYCloudSearchProxyClient.defaultClient().getAllProfessions().continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingPopularProfessions = false
                if let error = task.error {
                    print("getAllProfessions error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let cloudSearchProfessionsResult = task.result as? PRFYCloudSearchProfessionsResult, let cloudSearchProfessions = cloudSearchProfessionsResult.professions else {
                        self.tableView.reloadData()
                        return
                    }
                    for cloudSearchProfession in cloudSearchProfessions {
                        let profession = Profession(professionName: cloudSearchProfession.professionName, numberOfUsers: cloudSearchProfession.numberOfUsers)
                        self.popularProfessions.append(profession)
                    }
                    self.tableView.reloadData()
                }
            })
            return nil
        })
    }
    
    fileprivate func getProfessions(_ namePrefix: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYCloudSearchProxyClient.defaultClient().getProfessions(namePrefix: namePrefix).continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingRegularProfessions = false
                if let error = task.error {
                    print("getProfessions error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let cloudSearchProfessionsResult = task.result as? PRFYCloudSearchProfessionsResult, let cloudSearchProfessions = cloudSearchProfessionsResult.professions else {
                        self.tableView.reloadData()
                        return
                    }
                    // Clear old.
                    self.regularProfessions = []
                    for cloudSearchProfession in cloudSearchProfessions {
                        let profession = Profession(professionName: cloudSearchProfession.professionName, numberOfUsers: cloudSearchProfession.numberOfUsers)
                        self.regularProfessions.append(profession)
                    }
                    self.tableView.reloadData()
                }
            })
            return nil
        })
    }
}

extension SearchProfessionsTableViewController: SearchProfessionsDelegate {
    
    func addLocation(_ locationName: String) {
        self.locationName = locationName
        self.isLocationActive = true
        self.tableView.reloadData()
    }
    
    func removeLocation() {
        self.locationName = nil
        self.isLocationActive = false
        self.tableView.reloadData()
    }
    
    func searchBarTextChanged(_ searchText: String) {
        if searchText.trimm().isEmpty {
            self.isShowingPopularProfessions = true
            // Clear old.
            self.regularProfessions = []
            self.isSearchingRegularProfessions = false
            self.tableView.reloadData()
        } else {
            self.isShowingPopularProfessions = false
            // Clear old.
            self.regularProfessions = []
            self.isSearchingRegularProfessions = true
            self.tableView.reloadData()
            // Start search.
            self.getProfessions(searchText)
            
            // TODO filter local professions.
        }
    }
    
    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint.zero, animated: true)
    }
}
