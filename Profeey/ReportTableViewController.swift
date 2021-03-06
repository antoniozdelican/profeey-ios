//
//  ReportTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/02/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

enum ReportType: String {
    case user = "USER"
    case post = "POST"
}

// Not using on DynamoDB, just here.
enum ReportMidType: String {
    case spam = "SPAM"
    case inappropriate = "INAP"
}

enum ReportDetailType: String {
    case spam = "SPAM"
    case spamFakeAccount = "SPAM_FAKE"
    case spamHackedAccount = "SPAM_HACK"
    case inappropriateNudo = "INAP_NUDO"
    case inappropriateHarm = "INAP_HARM"
    case inappropriateIntellectual = "INAP_INTE"
}

class ReportTableViewController: UITableViewController {
    
    var reportType: ReportType = ReportType.post
    var userId: String?
    var postId: String?
    // In case we are reporting user for message or comment.
    var messageId: String?
    var removeMessageDelegate: RemoveMessageDelegate?
    var commentId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = (self.reportType == .user) ? "Report User" : "Report Post"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ReportDetailsTableViewController,
            let cell = sender as? ReportTypeTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            if indexPath.row == 1 {
                destinationViewController.reportMidType = ReportMidType.spam
            }
            if indexPath.row == 2 {
                destinationViewController.reportMidType = ReportMidType.inappropriate
            }
            destinationViewController.userId = self.userId
            destinationViewController.postId = self.postId
            destinationViewController.reportType = self.reportType
            // In case we are reporting user for message or comment.
            destinationViewController.messageId = self.messageId
            destinationViewController.removeMessageDelegate = self.removeMessageDelegate
            destinationViewController.commentId = self.commentId
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellReportHeader", for: indexPath) as! ReportHeaderTableViewCell
            cell.headerMessageLabel.text = (self.reportType == .user) ? "Tell us what's wrong with this user:" : "Tell us what's wrong with this post:"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellReportType", for: indexPath) as! ReportTypeTableViewCell
            cell.reportTypeLabel.text = (self.reportType == .user) ? "They are posting spam" : "It's spam"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellReportType", for: indexPath) as! ReportTypeTableViewCell
            cell.reportTypeLabel.text = (self.reportType == .user) ? "They are being inappropriate" : "It's inappropriate"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.row == 1 {
            self.performSegue(withIdentifier: "segueToReportDetailsVc", sender: cell)
        }
        if indexPath.row == 2 {
            self.performSegue(withIdentifier: "segueToReportDetailsVc", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: IBActions
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}
