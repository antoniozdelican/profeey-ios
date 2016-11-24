//
//  UsernameTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class UsernameTableViewController: UITableViewController {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    fileprivate var newProfilePicImageData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.profilePicImageView.layer.cornerRadius = 40.0
        self.usernameTextField.delegate = self
        self.continueButton.isEnabled = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? CaptureScrollViewController {
            childViewController.isProfilePic = true
            childViewController.profilePicUnwind = ProfilePicUnwind.usernameVc
        }
    }

    // MARK: UITableViewController

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath as NSIndexPath).row == 0 {
            self.editProfilePicCellTapped()
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func textFieldChanged(_ sender: AnyObject) {
        guard let usernameText = self.usernameTextField.text else {
                return
        }
        guard !usernameText.trimm().isEmpty else {
                self.continueButton.isEnabled = false
                return
        }
        self.continueButton.isEnabled = true
    }
    
    
    @IBAction func continueButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.prepareForUpdate()
    }
    
    @IBAction func unwindToUsernameTableViewController(_ segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? PreviewViewController {
            guard let finalImage = sourceViewController.finalImage,
                let imageData = UIImageJPEGRepresentation(finalImage, 0.6)  else {
                    return
            }
            self.newProfilePicImageData = imageData
            self.profilePicImageView.image = finalImage
            self.tableView.reloadData()
        }
    }
    
    // MARK: Helpers
    
    fileprivate func editProfilePicCellTapped() {
        self.view.endEditing(true)
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let removePhotoAction = UIAlertAction(title: "Remove Photo", style: UIAlertActionStyle.destructive, handler: {
            (alert: UIAlertAction) in
            self.newProfilePicImageData = nil
            self.profilePicImageView.image = nil
            self.tableView.reloadData()
        })
        alertController.addAction(removePhotoAction)
        let changePhotoAction = UIAlertAction(title: "Add Profile Photo", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction) in
            self.performSegue(withIdentifier: "segueToCaptureVc", sender: self)
        })
        alertController.addAction(changePhotoAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func prepareForUpdate() {
        guard let preferredUsernameText = self.usernameTextField.text else {
                return
        }
        guard !preferredUsernameText.trimm().isEmpty else {
                return
        }
        let preferredUsername = preferredUsernameText.trimm()
        FullScreenIndicator.show()
        self.updatePreferredUsername(preferredUsername)
    }
    
    // MARK: AWS
    
    fileprivate func updatePreferredUsername(_ preferredUsername: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        AWSClientManager.defaultClientManager().updatePreferredUsername(preferredUsername, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    FullScreenIndicator.hide()
                    print("updatePreferredUsernameUserPool error: \(error)")
                    let alertController = UIAlertController(title: "Username unavailable", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    if let profilePicImageData = self.newProfilePicImageData {
                        self.uploadImage(preferredUsername, imageData: profilePicImageData)
                    } else {
                        self.saveUser(preferredUsername, profilePicUrl: nil)
                    }
                }
            })
            return nil
        })
        
    }
    
    fileprivate func saveUser(_ preferredUsername: String, profilePicUrl: String?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserPreferredUsernameAndProfilePicDynamoDB(preferredUsername, profilePicUrl: profilePicUrl, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    FullScreenIndicator.hide()
                    print("saveUser error: \(error)")
                    let alertController = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    FullScreenIndicator.hide()
                    self.performSegue(withIdentifier: "segueToWelcomeProfessionsVc", sender: self)
                }
            })
            return nil
        })
    }
    
    fileprivate func uploadImage(_ preferredUsername: String, imageData: Data) {
        let uniqueImageName = NSUUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
        let imageKey = "public/profile_pics/\(uniqueImageName).jpg"
        let localContent = AWSUserFileManager.UserFileManager(forKey: "USEast1BucketManager").localContent(with: imageData, key: imageKey)
        
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
                        let alertController = UIAlertController(title: "Upload image failed", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        self.saveUser(preferredUsername, profilePicUrl: imageKey)
                    }
                })
        })
    }
}

extension UsernameTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
