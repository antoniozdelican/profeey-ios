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
    
    @IBOutlet weak var headerMessageLabel: UILabel!
    @IBOutlet weak var spamTableViewCell: UITableViewCell!
    @IBOutlet weak var inappropriateTableViewCell: UITableViewCell!
    
    var reportType: ReportType?
    var userId: String?
    var postId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)        
        if let reportType = self.reportType {
            switch reportType {
            case .user:
                self.navigationItem.title = "Report User"
                self.headerMessageLabel.text = "Tell us what's wrong with this user:"
            case .post:
                self.navigationItem.title = "Report Post"
                self.headerMessageLabel.text = "Tell us what's wrong with this post:"
            }
        }
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
        
        // TODO
        var userInfo: [String: Any] = [:]
        if let postId = self.postId {
            userInfo["postId"] = postId
        }
        if cell == self.spamTableViewCell {
            // TODO
            self.performSegue(withIdentifier: "segueToReportConfirmationVc", sender: cell)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: CreateReportNotificationKey), object: self, userInfo: userInfo)
        }
        if cell == self.inappropriateTableViewCell {
            // TODO
            self.performSegue(withIdentifier: "segueToReportConfirmationVc", sender: cell)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: CreateReportNotificationKey), object: self, userInfo: userInfo)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        }
        return 52.0
    }
    
    // MARK: IBActions
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}
