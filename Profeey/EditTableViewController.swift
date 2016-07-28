//
//  EditTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 13/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol UploadPostDelegate {
    func uploadPost()
}

class EditTableViewController: UITableViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var captionFakePlaceholderLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var recommendationCell: UITableViewCell!
    @IBOutlet weak var recommendationLabel: UILabel!
    @IBOutlet weak var recommendationSwitch: UISwitch!
    @IBOutlet weak var recommendedUsersLabel: UILabel!
    @IBOutlet weak var recommendationSwitchBottomConstraint: NSLayoutConstraint!
    
    // Use reduced thumbnail to show photo and data to transfer real full size photo data.
    var thumbnailPhoto: UIImage?
    var photoData: NSData?
    var categories: [String]?
    var recommendedUsers: [String]?
    
    // Constants used for dynamic cell resize.
    let RECOMMENDATION_SWITCH_BOTTOM_CONSTRAINT_CONSTANT: CGFloat = 8.0
    let BOTTOM_INSET: CGFloat = 15.0
    
    var uploadPostDelegate: UploadPostDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = Colors.grey
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        self.photoImageView.clipsToBounds = true
        self.photoImageView.image = self.thumbnailPhoto
        
        self.captionTextView.delegate = self
        self.captionFakePlaceholderLabel.hidden = !self.captionTextView.text.isEmpty
        self.configureLabel(ItemType.Category)
        self.configureLabel(ItemType.User)
        
        self.recommendedUsersLabel.hidden = true
        self.recommendationSwitchBottomConstraint.constant = self.RECOMMENDATION_SWITCH_BOTTOM_CONSTRAINT_CONSTANT
        self.recommendationCell.selectionStyle = UITableViewCellSelectionStyle.None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController, let childViewController = navigationController.childViewControllers[0] as? ItemsViewController {
            if segue.identifier == "segueToCategoriesVc" {
                childViewController.items = self.categories
                childViewController.delegate = self
                childViewController.itemType = ItemType.Category
            } else if segue.identifier == "segueToUsersVc" {
                childViewController.items = self.recommendedUsers
                childViewController.delegate = self
                childViewController.itemType = ItemType.User
            } else {
                return
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        // Don't allow segue if switch is off.
        if identifier == "segueToUsersVc" && !self.recommendationSwitch.on {
            return false
        } else {
            return true
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.captionTextView.resignFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        // Upload is made on HomeTableViewController.
        self.performSegueWithIdentifier("segueUnwindToHomeVc", sender: self)
    }
    
    @IBAction func recommendationSwitchTapped(sender: AnyObject) {
        guard let recommendationSwitch = sender as? UISwitch else {
            return
        }
        self.configureSwitch(recommendationSwitch.on)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    @IBAction func unwindToEditTableViewController(segue: UIStoryboardSegue) {
    }
    
    // MARK: Helper
    
    private func configureLabel(itemType: ItemType) {
        switch itemType {
        case .Category:
            if let categories = self.categories where !categories.isEmpty {
                self.categoriesLabel.text = categories.joinWithSeparator(" · ")
                self.categoriesLabel.textColor = Colors.blue
            } else {
                self.categoriesLabel.text = "Add categories"
                self.categoriesLabel.textColor = Colors.disabled
            }
        case .User:
            if let users = self.recommendedUsers where !users.isEmpty {
                self.recommendedUsersLabel.text = users.joinWithSeparator("\n")
                self.recommendedUsersLabel.textColor = Colors.green
                self.configureSwitch(true)
            } else {
                self.recommendedUsersLabel.text = "Recommend people"
                self.recommendedUsersLabel.textColor = Colors.disabled
                self.configureSwitch(false)
            }
        default:
            return
        }
    }
    
    private func configureSwitch(recommendationSwitchOn: Bool) {
        if recommendationSwitchOn {
            // To ensure its on!
            self.recommendationSwitch.on = true
            self.recommendationLabel.textColor = Colors.green
            self.recommendedUsersLabel.hidden = false
            self.recommendationCell.selectionStyle = UITableViewCellSelectionStyle.Default
            self.recommendationSwitchBottomConstraint.constant = self.getRecommendedUsersContentHeight()
        } else {
            self.recommendationSwitch.on = false
            self.recommendationLabel.textColor = Colors.greyDark
            self.recommendedUsersLabel.hidden = true
            self.recommendationCell.selectionStyle = UITableViewCellSelectionStyle.None
            self.recommendationSwitchBottomConstraint.constant = self.RECOMMENDATION_SWITCH_BOTTOM_CONSTRAINT_CONSTANT
        }
    }
    
    private func getRecommendedUsersContentHeight() -> CGFloat {
        let width = self.recommendedUsersLabel.bounds.width
        if let usersString = self.recommendedUsersLabel.text {
            let labelRect = NSString(string: usersString).boundingRectWithSize(CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(16.0)], context: nil)
            return ceil(labelRect.size.height) + self.BOTTOM_INSET
        } else {
            return self.RECOMMENDATION_SWITCH_BOTTOM_CONSTRAINT_CONSTANT + self.BOTTOM_INSET
        }
    }
}

extension EditTableViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        self.captionFakePlaceholderLabel.hidden = !textView.text.isEmpty
        
        // Changing height of the cell
        let currentOffset = self.tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        self.tableView.setContentOffset(currentOffset, animated: false)
    }
}

extension EditTableViewController: EditItemsDelegate {
    
    func itemsUpdated(items: [String]?, itemType: ItemType?) {
        if let itemType = itemType {
            switch itemType {
            case .Category:
                self.categories = items
            case .User:
                self.recommendedUsers = items
            default:
                return
            }
            self.configureLabel(itemType)
            self.tableView.reloadData()
        }
    }
}
