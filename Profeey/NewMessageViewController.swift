//
//  NewMessageViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit

protocol NewMessageViewControllerDelegate: class {
    func searchTextFieldChanged(_ text: String)
}

class NewMessageViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    
    fileprivate var newMessageViewControllerDelegate: NewMessageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? NewMessageTableViewController {
            destinationViewController.newMessageTableViewControllerDelegate = self
            self.newMessageViewControllerDelegate = destinationViewController
        }
    }
    
    // MARK: IBActions
    
    @IBAction func searchTextFieldChanged(_ sender: AnyObject) {
        guard let text = self.searchTextField.text else {
            return
        }
        self.newMessageViewControllerDelegate?.searchTextFieldChanged(text)
    }

}

extension NewMessageViewController: NewMessageTableViewControllerDelegate {
    
    func tableViewWillBeginDragging() {
        self.searchTextField.resignFirstResponder()
    }
}
