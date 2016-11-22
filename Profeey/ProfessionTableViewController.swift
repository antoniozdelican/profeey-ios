//
//  ProfessionTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 24/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class ProfessionTableViewController: UITableViewController {
    
    var profession: Profession?
    fileprivate var locationName: String?
    
    fileprivate var users: [User] = []
    fileprivate var allUsers: [User] = []
    fileprivate var locationUsers: [User] = []
    fileprivate var isSearchingUsers: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationItem.title = self.profession?.professionName
        if let professionName = self.profession?.professionName {
            self.isSearchingUsers = true
            self.scanUsersByProfessionName(professionName)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.user = self.users[indexPath.row]
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? LocationsTableViewController {
            childViewController.locationsTableViewControllerDelegate = self
        }
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if self.isSearchingUsers {
                return 1
            }
            if self.users.count == 0 {
                return 1
            }
            return self.users.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellAddLocation", for: indexPath) as! AddLocationTableViewCell
            if self.locationName != nil {
                cell.locationNameLabel.text = self.locationName
                cell.setActiveLocation()
                cell.clearButton.isHidden = false
            } else {
                cell.locationNameLabel.text = "Add city..."
                cell.setIncativeLocation()
                cell.clearButton.isHidden = true
            }
            cell.addLocationTableViewCellDelegate = self
            return cell
        case 1:
            if self.isSearchingUsers {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                cell.activityIndicator.startAnimating()
                return cell
            }
            if self.users.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearchUser", for: indexPath) as! SearchUserTableViewCell
            let user = self.users[indexPath.row]
            cell.profilePicImageView.image = user.profilePic
            cell.fullNameLabel.text = user.fullName
            cell.preferredUsernameLabel.text = user.preferredUsername
            cell.professionNameLabel.text = user.professionName
            cell.locationNameLabel.text = user.locationName
            cell.locationStackView.isHidden = user.locationName != nil ? false : true
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if cell is NoResultsTableViewCell {
            cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is SearchUserTableViewCell {
            self.performSegue(withIdentifier: "segueToProfileVc", sender: indexPath)
        }
        if cell is AddLocationTableViewCell {
            self.performSegue(withIdentifier: "segueToLocationsVc", sender: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 52.0
        case 1:
            if self.isSearchingUsers {
                return 64.0
            }
            if self.users.count == 0 {
                return 64.0
            }
            return 104.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 52.0
        case 1:
            if self.isSearchingUsers {
                return 64.0
            }
            if self.users.count == 0 {
                return 64.0
            }
            return UITableViewAutomaticDimension
        default:
            return 0.0
        }
    }
    
    // MARK: AWS
    
    fileprivate func scanUsersByProfessionName(_ professionName: String) {
        let searchProfessionName = professionName.lowercased()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanUsersByProfessionNameDynamoDB(searchProfessionName, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingUsers = false
                if let error = error {
                    print("scanUsersByProfessionName error: \(error)")
                    self.reloadUsersSection()
                } else {
                    guard let awsUsers = response?.items as? [AWSUser], awsUsers.count > 0 else {
                        self.reloadUsersSection()
                        return
                    }
                    for awsUser in awsUsers {
                        let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationName: awsUser._locationName)
                        self.allUsers.append(user)
                    }
                    self.users = self.allUsers
                    self.reloadUsersSection()
                    
                    for (index, user) in self.allUsers.enumerated() {
                        if let profilePicUrl = user.profilePicUrl {
                            let indexPath = IndexPath(row: index, section: 1)
                            self.downloadImage(profilePicUrl, imageType: ImageType.userProfilePic, indexPath: indexPath)
                        }
                    }
                }
            })
        })
    }
    
    fileprivate func downloadImage(_ imageKey: String, imageType: ImageType, indexPath: IndexPath) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let content = AWSUserFileManager.custom(key: "USEast1BucketManager").content(withKey: imageKey)
        // TODO check if content.isImage()
        if content.isCached {
            print("Content cached:")
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            let image = UIImage(data: content.cachedData)
            switch imageType {
            case .userProfilePic:
                self.allUsers[indexPath.row].profilePic = image
                self.reloadUsersSection()
            default:
                return
            }
        } else {
            print("Download content:")
            content.download(
                with: AWSContentDownloadType.ifNewerExists,
                pinOnCompletion: false,
                progressBlock: {
                    (content: AWSContent?, progress: Progress?) -> Void in
                    // TODO
                },
                completionHandler: {
                    (content: AWSContent?, data: Data?, error: Error?) in
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if let error = error {
                            print("downloadImage error: \(error)")
                        } else {
                            guard let imageData = data else {
                                return
                            }
                            let image = UIImage(data: imageData)
                            switch imageType {
                            case .userProfilePic:
                                self.allUsers[indexPath.row].profilePic = image
                                self.reloadUsersSection()
                            default:
                                return
                            }
                        }
                    })
            })
        }
    }
    
    // MARK: Helper
    
    fileprivate func filterUsers(_ searchText: String) {
//        let searchLocationName = searchText.lowercased()
        let searchLocationName = searchText
        self.locationUsers = self.allUsers.filter({
            (user: User) in
            if let locationName = user.locationName, locationName.hasPrefix(searchLocationName) {
                return true
            } else {
                return false
            }
        })
        self.users = self.locationUsers
        self.reloadUsersSection()
    }
    
    fileprivate func reloadUsersSection () {
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
        }
    }
    
    fileprivate func reloadAddLocationSection () {
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.none)
        }
    }
}

extension ProfessionTableViewController: AddLocationTableViewCellDelegate {
    
    func clearButtonTapped(_ button: UIButton) {
        self.locationName = nil
        self.reloadAddLocationSection()
        self.users = self.allUsers
        self.reloadUsersSection()
    }
}

extension ProfessionTableViewController: LocationsTableViewControllerDelegate {
    
    func didSelectLocation(_ locationName: String?) {
        self.locationName = locationName
        if locationName != nil {
            self.filterUsers(locationName!)
        }
        self.reloadAddLocationSection()
    }
}
