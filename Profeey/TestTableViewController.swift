//
//  TestTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class TestTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0)
        //self.titleTableViewCell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, self.view.bounds.width)
        //self.titleTableViewCell.layoutMargins = UIEdgeInsetsZero
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.usernameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //self.usernameTextField.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }

}
