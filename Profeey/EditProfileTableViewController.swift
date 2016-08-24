//
//  EditProfileTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol EditProfileDelegate {
    // Notify profileTableVc that user is updated.
    func userUpdated(user: User?)
}

class EditProfileTableViewController: UITableViewController {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    
    var user: User?
    var editProfileDelegate: EditProfileDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        self.configureUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    private func configureUser() {
        self.profilePicImageView.image = self.user?.profilePic
        self.usernameLabel.text = self.user?.preferredUsername
        self.fullNameLabel.text = self.user?.fullName
        self.professionLabel.text = self.user?.profession
        self.locationLabel.text = self.user?.location
        self.aboutLabel.text = self.user?.about
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
            case let destinationViewController as EditProfessionTableViewController:
                destinationViewController.profession = self.user?.profession
                destinationViewController.editProfessionDelegate = self
            case let destinationViewController as EditLocationTableViewController:
                destinationViewController.location = self.user?.location
                destinationViewController.editLocationDelegate = self
            case let destinationViewController as EditAboutTableViewController:
                destinationViewController.about = self.user?.about
                destinationViewController.editAboutDelegate = self
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

extension EditProfileTableViewController: EditProfessionDelegate {
    
    func professionUpdated(profession: String?) {
        self.user?.profession = profession
        self.configureUser()
        self.editProfileDelegate?.userUpdated(self.user)
    }
}

extension EditProfileTableViewController: EditLocationDelegate {
    
    func locationUpdated(location: String?) {
        self.user?.location = location
        self.configureUser()
        self.editProfileDelegate?.userUpdated(self.user)
    }
}

extension EditProfileTableViewController: EditAboutDelegate {
    
    func aboutUpdated(about: String?) {
        self.user?.about = about
        self.configureUser()
        self.editProfileDelegate?.userUpdated(self.user)
    }
}
