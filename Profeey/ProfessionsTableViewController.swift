//
//  ProfessionsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol ProfessionsDidSelectRowDelegate {
    func didSelectRow(profession: String)
}

class ProfessionsTableViewController: UITableViewController {
    
    private var professions: [String] = []
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return professions.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellProfession", forIndexPath: indexPath) as! ProfessionTableViewCell
        cell.professionLabel.text = professions[indexPath.row]
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // Trigger delegate.
        self.professionsDidSelectRowDelegate?.didSelectRow(self.professions[indexPath.row])
        // Clear tableView.
        self.filterItemsForSearchText("")
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: Filter
    
    private func filterItemsForSearchText(searchText: String) {
        let trimmedText = searchText.trimm()
        if !trimmedText.isEmpty {
            // Set first row as searched text.
            if !self.professions.isEmpty {
                self.professions[0] = trimmedText
            } else {
                self.professions.insert(trimmedText, atIndex: 0)
            }
        } else {
            self.professions = []
        }
        self.tableView.reloadData()
    }
}

extension ProfessionsTableViewController: ProfessionsTextFieldDelegate {
    
    func textFieldChanged(searchText: String) {
        self.filterItemsForSearchText(searchText)
    }
}
