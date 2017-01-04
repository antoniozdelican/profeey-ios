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
    fileprivate var isSearchingProfessions: Bool {
        return self.isSearchingPopularProfessions
    }
    
    fileprivate var popularProfessions: [Profession] = []
    fileprivate var isSearchingPopularProfessions: Bool = false
    fileprivate var isShowingPopularProfessions: Bool = true
    
    fileprivate var isLocationActive: Bool = false
    fileprivate var location: Location?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "SearchTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchTableSectionHeader")
        
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
            destinationViewController.isLocationActive = self.isLocationActive
            destinationViewController.location = self.location
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
            // TODO update text.
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
            self.performSegue(withIdentifier: "segueToProfessionVc", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isSearchingProfessions {
            return 64.0
        }
        if self.professions.count == 0 {
            return 64.0
        }
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
        if self.isLocationActive, let locationName = self.location?.locationName {
            titleText = titleText + " in \(locationName)"
        }
        header?.titleLabel.text = titleText
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
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
                self.isSearchingPopularProfessions = false
                if let error = error {
                    print("scanProfessions error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsProfessions = response?.items as? [AWSProfession] else {
                        self.tableView.reloadData()
                        return
                    }
                    self.popularProfessions = []
                    for awsProfession in awsProfessions {
                        let profession = Profession(professionName: awsProfession._professionName, numberOfUsers: awsProfession._numberOfUsers)
                        self.popularProfessions.append(profession)
                    }
                    self.popularProfessions = self.sortProfessions(self.popularProfessions)
                    self.professions = self.popularProfessions
                    self.tableView.reloadData()
                }
            })
        })
    }
    
    fileprivate func queryLocationProfessions(_ locationId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryLocationProfessions(locationId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingPopularProfessions = false
                if let error = error {
                    print("queryLocationProfessions error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsProfessionLocations = response?.items as? [AWSProfessionLocation] else {
                        self.tableView.reloadData()
                        return
                    }
                    self.popularProfessions = []
                    for awsProfessionLocation in awsProfessionLocations {
                        let profession = Profession(professionName: awsProfessionLocation._professionName, numberOfUsers: awsProfessionLocation._numberOfUsers)
                        self.popularProfessions.append(profession)
                    }
                    self.popularProfessions = self.sortProfessions(self.popularProfessions)
                    self.professions = self.popularProfessions
                    self.tableView.reloadData()
                }
            })
        })
    } 
}

extension SearchProfessionsTableViewController: SearchProfessionsDelegate {
    
    func addLocation(_ location: Location) {
        guard let locationId = location.locationId else {
            return
        }
        self.location = location
        self.isLocationActive = true
        // Clear old.
        self.professions = []
        self.isSearchingPopularProfessions = true
        self.tableView.reloadData()
        self.queryLocationProfessions(locationId)
    }
    
    func removeLocation() {
        self.location = nil
        self.isLocationActive = false
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
