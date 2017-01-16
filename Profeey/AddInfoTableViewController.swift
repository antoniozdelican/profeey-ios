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
    
    var postImage: UIImage?
    var caption: String?
    var categoryName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellAddInfoImage", for: indexPath) as! AddInfoImageTableViewCell
            cell.postImageView.image = self.postImage
            if let imageWidth = self.postImage?.size.width, let imageHeight = self.postImage?.size.height {
                let aspectRatio = CGFloat(imageWidth / imageHeight)
                cell.postImageViewHeightConstraint.constant = ceil(cell.postImageViewWidthConstraint.constant / aspectRatio)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditPostDescription", for: indexPath) as! EditPostDescriptionTableViewCell
            cell.editPostDescriptionTableViewCellDelegate = self
            cell.descriptionTextView.text = self.caption
            cell.descriptionPlaceholderLabel.isHidden = self.caption != nil ? true : false
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditPostCategory", for: indexPath) as! EditPostCategoryTableViewCell
            if let categoryName = self.categoryName {
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
        if cell is EditPostCategoryTableViewCell {
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
            //return 132.0
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
}

extension AddInfoTableViewController: EditPostDescriptionTableViewCellDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // Change height of tableViewCell.
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
        self.caption = textView.text.trimm().isEmpty ? nil : textView.text.trimm()
    }
}

extension AddInfoTableViewController: EditPostCategoryTableViewCellDelegate {
    
    func clearCategoryButtonTapped() {
        self.categoryName = nil
        self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: UITableViewRowAnimation.none)
    }
}

extension AddInfoTableViewController: CategoriesTableViewControllerDelegate {
    
    func didSelectCategory(_ categoryName: String?) {
        self.categoryName = categoryName
        self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: UITableViewRowAnimation.none)
    }
}
