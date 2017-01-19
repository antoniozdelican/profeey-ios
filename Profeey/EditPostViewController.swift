//
//  EditPostViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 04/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class EditPostViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    
    var editPost: EditPost?
    fileprivate var bottomIndexPath: IndexPath = IndexPath(row: 2, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.scrollToRow(at: self.bottomIndexPath, at: UITableViewScrollPosition.bottom, animated: false)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.scrollToRow(at: self.bottomIndexPath, at: UITableViewScrollPosition.bottom, animated: false)
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
            let childViewController = navigationController.childViewControllers[0] as? CategoriesTableViewController {
            childViewController.categoriesTableViewControllerDelegate = self
            childViewController.categoryName = self.editPost?.categoryName
        }
    }
    
    // MARK: Keyboard
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillBeShown(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillBeHidden(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)
    }
    
    func keyboardWillBeShown(_ notification: Notification) {
        let userInfo: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (userInfo.object(forKey: UIKeyboardFrameBeginUserInfoKey)! as AnyObject).cgRectValue.size
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
        self.tableView.scrollToRow(at: self.bottomIndexPath, at: UITableViewScrollPosition.bottom, animated: false)
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.updatePost()
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // MARK: AWS
    
    fileprivate func updatePost() {
        guard let postId = self.editPost?.postId else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        PRFYDynamoDBManager.defaultDynamoDBManager().updatePostDynamoDB(postId, caption: self.editPost?.caption, categoryName: self.editPost?.categoryName, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("updatePost error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    var userInfo = ["postId": postId]
                    if let caption = self.editPost?.caption {
                        userInfo["caption"] = caption
                    }
                    if let categoryName = self.editPost?.categoryName {
                        userInfo["categoryName"] = categoryName
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: UpdatePostNotificationKey), object: self, userInfo: userInfo)
                    self.dismiss(animated: false, completion: nil)
                }
            })
            return nil
        })
    }
    
}

extension EditPostViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditPostImage", for: indexPath) as! EditPostImageTableViewCell
            cell.postImageView.image = self.editPost?.image
            if let imageWidth = self.editPost?.imageWidth?.floatValue, let imageHeight = self.editPost?.imageHeight?.floatValue {
                let aspectRatio = CGFloat(imageWidth / imageHeight)
                cell.postImageViewHeightConstraint.constant = ceil(tableView.bounds.width / aspectRatio)
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditPostDescription", for: indexPath) as! EditPostDescriptionTableViewCell
            cell.descriptionTextView.text = self.editPost?.caption
            cell.descriptionPlaceholderLabel.isHidden = self.editPost?.caption != nil ? true : false
            cell.editPostDescriptionTableViewCellDelegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditPostCategory", for: indexPath) as! EditPostCategoryTableViewCell
            if let categoryName = self.editPost?.categoryName {
                cell.categoryNameLabel.text = categoryName
                cell.categoryNameLabel.textColor = Colors.black
                cell.clearCategoryButton.isHidden = false
                cell.categoryImageView.image = UIImage(named: "ic_skills_active")
            } else {
                cell.categoryNameLabel.text = "Add Skill"
                cell.categoryNameLabel.textColor = Colors.disabled
                cell.clearCategoryButton.isHidden = true
                cell.categoryImageView.image = UIImage(named: "ic_skills")
            }
            cell.editPostCategoryTableViewCellDelegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableVieDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if cell is EditPostImageTableViewCell {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is EditPostCategoryTableViewCell {
            self.performSegue(withIdentifier: "segueToCategoriesVc", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 500.0
        case 1:
            return 52.0
        case 2:
            return 52.0
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return UITableViewAutomaticDimension
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return 52.0
        default:
            return 0.0
        }
    }
}

extension EditPostViewController: EditPostDescriptionTableViewCellDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // Change height of tableViewCell and scroll to bottom of tableView.
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            self.tableView.scrollToRow(at: self.bottomIndexPath, at: UITableViewScrollPosition.bottom, animated: false)
        }
        self.editPost?.caption = textView.text.trimm().isEmpty ? nil : textView.text.trimm()
    }
}

extension EditPostViewController: EditPostCategoryTableViewCellDelegate {
    
    func clearCategoryButtonTapped() {
        self.editPost?.categoryName = nil
        (self.tableView.cellForRow(at: self.bottomIndexPath) as? EditPostCategoryTableViewCell)?.categoryNameLabel.text = "Add Skill"
        (self.tableView.cellForRow(at: self.bottomIndexPath) as? EditPostCategoryTableViewCell)?.categoryNameLabel.textColor = Colors.disabled
        (self.tableView.cellForRow(at: self.bottomIndexPath) as? EditPostCategoryTableViewCell)?.clearCategoryButton.isHidden = true
        (self.tableView.cellForRow(at: self.bottomIndexPath) as? EditPostCategoryTableViewCell)?.categoryImageView.image = UIImage(named: "ic_skills")
    }
}

extension EditPostViewController: CategoriesTableViewControllerDelegate {
    
    func didSelectCategory(_ categoryName: String?) {
        self.editPost?.categoryName = categoryName
        (self.tableView.cellForRow(at: self.bottomIndexPath) as? EditPostCategoryTableViewCell)?.categoryNameLabel.text = categoryName
        (self.tableView.cellForRow(at: self.bottomIndexPath) as? EditPostCategoryTableViewCell)?.categoryNameLabel.textColor = Colors.black
        (self.tableView.cellForRow(at: self.bottomIndexPath) as? EditPostCategoryTableViewCell)?.clearCategoryButton.isHidden = false
        (self.tableView.cellForRow(at: self.bottomIndexPath) as? EditPostCategoryTableViewCell)?.categoryImageView.image = UIImage(named: "ic_skills_active")
    }
}
