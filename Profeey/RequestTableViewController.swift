//
//  RequestTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 28/02/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

enum RequestType: String {
    case profession = "PROFESSION"
    case skill = "SKILL"
}

class RequestTableViewController: UITableViewController {

    @IBOutlet weak var headerMessageLabel: UILabel!
    @IBOutlet weak var requestTextLabel: UILabel!
    @IBOutlet weak var requestButton: UIButton!
    
    var requestType: RequestType = RequestType.profession
    var userId: String?
    var requestedText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TEST
        self.requestedText = "Handicrafter"
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = "Request \(self.requestType.rawValue.lowercased().capitalized)"
        self.headerMessageLabel.text = "Your \(self.requestType.rawValue.lowercased()) still doesn't exist on Profeey. But no worries, you can request it from our team."
        self.requestTextLabel.text = self.requestedText
        self.requestButton.setBackgroundImage(UIImage(named: "btn_follow_resizable"), for: UIControlState.normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? RequestConfirmationTableViewController {
            destinationViewController.requestType = self.requestType
            destinationViewController.userId = self.userId
            destinationViewController.requestedText = self.requestedText
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = self.tableView.cellForRow(at: indexPath)
        if indexPath.row == 1 {
            self.performSegue(withIdentifier: "segueToRequestConfirmationVc", sender: cell)
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
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
