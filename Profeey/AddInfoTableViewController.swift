//
//  AddInfoTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class AddInfoTableViewController: UITableViewController {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var captionImageView: UIImageView?
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var captionPlaceholderLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var clearCategoryButton: UIButton!
    @IBOutlet weak var editPostCategoryTableViewCell: UITableViewCell!
    
    var postImage: UIImage?
    var caption: String?
    var categoryName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
        self.configureInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureInfo() {
        self.postImageView.image = self.postImage
        if let imageWidth = self.postImage?.size.width, let imageHeight = self.postImage?.size.height {
            let aspectRatio = CGFloat(imageWidth / imageHeight)
            self.postImageViewHeightConstraint.constant = ceil(self.postImageViewWidthConstraint.constant / aspectRatio)
        }
        self.captionTextView.text = self.caption
        self.captionTextView.delegate = self
        self.captionPlaceholderLabel.isHidden = self.caption != nil ? true : false
        if let categoryName = self.categoryName {
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
            childViewController.categoryName = self.categoryName
            childViewController.isStatusBarHidden = true
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
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
            return 132.0
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
        // Upload is on HomeVc.
        self.performSegue(withIdentifier: "segueUnwindToHomeVc", sender: self)
    }
    
    @IBAction func clearCategoryButtonTapped(_ sender: AnyObject) {
        self.categoryName = nil
        self.categoryNameLabel.text = "Add Skill"
        self.categoryNameLabel.textColor = Colors.disabled
        self.clearCategoryButton.isHidden = true
        self.categoryImageView.image = UIImage(named: "ic_skill_off")
    }
}

extension AddInfoTableViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = self.captionTextView.text {
            self.captionPlaceholderLabel.isHidden = !text.isEmpty
            self.captionImageView?.image = !text.isEmpty ? UIImage(named: "ic_caption_on") : UIImage(named: "ic_caption_off")
            // Change height of tableViewCell.
            let size = textView.bounds.size
            let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
            if size.height != newSize.height {
                UIView.setAnimationsEnabled(false)
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                UIView.setAnimationsEnabled(true)
            }
            self.caption = text.trimm().isEmpty ? nil : text.trimm()
        }
    }
}

extension AddInfoTableViewController: CategoriesTableViewControllerDelegate {
    
    func didSelectCategory(_ categoryName: String?) {
        if let categoryName = categoryName {
            self.categoryName = categoryName
            self.categoryNameLabel.text = categoryName
            self.categoryNameLabel.textColor = Colors.black
            self.clearCategoryButton.isHidden = false
            self.categoryImageView.image = UIImage(named: "ic_skill_on")
        } else {
            self.categoryName = nil
            self.categoryNameLabel.text = "Add Skill"
            self.categoryNameLabel.textColor = Colors.disabled
            self.clearCategoryButton.isHidden = true
            self.categoryImageView.image = UIImage(named: "ic_skill_off")
        }
    }
}
