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
    fileprivate var professions: [Profession] = []
    //fileprivate var showAllProfessions: Bool = true
    fileprivate var isSearchingProfessions: Bool = false
    
    fileprivate var isLocationActive: Bool = false
    fileprivate var locationName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "SearchTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchTableSectionHeader")
        
        self.isSearchingProfessions = true
        self.getAllProfessions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfessionTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.profession = self.professions[indexPath.row]
            destinationViewController.isLocationActive = self.isLocationActive
            destinationViewController.locationName = self.locationName
        }
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchingProfessions {
            return 1
        }
        if self.professions.count == 0 {
            return 1
        }
        return self.professions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        cell.professionNameLabel.text = profession.professionName
        cell.numberOfUsersLabel.text = profession.numberOfUsersString
        return cell
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
        if self.isSearchingProfessions {
            return 64.0
        }
        if self.professions.count == 0 {
            return 64.0
        }
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isSearchingProfessions {
            return 64.0
        }
        if self.professions.count == 0 {
            return 64.0
        }
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "searchTableSectionHeader") as? SearchTableSectionHeader
        var titleText = "POPULAR"
        if self.isLocationActive, let locationName = self.locationName {
            titleText = titleText + " in \(locationName)"
        }
        header?.titleLabel.text = titleText
//        header?.titleLabel.text = self.showAllUsers ? "POPULAR" : "BEST MATCHES"
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
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
                self.isSearchingProfessions = false
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
                        self.professions.append(profession)
                    }
                    self.tableView.reloadData()
                    
                    // If there is text already in text field, do the filter.
//                    if let searchText = self.searchController?.searchBar.text, !searchText.isEmpty {
//                        self.filterProfessions(searchText)
//                    } else {
//                        self.professions = self.allProfessions
//                        self.searchProfessionsDelegate?.showProfessions(self.professions, showAllProfessions: true)
//                    }
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
}
