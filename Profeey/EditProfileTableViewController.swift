//
//  EditProfileTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditProfileDelegate {
    func userUpdated(user: User?)
}

class EditProfileTableViewController: UITableViewController {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var professionsLabel: UILabel!
    
    var user: User?
    var editProfileDelegate: EditProfileDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    private func configureUser() {
        self.usernameLabel.text = self.user?.preferredUsername
        self.fullNameLabel.text = self.user?.fullName
        self.professionsLabel.text = self.user?.professions?.joinWithSeparator(" · ")
        self.tableView.reloadData()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController {
            switch navigationController.childViewControllers[0] {
            case let destinationViewController as EditUsernameTableViewController:
                destinationViewController.preferredUsername = self.user?.preferredUsername
                destinationViewController.editUsernameDelegate = self
            case let destinationViewController as EditFirstLastNameTableViewController:
                destinationViewController.firstName = self.user?.firstName
                destinationViewController.lastName = self.user?.lastName
                destinationViewController.editFirstLastNameDelegate = self
            case let destinationViewController as ProfessionsViewController:
                if let professions = self.user?.professions {
                    destinationViewController.professions = professions
                }
                destinationViewController.editProfessionsDelegate = self
                destinationViewController.isEditProfessions = true
                
//            case let destinationViewController as ItemsViewController:
//                destinationViewController.items = self.user?.professions
//                destinationViewController.delegate = self
//                destinationViewController.itemType = ItemType.Profession
//            case let destinationViewController as EditAboutTableViewController:
//                destinationViewController.about = self.user?.about
//                destinationViewController.delegate = self
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

extension EditProfileTableViewController: EditUsernameDelegate {
    
    func usernameUpdated(preferredUsername: String?) {
        self.user?.preferredUsername = preferredUsername
        self.configureUser()
        self.editProfileDelegate?.userUpdated(self.user)
    }
}

extension EditProfileTableViewController: EditFirstLastNameDelegate {
    
    func firstLastNameUpdated(firstName: String?, lastName: String?) {
        self.user?.firstName = firstName
        self.user?.lastName = lastName
        self.configureUser()
        self.editProfileDelegate?.userUpdated(self.user)
    }
}

extension EditProfileTableViewController: EditProfessionsDelegate {
    
    func professionsUpdated(professions: [String]?) {
        self.user?.professions = professions
        self.configureUser()
        self.editProfileDelegate?.userUpdated(self.user)
    }
}

//extension EditProfileTableViewController: EditAboutDelegate {
//    
//    func aboutUpdated(about: String?) {
//        self.currentUser?.about = about
//        self.aboutPlaceholderLabel.text = self.currentUser?.about
//        self.tableView.reloadData()
//        //self.delegate?.currentUserUpdated(self.currentUser)
//    }
//}

//extension EditProfileTableViewController: EditItemsDelegate {
//    
//    func itemsUpdated(items: [String]?, itemType: ItemType?) {
//        // We know here itemType is .Profession
//        self.currentUser?.professions = items
//        self.professionsPlaceholderLabel.text = self.currentUser?.professions?.joinWithSeparator(" · ")
//        self.tableView.reloadData()
//        //self.delegate?.currentUserUpdated(self.currentUser)
//    }
//}
