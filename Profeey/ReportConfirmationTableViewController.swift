//
//  ReportConfirmationTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/02/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

class ReportConfirmationTableViewController: UITableViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var headerMessageLabel: UILabel!
    @IBOutlet weak var thanksMessageLabel: UILabel!
    
    var reportType: ReportType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.doneButton?.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
        if let reportType = self.reportType {
            switch reportType {
            case .user:
                self.navigationItem.title = "Report User"
            case .post:
                self.navigationItem.title = "Report Post"
            }
        }
        self.headerMessageLabel.text = "Your report has been submitted."
        self.thanksMessageLabel.text = "Thanks for helping us making Profeey a safe place for everybody."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDelegate
    
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
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}
