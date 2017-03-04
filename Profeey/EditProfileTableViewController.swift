//
//  EditProfileTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 28/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import PhotosUI
import AWSMobileHubHelper

protocol EditAboutDelegate: class {
    func toggleAboutFakePlaceholderLabel(_ hidden: Bool)
}

class EditProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editProfilePicTableViewCell: UITableViewCell!
    @IBOutlet weak var editSchoolTableViewCell: UITableViewCell!
    @IBOutlet weak var editProfessionTableViewCell: UITableViewCell!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var aboutPlaceholderLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var clearSchoolButton: UIButton!
    @IBOutlet weak var professionNameLabel: UILabel!
    @IBOutlet weak var clearProfessionButton: UIButton!
    @IBOutlet weak var websiteTextField: UITextField!
    
    var user: EditUser?
    fileprivate var profilePicUrlToRemove: String?
    fileprivate var newProfilePicImageData: Data?
    fileprivate weak var editAboutDelegate: EditAboutDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        self.saveButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
        
        self.configureUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureUser() {
        self.profilePicImageView.image = self.user?.profilePic != nil ? self.user?.profilePic : UIImage(named: "ic_no_profile_pic_profile")
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        self.firstNameTextField.text = self.user?.firstName
        self.lastNameTextField.text = self.user?.lastName
        self.aboutTextView.text = self.user?.about
        self.aboutTextView.delegate = self
        self.aboutPlaceholderLabel.isHidden = self.user?.about != nil ? true : false
        if let schoolName = self.user?.schoolName {
            self.schoolNameLabel.text = schoolName
            self.schoolNameLabel.textColor = Colors.black
            self.clearSchoolButton.isHidden = false
        } else {
            self.schoolNameLabel.text = "Add School"
            self.schoolNameLabel.textColor = Colors.disabled
            self.clearSchoolButton.isHidden = true
        }
        if let professionName = self.user?.professionName {
            self.professionNameLabel.text = professionName
            self.professionNameLabel.textColor = Colors.black
            self.clearProfessionButton.isHidden = false
        } else {
            self.professionNameLabel.text = "Add Profession"
            self.professionNameLabel.textColor = Colors.disabled
            self.clearProfessionButton.isHidden = true
        }
        self.websiteTextField.text = self.user?.website
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? CaptureScrollViewController {
            childViewController.isProfilePic = true
            childViewController.profilePicUnwind = ProfilePicUnwind.editProfileVc
        }
        if let destinationViewController = segue.destination as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? SchoolsTableViewController {
            childViewController.schoolName = self.user?.schoolName
            childViewController.schoolsTableViewControllerDelegate = self
        }
        if let destinationViewController = segue.destination as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? ProfessionsTableViewController {
            childViewController.professionName = self.user?.professionName
            childViewController.professionsTableViewControllerDelegate = self
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell == self.editProfilePicTableViewCell {
            self.editProfilePicCellTapped()
        }
        if cell == self.editSchoolTableViewCell {
            self.performSegue(withIdentifier: "segueToSchoolsVc", sender: cell)
        }
        if cell == self.editProfessionTableViewCell {
            self.performSegue(withIdentifier: "segueToProfessionsVc", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 134.0
        default:
            return 52.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 134.0
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
            self.updateUser()
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
            self.profilePicImageView.image = self.user?.profilePic != nil ? self.user?.profilePic : UIImage(named: "ic_no_profile_pic_profile")
        }
    }
    
    @IBAction func editProfilePicButtonTapped(_ sender: AnyObject) {
        self.editProfilePicCellTapped()
    }
    
    @IBAction func firstNameTextFieldChanged(_ sender: AnyObject) {
        if let text = self.firstNameTextField.text {
            self.user?.firstName = text.trimm().isEmpty ? nil : text.trimm()
        }
    }
    
    @IBAction func lastNameTextFieldChanged(_ sender: AnyObject) {
        if let text = self.lastNameTextField.text {
            self.user?.lastName = text.trimm().isEmpty ? nil : text.trimm()
        }
    }
    
    @IBAction func clearSchoolButtonTapped(_ sender: AnyObject) {
        self.user?.schoolId = nil
        self.user?.schoolName = nil
        self.schoolNameLabel.text = "Add School"
        self.schoolNameLabel.textColor = Colors.disabled
        self.clearSchoolButton.isHidden = true
    }
    
    @IBAction func clearProfessionButtonTapped(_ sender: AnyObject) {
        self.user?.professionName = nil
        self.professionNameLabel.text = "Add Profession"
        self.professionNameLabel.textColor = Colors.disabled
        self.clearProfessionButton.isHidden = true
    }
    
    @IBAction func websiteTextFieldChanged(_ sender: AnyObject) {
        if let text = self.websiteTextField.text {
            self.user?.website = text.trimm().isEmpty ? nil : text.trimm()
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
            self.user?.profilePic = UIImage(named: "ic_no_profile_pic_profile")
            self.profilePicImageView.image = self.user?.profilePic != nil ? self.user?.profilePic : UIImage(named: "ic_no_profile_pic_profile")
        })
        alertController.addAction(removePhotoAction)
        let changePhotoAction = UIAlertAction(title: "Change Photo", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction) in
            // Check Photos access for the first time. This can happen on MainTabBarVc, UsernameVc, ProfileVc and EditVc.
            if PHPhotoLibrary.authorizationStatus() == .notDetermined {
                PHPhotoLibrary.requestAuthorization({
                    (status: PHAuthorizationStatus) in
                    self.performSegue(withIdentifier: "segueToCaptureVc", sender: self)
                })
            } else {
                self.performSegue(withIdentifier: "segueToCaptureVc", sender: self)
            }
        })
        alertController.addAction(changePhotoAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: AWS
    
    fileprivate func updateUser() {
        guard let user = self.user else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().updateUserDynamoDB(user.firstName, lastName: user.lastName, professionName: user.professionName, profilePicUrl: user.profilePicUrl, about: user.about, schoolId: user.schoolId, schoolName: user.schoolName, website: user.website, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("updateUser error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // Don't need to copy user.
                    var userInfo: [String: Any] = ["user": user]
                    // Remove old profilePic on ProfileVc.
                    if let profilePicUrlToRemove = self.profilePicUrlToRemove {
                        userInfo["profilePicUrlToRemove"] = profilePicUrlToRemove
                    }
                    // Notifiy observers.
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: UpdateUserNotificationKey), object: self, userInfo: userInfo)
                    // Update locally.
                    PRFYDynamoDBManager.defaultDynamoDBManager().updateCurrentUserLocal(user.firstName, lastName: user.lastName, preferredUsername: user.preferredUsername, professionName: user.professionName, profilePicUrl: user.profilePicUrl, schoolId: user.schoolId, schoolName: user.schoolName, profilePic: user.profilePic)
                    self.dismiss(animated: true, completion: nil)
                }
            })
            return nil
        })
    }
    
    fileprivate func uploadImage(_ imageData: Data) {
        let uniqueImageName = NSUUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
        let imageKey = "public/profile_pics/\(uniqueImageName).jpg"
        let localContent = AWSUserFileManager.defaultUserFileManager().localContent(with: imageData, key: imageKey)
        
        print("uploadImageS3:")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        localContent.uploadWithPin(
            onCompletion: true,
            progressBlock: {
                (content: AWSLocalContent?, progress: Progress?) -> Void in
                // Do nothing.
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
                        self.user?.profilePicUrl = imageKey
                        self.updateUser()
                    }
                })
        })
    }
}

