//
//  SearchProfessionsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 10/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol ProfessionsDidSelectRowDelegate {
    func didSelectRow(profession: String)
}

class SearchProfessionsTableViewController: UITableViewController {
    
    private var professionsArray: [String] = []
    var professionsDidSelectRowDelegate: ProfessionsDidSelectRowDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = Colors.grey
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.professionsArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellProfession", forIndexPath: indexPath) as! ProfessionTableViewCell
        cell.professionLabel.text = self.professionsArray[indexPath.row]
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // Trigger delegate.
        self.professionsDidSelectRowDelegate?.didSelectRow(self.professionsArray[indexPath.row])
        // Clear tableView.
        self.filterProfessionsForSearchText("")
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: Filter
    
    private func filterProfessionsForSearchText(searchText: String) {
        let trimmedText = searchText.trimm()
        // Should skip "" empty string.
        if !trimmedText.isEmpty {
            //self.scanProfessions(trimmedText)
            // Set first row as searched text.
            if !self.professionsArray.isEmpty {
                self.professionsArray[0] = trimmedText
            } else {
                self.professionsArray.insert(trimmedText, atIndex: 0)
            }
        } else {
            self.professionsArray = []
        }
        self.tableView.reloadData()
    }
}

extension SearchProfessionsTableViewController: ProfessionsTextFieldDelegate {
    
    // Parent VC is responsible for providing textField.
    func textFieldChanged(searchText: String) {
        self.filterProfessionsForSearchText(searchText)
    }

}
