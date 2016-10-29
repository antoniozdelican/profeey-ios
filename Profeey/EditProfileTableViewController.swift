//
//  EditProfileTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 28/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol EditProfileTableViewControllerDelegate {
    func userUpdated(_ user: User?, profilePicUrlToRemove: String?)
}

protocol EditAboutDelegate {
    func toggleAboutFakePlaceholderLabel(_ hidden: Bool)
}

class EditProfileTableViewController: UITableViewController {
    
    var originalUser: User?
    var editProfileTableViewControllerDelegate: EditProfileTableViewControllerDelegate?
    fileprivate var user: User?
    fileprivate var profilePicUrlToRemove: String?
    fileprivate var newProfilePicImageData: Data?
    fileprivate var editAboutDelegate: EditAboutDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        self.user = User(userId: self.originalUser?.userId, firstName: self.originalUser?.firstName, lastName: self.originalUser?.lastName, professionName: self.originalUser?.professionName, profilePicUrl: self.originalUser?.profilePicUrl, about: self.originalUser?.about, locationName: self.originalUser?.locationName)
        self.user?.profilePic = self.originalUser?.profilePic
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? CaptureScrollViewController {
            childViewController.isProfilePic = true
            childViewController.profilePicUnwind = ProfilePicUnwind.editProfileVc
        }
        if let destinationViewController = segue.destination as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? LocationsTableViewController {
            childViewController.locationName = self.user?.locationName
            childViewController.locationsTableViewControllerDelegate = self
        }
        if let destinationViewController = segue.destination as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? ProfessionsTableViewController {
            childViewController.professionName = self.user?.professionName
            childViewController.professionsTableViewControllerDelegate = self
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditProfilePic", for: indexPath) as! EditProfilePicTableViewCell
            cell.profilePicImageView.image = self.user?.profilePic
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditFirstName", for: indexPath) as! EditFirstNameTableViewCell
            cell.firstNameTextField.text = self.user?.firstName
            cell.editFirstNameTableViewCellDelegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditLastName", for: indexPath) as! EditLastNameTableViewCell
            cell.lastNameTextField.text = self.user?.lastName
            cell.editLastNameTableViewCellDelegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditAbout", for: indexPath) as! EditAboutTableViewCell
            cell.aboutTextView.text = self.user?.about
            cell.aboutTextView.delegate = self
            if let about = self.user?.about {
                cell.aboutFakePlaceholderLabel.isHidden = !about.isEmpty
            }
            self.editAboutDelegate = cell
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditLocation", for: indexPath) as! EditLocationTableViewCell
            if let locationName = self.user?.locationName {
                cell.locationNameLabel.text = locationName
                cell.locationNameLabel.textColor = Colors.black
            } else {
                cell.locationNameLabel.text = "Add city"
                cell.locationNameLabel.textColor = Colors.disabled
            }
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditProfession", for: indexPath) as! EditProfessionTableViewCell
            if let professionName = self.user?.professionName {
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
    }
    
    // MARK: UITableViewDelegate
    
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 112.0
        default:
            return 52.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 112.0
        case 3:
            return UITableViewAutomaticDimension
        default:
            return 52.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1.0
        }
        return 12.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
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
        if let sourceViewController = segue.source as? PreviewViewController {
            guard let finalImage = sourceViewController.finalImage,
                let imageData = UIImageJPEGRepresentation(finalImage, 0.6)  else {
                    return
            }
            self.newProfilePicImageData = imageData
            if self.user?.profilePicUrl != nil {
                self.profilePicUrlToRemove = self.user?.profilePicUrl
                self.user?.profilePicUrl = nil
            }
            self.user?.profilePic = finalImage
            self.tableView.reloadData()
        }
    }
    
    // MARK: Helpers
    
    fileprivate func editProfilePicCellTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let removePhotoAction = UIAlertAction(title: "Remove Photo", style: UIAlertActionStyle.destructive, handler: {
            (alert: UIAlertAction) in
            self.newProfilePicImageData = nil
            if self.user?.profilePicUrl != nil {
                self.profilePicUrlToRemove = self.user?.profilePicUrl
                self.user?.profilePicUrl = nil
            }
            self.user?.profilePic = nil
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserDynamoDB(self.user, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("saveUser error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.editProfileTableViewControllerDelegate?.userUpdated(self.user, profilePicUrlToRemove: self.profilePicUrlToRemove)
                    self.dismiss(animated: true, completion: nil)
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
                        self.user?.profilePicUrl = imageKey
                        self.saveUser()
                    }
                })
        })
    }
}

extension EditProfileTableViewController: EditFirstNameTableViewCellDelegate {
    
    func firstNameTextFieldChanged(_ text: String) {
        self.user?.firstName = text.trimm().isEmpty ? nil : text.trimm()
    }
}

extension EditProfileTableViewController: EditLastNameTableViewCellDelegate {
    
    func lastNameTextFieldChanged(_ text: String) {
        self.user?.lastName = text.trimm().isEmpty ? nil : text.trimm()
    }
}

extension EditProfileTableViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.trimm().isEmpty {
            self.editAboutDelegate?.toggleAboutFakePlaceholderLabel(false)
        } else {
            self.editAboutDelegate?.toggleAboutFakePlaceholderLabel(true)
        }
        self.user?.about = textView.text.trimm().isEmpty ? nil : textView.text.trimm()
        
        // Changing height of the cell
        let currentOffset = self.tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        self.tableView.setContentOffset(currentOffset, animated: false)
    }
}

extension EditProfileTableViewController: LocationsTableViewControllerDelegate {
    
    func didSelectLocation(_ locationName: String?) {
        self.user?.locationName = locationName
        self.tableView.reloadData()
    }
}

extension EditProfileTableViewController: ProfessionsTableViewControllerDelegate {
    
    func didSelectProfession(_ professionName: String?) {
        self.user?.professionName = professionName
        self.tableView.reloadData()
    }
}
