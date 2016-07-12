//
//  ProfessionsWelcomeTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 13/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol ProfessionsWelcomeProtocol {
    func toggleNextButton(enabled: Bool)
    func addProfession(profession: String)
    func removeProfession(profession: String)
}

class ProfessionsWelcomeTableViewController: UITableViewController {

    @IBOutlet weak var addProfessionTextField: UITextField!
    @IBOutlet weak var addProfessionButton: UIButton!
    
    var professions: [String] = []
    var delegate: ProfessionsWelcomeProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addProfessionTextField.addTarget(self, action: #selector(ProfessionsWelcomeTableViewController.addProfessionTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.addProfessionButton.addTarget(self, action: #selector(ProfessionsWelcomeTableViewController.addProfessionButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.addProfessionButton.hidden = true
        
        self.tableView.delaysContentTouches = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addProfessionTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.addProfessionTextField.resignFirstResponder()
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.addProfessionTextField.resignFirstResponder()
    }

    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return professions.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellProfession", forIndexPath: indexPath) as! ProfessionWelcomeTableViewCell
        cell.professionLabel.text = professions[indexPath.row]
        cell.removeProfessionButton.addTarget(self, action: #selector(ProfessionsWelcomeTableViewController.removeProfessionButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85.0
    }
    
    // MARK: Tappers
    
    func addProfessionTextFieldDidChange(sender: UITextField) {
        guard let profession = self.addProfessionTextField.text else {
            return
        }
        let trimmedProfession = profession.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        // Toggle button.
        self.addProfessionButton.hidden = trimmedProfession.isEmpty
    }
    
    func addProfessionButtonTapped(sender: UIButton) {
        guard let profession = self.addProfessionTextField.text else {
            return
        }
        // Add profession.
        let index = 0
        self.professions.insert(profession, atIndex: index)
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        // Clear text field and button.
        self.addProfessionTextField.text = ""
        self.addProfessionButton.hidden = true
        // Toggle next button.
        self.delegate.toggleNextButton(true)
        // Add profession to parent.
        self.delegate.addProfession(profession)
    }
    
    func removeProfessionButtonTapped(sender: UIButton) {
        let point = sender.convertPoint(CGPointZero, toView: self.tableView)
        guard let indexPath = self.tableView.indexPathForRowAtPoint(point) else {
            return
        }
        // Remove profession.
        let index = indexPath.row
        // Save profession string for parent.
        let profession = self.professions[index]
        self.professions.removeAtIndex(index)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        // Toggle next button.
        if self.professions.count == 0 {
            self.delegate.toggleNextButton(false)
            //self.doneButton.enabled = false
        }
        // Remove profession from parent.
        self.delegate.removeProfession(profession)
    }
}
