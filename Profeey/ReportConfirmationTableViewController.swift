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
        self.tableView.register(UINib(nibName: "ReportTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "reportTableSectionHeader")
        
        self.thanksMessageLabel.text = "Thanks for helping us making Profeey a safe place for everybody."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "reportTableSectionHeader") as? ReportTableSectionHeader
        header?.titleLabel.text = "Your issue has been reported."
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    // MARK: IBActions
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}
