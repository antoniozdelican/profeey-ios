//
//  EditProfileTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 20/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import MapKit

protocol EditAboutDelegate {
    func toggleAboutFakePlaceholderLabel(_ hidden: Bool)
}

class EditProfileTableViewController: UITableViewController {
    
    var user: User?
    
    // Properties.
    var profilePic: UIImage?
    var profilePicUrl: String?
    var firstName: String?
    var lastName: String?
    var about: String?
    var locationName: String?
    var professionName: String?
    
    var profilePicUrlToRemove: String?
    fileprivate var newProfilePicImageData: Data?
    
    fileprivate var editAboutDelegate: EditAboutDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUserData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureUserData() {
        self.profilePic = self.user?.profilePic
        self.profilePicUrl = self.user?.profilePicUrl
        self.firstName = self.user?.firstName
        self.lastName = self.user?.lastName
        self.about = self.user?.about
        self.locationName = self.user?.locationName
        self.professionName = self.user?.professionName
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? LocationsTableViewController {
            childViewController.locationName = self.locationName
        }
        if let destinationViewController = segue.destination as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? ProfessionsTableViewController {
            childViewController.professionName = self.professionName
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? CaptureScrollViewController {
            childViewController.isProfilePic = true
            childViewController.profilePicUnwind = ProfilePicUnwind.editProfileVc
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier == "segueToLocationsVc" else {
            return true
        }
        // Ask for location authorization.
        let status = CLLocationManager.authorizationStatus()
        if (status == CLAuthorizationStatus.restricted) || (status == CLAuthorizationStatus.denied) {
            print("Location Restricted or Denied")
            let alertController = UIAlertController(title: "Enable Location Services", message: "To use location services, please allow it in the Settings", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            let openSettingsAction = UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.default, handler: {
                (alertAction: UIAlertAction) in
                // Open Settings.
                DispatchQueue.main.async(execute: {
                    if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.openURL(appSettings)
                    }
                })
            })
            alertController.addAction(cancelAction)
            alertController.addAction(openSettingsAction)
            present(alertController, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 6
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditProfilePic", for: indexPath) as! EditProfilePicTableViewCell
                cell.profilePicImageView.image = self.profilePic
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditFirstName", for: indexPath) as! EditFirstNameTableViewCell
                cell.firstNameTextField.text = self.firstName
                cell.firstNameTextField.addTarget(self, action: #selector(EditProfileTableViewController.firstNameTextFieldChanged(_:)), for: UIControlEvents.editingChanged)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditLastName", for: indexPath) as! EditLastNameTableViewCell
                cell.lastNameTextField.text = self.lastName
                cell.lastNameTextField.addTarget(self, action: #selector(EditProfileTableViewController.lastNameTextFieldChanged(_:)), for: UIControlEvents.editingChanged)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditAbout", for: indexPath) as! EditAboutTableViewCell
                cell.aboutTextView.text = self.about
                cell.aboutTextView.delegate = self
                if let about = self.about {
                    cell.aboutFakePlaceholderLabel.isHidden = !about.isEmpty
                }
                self.editAboutDelegate = cell
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditLocation", for: indexPath) as! EditLocationTableViewCell
                if let locationName = self.locationName {
                    cell.locationNameLabel.text = locationName
                    cell.locationNameLabel.textColor = Colors.black
                } else {
                    cell.locationNameLabel.text = "Add location"
                    cell.locationNameLabel.textColor = Colors.disabled
                }
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditProfession", for: indexPath) as! EditProfessionTableViewCell
                if let professionName = self.professionName {
                    cell.professionNameLabel.text = professionName
                    cell.professionNameLabel.textColor = Colors.black
                } else {
                    cell.professionNameLabel.text = "Add profession"
                    cell.professionNameLabel.textColor = Colors.disabled
                }
                return cell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
            case 4:
                cell.selectionStyle = UITableViewCellSelectionStyle.default
            case 5:
                cell.selectionStyle = UITableViewCellSelectionStyle.default
                cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
            default:
                return
            }
        default:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                return 112.0
            default:
                return 52.0
            }
        default:
            return 52.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                return 112.0
            case 1:
                return 52.0
            case 2:
                return 52.0
            default:
                return UITableViewAutomaticDimension
            }
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is EditProfilePicTableViewCell {
            self.editProfilePicCellTapped()
        }
        if cell is EditLocationTableViewCell {
            self.performSegue(withIdentifier: "segueToLocationsVc", sender: self)
        }
        if cell is EditProfessionTableViewCell {
            self.performSegue(withIdentifier: "segueToProfessionsVc", sender: self)
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: Tappers
    
    func firstNameTextFieldChanged(_ sender: AnyObject) {
        guard let textField = sender as? UITextField else {
            return
        }
        guard let text = textField.text else {
            return
        }
        self.firstName = text.trimm().isEmpty ? nil : text.trimm()
    }
    
    func lastNameTextFieldChanged(_ sender: AnyObject) {
        guard let textField = sender as? UITextField else {
            return
        }
        guard let text = textField.text else {
            return
        }
        self.lastName = text.trimm().isEmpty ? nil : text.trimm()
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        FullScreenIndicator.show()
        if let newProfilePicImageData = self.newProfilePicImageData {
            self.uploadImage(newProfilePicImageData)
        } else {
            self.saveUser()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToEditProfileTableViewController(_ segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? LocationsTableViewController {
            guard let locationName = sourceViewController.locationName else {
                self.locationName = nil
                self.tableView.reloadData()
                return
            }
            self.locationName = locationName.isEmpty ? nil : locationName
            self.tableView.reloadData()
        }
        if let sourceViewController = segue.source as? ProfessionsTableViewController {
            guard let professionName = sourceViewController.professionName else {
                self.professionName = nil
                self.tableView.reloadData()
                return
            }
            self.professionName = professionName.isEmpty ? nil : professionName
            self.tableView.reloadData()
        }
        if let sourceViewController = segue.source as? PreviewViewController {
            guard let finalImage = sourceViewController.finalImage,
                let imageData = UIImageJPEGRepresentation(finalImage, 0.6)  else {
                return
            }
            self.newProfilePicImageData = imageData
            if self.profilePicUrl != nil {
                self.profilePicUrlToRemove = self.profilePicUrl
                self.profilePicUrl = nil
            }
            self.profilePic = finalImage
            self.tableView.reloadData()
        }
    }
    
    // MARK: Helpers
    
    fileprivate func editProfilePicCellTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let removePhotoAction = UIAlertAction(title: "Remove Photo", style: UIAlertActionStyle.destructive, handler: {
            (alert: UIAlertAction) in
            self.newProfilePicImageData = nil
            if self.profilePicUrl != nil {
                self.profilePicUrlToRemove = self.profilePicUrl
                self.profilePicUrl = nil
            }
            self.profilePic = nil
            self.tableView.reloadData()
        })
        alertController.addAction(removePhotoAction)
        let changePhotoAction = UIAlertAction(title: "Change Photo", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction) in
            self.performSegue(withIdentifier: "segueToCaptureVc", sender: self)
        })
        alertController.addAction(changePhotoAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: AWS
    
    fileprivate func saveUser() {
        let updatedUser = User(userId: self.user?.userId, firstName: self.firstName, lastName: self.lastName, professionName: self.professionName, profilePicUrl: self.profilePicUrl, about: self.about, locationName: self.locationName)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserDynamoDB(updatedUser, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("saveUser error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: "segueUnwindToProfileVc", sender: self)
                }
            })
            return nil
        })
    }
    
    fileprivate func uploadImage(_ imageData: Data) {
        let uniqueImageName = NSUUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
        let imageKey = "public/profile_pics/\(uniqueImageName).jpg"
        let localContent = AWSUserFileManager.custom(key: "USEast1BucketManager").localContent(with: imageData, key: imageKey)
        
        print("uploadImageS3:")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        localContent.uploadWithPin(
            onCompletion: false,
            progressBlock: {
                (content: AWSLocalContent?, progress: Progress?) -> Void in
                // TODO
            }, completionHandler: {
                (content: AWSLocalContent?, error: Error?) -> Void in
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let error = error {
                        FullScreenIndicator.hide()
                        print("uploadImageS3 error: \(error)")
                        let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        print("uploadImageS3 success!")
                        self.profilePicUrl = imageKey
                        self.saveUser()
                    }
                })
        })
    }
}

extension EditProfileTableViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.trimm().isEmpty {
            self.editAboutDelegate?.toggleAboutFakePlaceholderLabel(false)
        } else {
            self.editAboutDelegate?.toggleAboutFakePlaceholderLabel(true)
        }
        self.about = textView.text.trimm().isEmpty ? nil : textView.text.trimm()
        
        // Changing height of the cell
        let currentOffset = self.tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        self.tableView.setContentOffset(currentOffset, animated: false)
    }
}
