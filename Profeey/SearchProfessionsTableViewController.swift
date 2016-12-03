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

//protocol SearchProfessionsTableViewControllerDelegate {
//    func didSelectProfession(_ indexPath: IndexPath)
//}

protocol SearchProfessionsTableViewControllerDelegate {
    func professionsTableViewWillBeginDragging()
}

class SearchProfessionsTableViewController: UITableViewController {
    
    var searchProfessionsTableViewControllerDelegate: SearchProfessionsTableViewControllerDelegate?
    fileprivate var professions: [Profession] = []
    //fileprivate var showAllProfessions: Bool = true
    fileprivate var isSearchingProfessions: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "SearchTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchTableSectionHeader")
        
        self.isSearchingProfessions = true
        self.scanProfessions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfessionTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.profession = self.professions[indexPath.row]
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
//            self.searchProfessionsTableViewControllerDelegate?.didSelectProfession(indexPath)
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
        header?.titleLabel.text = "POPULAR in Zagreb, Croatia"
        //header?.titleLabel.text = self.showAllProfessions ? "POPULAR" : "BEST MATCHES"
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
    
    fileprivate func scanProfessions() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanProfessionsDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingProfessions = false
                //self.searchProfessionsDelegate?.isSearchingProfessions(false)
                if let error = error {
                    print("scanProfessions error: \(error)")
                    self.tableView.reloadData()
                    //self.searchProfessionsDelegate?.showProfessions(self.professions, showAllProfessions: true)
                } else {
                    guard let awsProfessions = response?.items as? [AWSProfession] else {
                        self.tableView.reloadData()
                        //self.searchProfessionsDelegate?.showProfessions(self.professions, showAllProfessions: true)
                        return
                    }
                    for awsProfession in awsProfessions {
                        let profession = Profession(professionName: awsProfession._professionName, numberOfUsers: awsProfession._numberOfUsers)
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
        })
    }
}

//extension SearchProfessionsTableViewController: SearchProfessionsDelegate {
//    
//    func isSearchingProfessions(_ isSearching: Bool) {
//        self.isSearchingProfessions = isSearching
//        self.tableView.reloadData()
//    }
//    
//    func showProfessions(_ professions: [Profession], showAllProfessions: Bool) {
//        self.professions = professions
//        self.showAllProfessions = showAllProfessions
//        self.tableView.reloadData()
//    }
//}
