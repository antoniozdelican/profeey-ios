//
//  ReportDetailsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/02/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class ReportDetailsTableViewController: UITableViewController {
    
    var reportType: ReportType = ReportType.post
    var reportMidType: ReportMidType?
    var userId: String?
    var postId: String?

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
        if let destinationViewController = segue.destination as? ReportConfirmationTableViewController {
            destinationViewController.reportType = self.reportType
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellReportHeader", for: indexPath) as! ReportHeaderTableViewCell
            cell.headerMessageLabel.text = (self.reportType == .user) ? "What's the reason for reporting this user:" : "What's the reason for reporting this post:"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellReportType", for: indexPath) as! ReportTypeTableViewCell
            if let reportMidType = self.reportMidType {
                switch reportMidType {
                case .spam:
                    cell.reportTypeLabel.text = (self.reportType == .user) ? "They are just posting spam" : "It's just spam"
                case .inappropriate:
                    cell.reportTypeLabel.text = "Nudity or pornography"
                }
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellReportType", for: indexPath) as! ReportTypeTableViewCell
            if let reportMidType = self.reportMidType {
                switch reportMidType {
                case .spam:
                    cell.reportTypeLabel.text = (self.reportType == .user) ? "It's a fake account" : "It's from a fake account"
                case .inappropriate:
                    cell.reportTypeLabel.text = "Violence or harm"
                }
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellReportType", for: indexPath) as! ReportTypeTableViewCell
            if let reportMidType = self.reportMidType {
                switch reportMidType {
                case .spam:
                    cell.reportTypeLabel.text = (self.reportType == .user) ? "It's a hacked account" : "It's from a hacked account"
                case .inappropriate:
                    cell.reportTypeLabel.text = "Intellectual property violation"
                }
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let reportMidType = self.reportMidType {
            if indexPath.row == 1 {
                switch reportMidType {
                case .spam:
                    self.createReport(self.reportType, reportDetailType: ReportDetailType.spam)
                case .inappropriate:
                    self.createReport(self.reportType, reportDetailType: ReportDetailType.inappropriateNudo)
                }
            }
            if indexPath.row == 2 {
                switch reportMidType {
                case .spam:
                    self.createReport(self.reportType, reportDetailType: ReportDetailType.spamFakeAccount)
                case .inappropriate:
                    self.createReport(self.reportType, reportDetailType: ReportDetailType.inappropriateHarm)
                }
            }
            if indexPath.row == 3 {
                switch reportMidType {
                case .spam:
                    self.createReport(self.reportType, reportDetailType: ReportDetailType.spamHackedAccount)
                case .inappropriate:
                    self.createReport(self.reportType, reportDetailType: ReportDetailType.inappropriateIntellectual)
                }
            }
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
    
    // MARK: AWS
    
    fileprivate func createReport(_ reportType: ReportType, reportDetailType: ReportDetailType) {
        guard let reportedUserId = self.userId else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        PRFYDynamoDBManager.defaultDynamoDBManager().createReportDynamoDB(reportedUserId, reportedPostId: self.postId, reportType: reportType, reportDetailType: reportDetailType, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("createReport error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    var userInfo: [String: Any] = ["userId": reportedUserId]
                    if let postId = self.postId {
                        userInfo["postId"] = postId
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: CreateReportNotificationKey), object: self, userInfo: userInfo)
                    self.performSegue(withIdentifier: "segueToReportConfirmationVc", sender: self)
                }
            })
            return nil
        })
    }

}
