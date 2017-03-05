//
//  EditPostTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 20/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class EditPostTableViewController: UITableViewController {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var captionPlaceholderLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var clearCategoryButton: UIButton!
    @IBOutlet weak var editPostCategoryTableViewCell: UITableViewCell!
    
    var editPost: EditPost?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
        self.configureInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.scrollToRow(at: IndexPath(row: 2, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureInfo() {
        self.postImageView.image = self.editPost?.image
        if let imageWidth = self.editPost?.imageWidth?.floatValue, let imageHeight = self.editPost?.imageHeight?.floatValue {
            let aspectRatio = CGFloat(imageWidth / imageHeight)
            self.postImageViewHeightConstraint.constant = ceil(self.tableView.bounds.width / aspectRatio)
        }
        self.captionTextView.text = self.editPost?.caption
        self.captionTextView.delegate = self
        self.captionPlaceholderLabel.isHidden = self.editPost?.caption != nil ? true : false
        if let categoryName = self.editPost?.categoryName {
            self.categoryNameLabel.text = categoryName
            self.categoryNameLabel.textColor = Colors.black
            self.clearCategoryButton.isHidden = false
            self.categoryImageView.image = UIImage(named: "ic_skill_on")
        } else {
            self.categoryNameLabel.text = "Add Skill"
            self.categoryNameLabel.textColor = Colors.disabled
            self.clearCategoryButton.isHidden = true
            self.categoryImageView.image = UIImage(named: "ic_skill_off")
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? CategoriesTableViewController {
            childViewController.categoriesTableViewControllerDelegate = self
            childViewController.categoryName = self.editPost?.categoryName
        }
    }
    
    // MARK: UITableVieDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell == self.editPostCategoryTableViewCell {
            self.performSegue(withIdentifier: "segueToCategoriesVc", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.updatePost()
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func clearCategoryButtonTapped(_ sender: AnyObject) {
        self.editPost?.categoryName = nil
        self.categoryNameLabel.text = "Add Skill"
        self.categoryNameLabel.textColor = Colors.disabled
        self.clearCategoryButton.isHidden = true
        self.categoryImageView.image = UIImage(named: "ic_skill_off")
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

extension EditPostTableViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = self.captionTextView.text {
            self.captionPlaceholderLabel.isHidden = !text.isEmpty
            
            // Change height of tableViewCell and scroll to bottom of tableView.
            let size = textView.bounds.size
            let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
            if size.height != newSize.height {
                UIView.setAnimationsEnabled(false)
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                UIView.setAnimationsEnabled(true)
                self.tableView.scrollToRow(at: IndexPath(row: 2, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
            }
            self.editPost?.caption = text.trimm().isEmpty ? nil : text.trimm()
        }
    }
}

extension EditPostTableViewController: CategoriesTableViewControllerDelegate {
    
    func didSelectCategory(_ categoryName: String?) {
        if let categoryName = categoryName {
            self.editPost?.categoryName = categoryName
            self.categoryNameLabel.text = categoryName
            self.categoryNameLabel.textColor = Colors.black
            self.clearCategoryButton.isHidden = false
            self.categoryImageView.image = UIImage(named: "ic_skill_on")
        } else {
            self.editPost?.categoryName = nil
            self.categoryNameLabel.text = "Add Skill"
            self.categoryNameLabel.textColor = Colors.disabled
            self.clearCategoryButton.isHidden = true
            self.categoryImageView.image = UIImage(named: "ic_skill_off")
        }
    }
}
