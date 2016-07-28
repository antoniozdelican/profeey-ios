//
//  ProfessionsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 13/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol ItemsDidSelectRowDelegate {
    func didSelectRow(item: String)
}

class ItemsTableViewController: UITableViewController {
    
    private var itemsArray: [String] = []
    var itemsDidSelectRowDelegate: ItemsDidSelectRowDelegate?
    
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
        return self.itemsArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellItem", forIndexPath: indexPath) as! ItemTableViewCell
        cell.itemLabel.text = self.itemsArray[indexPath.row]
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // Trigger delegate.
        self.itemsDidSelectRowDelegate?.didSelectRow(self.itemsArray[indexPath.row])
        // Clear tableView.
        self.filterItemsForSearchText("")
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: Filter
    
    private func filterItemsForSearchText(searchText: String) {
        let trimmedText = searchText.trimm()
        // Should skip "" empty string.
        if !trimmedText.isEmpty {
            //self.scanProfessions(trimmedText)
            // Set first row as searched text.
            if !self.itemsArray.isEmpty {
                self.itemsArray[0] = trimmedText
            } else {
                self.itemsArray.insert(trimmedText, atIndex: 0)
            }
        } else {
            self.itemsArray = []
        }
        self.tableView.reloadData()
    }
}

extension ItemsTableViewController: ItemTextFieldDelegate {
    
    // Parent VC is responsible for providing textField.
    func textFieldChanged(searchText: String) {
        self.filterItemsForSearchText(searchText)
    }
    
}
