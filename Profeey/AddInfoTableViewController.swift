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
    
    var post: Post?
    var photo: UIImage?
    
    fileprivate var bottomIndexPath: IndexPath = IndexPath(row: 2, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.post = Post()
        self.post?.image = self.photo
        
        // Fix alignment for custom rightBarButtonItem.
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
            cell.postImageView.image = self.post?.image
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
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
            return 124.0
        case 1:
            return 68.0
        case 2:
            return 68.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 124.0
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return UITableViewAutomaticDimension
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
        self.post?.caption = textView.text.trimm().isEmpty ? nil : textView.text.trimm()
    }
}

extension AddInfoTableViewController: EditPostCategoryTableViewCellDelegate {
    
    func removeButtonTapped() {
        self.post?.categoryName = nil
        self.tableView.reloadRows(at: [self.bottomIndexPath], with: UITableViewRowAnimation.none)
    }
}

extension AddInfoTableViewController: CategoriesTableViewControllerDelegate {
    
    func didSelectCategory(_ categoryName: String?) {
        self.post?.categoryName = categoryName
        self.tableView.reloadRows(at: [self.bottomIndexPath], with: UITableViewRowAnimation.none)
    }
}
