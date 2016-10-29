//
//  SearchProfessionsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol SearchProfessionsTableViewControllerDelegate {
    func didSelectProfession(_ indexPath: IndexPath)
}

class SearchProfessionsTableViewController: UITableViewController {
    
    var searchScrollDelegate: SearchScrollDelegate?
    var searchProfessionsTableViewControllerDelegate: SearchProfessionsTableViewControllerDelegate?
    fileprivate var professions: [Profession] = []
    fileprivate var showAllProfessions: Bool = true
    fileprivate var isSearchingProfessions: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register custom header.
        self.tableView.register(UINib(nibName: "SearchTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchTableSectionHeader")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is SearchProfessionTableViewCell {
            self.searchProfessionsTableViewControllerDelegate?.didSelectProfession(indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "searchTableSectionHeader") as? SearchTableSectionHeader
        header?.titleLabel.text = self.showAllProfessions ? "POPULAR" : "BEST MATCHES"
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchScrollDelegate?.scrollViewWillBeginDragging()
    }
}

extension SearchProfessionsTableViewController: SearchProfessionsDelegate {
    
    func isSearchingProfessions(_ isSearching: Bool) {
        self.isSearchingProfessions = isSearching
        self.tableView.reloadData()
    }
    
    func showProfessions(_ professions: [Profession], showAllProfessions: Bool) {
        self.professions = professions
        self.showAllProfessions = showAllProfessions
        self.tableView.reloadData()
    }
}
