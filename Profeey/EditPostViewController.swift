//
//  EditPostViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 04/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol EditPostViewControllerDelegate {
    func updatedPost(post: Post, indexPath: IndexPath)
}

class EditPostViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var post: Post?
    var indexPath: IndexPath?
    var editPostViewControllerDelegate: EditPostViewControllerDelegate?
    fileprivate var bottomIndexPath: IndexPath = IndexPath(row: 2, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        self.updatePost()
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // MARK: AWS
    
    fileprivate func updatePost() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().updatePostDynamoDB(self.post, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
               UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                   print("updatePost error: \(error)")
                } else {
                    guard let post = self.post, let indexPath = self.indexPath else {
                        return
                    }
                    self.editPostViewControllerDelegate?.updatedPost(post: post, indexPath: indexPath)
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
            cell.postImageView.image = self.post?.image
            if let image = self.post?.image {
                let aspectRatio = image.size.width / image.size.height
                cell.postImageViewHeightConstraint.constant = ceil(tableView.bounds.width / aspectRatio)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditPostDescription", for: indexPath) as! EditPostDescriptionTableViewCell
            cell.editPostDescriptionTableViewCellDelegate = self
            cell.descriptionTextView.text = self.post?.caption
            cell.descriptionPlaceholderLabel.isHidden = self.post?.caption != nil ? true : false
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditPostCategory", for: indexPath) as! EditPostCategoryTableViewCell
            cell.editPostCategoryTableViewCellDelegate = self
            if let categoryName = self.post?.categoryName {
                cell.categoryAdded(categoryName: categoryName)
            } else {
                cell.categoryRemoved()
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableVieDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is EditPostCategoryTableViewCell {
            if self.post?.categoryName == nil {
                self.performSegue(withIdentifier: "segueToCategoriesVc", sender: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 500.0
        case 1:
            return 54.0
        case 2:
            return 54.0
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
            return UITableViewAutomaticDimension
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
        self.post?.caption = textView.text.trimm().isEmpty ? nil : textView.text.trimm()
    }
}

extension EditPostViewController: EditPostCategoryTableViewCellDelegate {
    
    func removeButtonTapped() {
        self.post?.categoryName = nil
        self.tableView.reloadRows(at: [self.bottomIndexPath], with: UITableViewRowAnimation.none)
    }
}

extension EditPostViewController: CategoriesTableViewControllerDelegate {
    
    func didSelectCategory(categoryName: String) {
        self.post?.categoryName = categoryName
        self.tableView.reloadRows(at: [self.bottomIndexPath], with: UITableViewRowAnimation.none)
    }
}
