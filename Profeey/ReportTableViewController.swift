//
//  ReportTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/02/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

enum ReportType {
    case user
    case post
}

class ReportTableViewController: UITableViewController {
    
    @IBOutlet weak var spamTableViewCell: UITableViewCell!
    @IBOutlet weak var inappropriateTableViewCell: UITableViewCell!
    
    var reportType: ReportType?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)        
        if let reportType = self.reportType {
            switch reportType {
            case .user:
                self.navigationItem.title = "Report User"
            case .post:
                self.navigationItem.title = "Report Post"
            }
        }
        self.tableView.register(UINib(nibName: "ReportTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "reportTableSectionHeader")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ReportConfirmationTableViewController {
            destinationViewController.reportType = self.reportType
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell == self.spamTableViewCell {
            // TODO
            self.performSegue(withIdentifier: "segueToReportConfirmationVc", sender: cell)
        }
        if cell == self.inappropriateTableViewCell {
            // TODO
            self.performSegue(withIdentifier: "segueToReportConfirmationVc", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "reportTableSectionHeader") as? ReportTableSectionHeader
        if let reportType = self.reportType {
            switch reportType {
            case .user:
                header?.titleLabel.text = "Tell us what's wrong with this user."
            case .post:
                header?.titleLabel.text = "Tell us what's wrong with this post."
            }
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    // MARK: IBActions
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}