extension EditProfileTableViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = self.aboutTextView.text {
            self.aboutPlaceholderLabel.isHidden = !text.isEmpty
            self.user?.about = text.trimm().isEmpty ? nil : text.trimm()
            // Changing height of the cell
            let currentOffset = self.tableView.contentOffset
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            self.tableView.setContentOffset(currentOffset, animated: false)
        }
    }
}

extension EditProfileTableViewController: SchoolsTableViewControllerDelegate {
    
    func didSelectSchool(_ school: School) {
        self.user?.schoolId = school.schoolId
        self.user?.schoolName = school.schoolName
        self.schoolNameLabel.text = school.schoolName
        self.schoolNameLabel.textColor = Colors.black
        self.clearSchoolButton.isHidden = false
    }
}

extension EditProfileTableViewController: ProfessionsTableViewControllerDelegate {

    func didSelectProfession(_ professionName: String?) {
        if let professionName = professionName {
            self.user?.professionName = professionName
            self.professionNameLabel.text = professionName
            self.professionNameLabel.textColor = Colors.black
            self.clearProfessionButton.isHidden = false
        } else {
            self.user?.professionName = nil
            self.professionNameLabel.text = "Add Profession"
            self.professionNameLabel.textColor = Colors.disabled
            self.clearProfessionButton.isHidden = true
        }
    }
}
