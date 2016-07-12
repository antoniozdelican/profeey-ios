//
//  EditProfileTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditProfileDelegate {
    func currentUserUpdated(currentUser: CurrentUser)
}

class EditProfileTableViewController: UITableViewController {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var usernamePlaceholderLabel: UILabel!
    @IBOutlet weak var namePlaceholderLabel: UILabel!
    @IBOutlet weak var aboutPlaceholderLabel: UILabel!
    @IBOutlet weak var professionsPlaceholderLabel: UILabel!
    
    var currentUser: CurrentUser!
    var delegate: EditProfileDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = Colors.grey
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        
        if let imageData = self.currentUser.profilePicData {
            self.profilePicImageView.image = UIImage(data: imageData)
        }
        self.usernamePlaceholderLabel.text = self.currentUser.preferredUsername
        self.namePlaceholderLabel.text = self.currentUser.fullName
        self.professionsPlaceholderLabel.text = self.currentUser.professions?.joinWithSeparator(" · ")
        self.aboutPlaceholderLabel.text = self.currentUser.about
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController {
            switch navigationController.childViewControllers[0] {
            case let destinationViewController as EditUsernameTableViewController:
                destinationViewController.preferredUsername = self.currentUser.preferredUsername
                destinationViewController.delegate = self
            case let destinationViewController as EditNameTableViewController:
                destinationViewController.fullName = self.currentUser.fullName
                destinationViewController.delegate = self
            case let destinationViewController as EditProfessionsViewController:
                destinationViewController.professions = self.currentUser.professions
                destinationViewController.delegate = self
            case let destinationViewController as EditAboutTableViewController:
                destinationViewController.about = self.currentUser.about
                destinationViewController.delegate = self
            default:
                return
            }
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: IBActions
    
    @IBAction func unwindToEditProfileTableViewController(segue: UIStoryboardSegue) {
    }
}

extension EditProfileTableViewController: EditNameDelegate {
    
    func nameUpdated(fullName: String?) {
        self.currentUser.fullName = fullName
        self.namePlaceholderLabel.text = self.currentUser.fullName
        self.tableView.reloadData()
        // Inform delegate.
        self.delegate?.currentUserUpdated(self.currentUser)
    }
}

extension EditProfileTableViewController: EditUsernameDelegate {
    
    func usernameUpdated(preferredUsername: String?) {
        self.currentUser.preferredUsername = preferredUsername
        self.usernamePlaceholderLabel.text = self.currentUser.preferredUsername
        self.tableView.reloadData()
        self.delegate?.currentUserUpdated(self.currentUser)
    }
}

extension EditProfileTableViewController: EditAboutDelegate {
    
    func aboutUpdated(about: String?) {
        self.currentUser.about = about
        self.aboutPlaceholderLabel.text = self.currentUser.about
        self.tableView.reloadData()
        self.delegate?.currentUserUpdated(self.currentUser)
    }
}

extension EditProfileTableViewController: EditProfessionsDelegate {
    
    func professionsUpdated(professions: [String]?) {
        self.currentUser.professions = professions
        self.professionsPlaceholderLabel.text = self.currentUser.professions?.joinWithSeparator(" · ")
        self.tableView.reloadData()
        self.delegate?.currentUserUpdated(self.currentUser)
    }
}
