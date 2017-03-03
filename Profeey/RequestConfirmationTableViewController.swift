//
//  RequestConfirmationTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 28/02/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

class RequestConfirmationTableViewController: UITableViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var confirmationMessageLabel: UILabel!
    @IBOutlet weak var thanksMessageLabel: UILabel!
    
    var requestType: RequestType = RequestType.profession
    var userId: String?
    var requestedText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: IBActions
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
