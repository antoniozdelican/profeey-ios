//
//  EditPostTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class EditPostTableViewController: UITableViewController {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionFakePlaceholderLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var removeCategoryButton: UIButton!
    @IBOutlet weak var addCategoryTableViewCell: UITableViewCell!
    
    var finalImage: UIImage?
    // Properties that will be passed to HomeVc through delegation.
    var imageData: NSData?
    var postTitle: String?
    var postDescription: String?
    var categoryName: String?
    
    private var categoryAdded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.thumbnailImageView.image = self.finalImage
        if let finalImage = self.finalImage {
            self.imageData = UIImageJPEGRepresentation(finalImage, 0.6)
        }
        self.descriptionTextView.delegate = self
        self.removeCategoryButton.hidden = true
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? AddCategoryViewController {
            childViewController.addCategoryDelegate = self
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
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell == self.addCategoryTableViewCell && !self.categoryAdded {
            self.performSegueWithIdentifier("segueToAddCategoryVc", sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.descriptionTextView.resignFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction func postButtonTapped(sender: AnyObject) {
        self.titleTextField.resignFirstResponder()
        self.descriptionTextView.resignFirstResponder()
        guard let titleText = self.titleTextField.text,
            let descriptionText = self.descriptionTextView.text else {
                return
        }
        
        self.postTitle = titleText.trimm().isEmpty ? nil: titleText.trimm()
        self.postDescription = descriptionText.trimm().isEmpty ? nil : descriptionText.trimm()
        
        // Upload is on ProfileVc.
        self.performSegueWithIdentifier("segueUnwindToProfileVc", sender: self)
    }
    
    @IBAction func removeCategoryButtonTapped(sender: AnyObject) {
        self.categoryName = nil
        self.removeCategoryButton.hidden = true
        self.categoryLabel.text = "Add Skill"
        self.categoryLabel.textColor = Colors.black
        // Allow segueToAddCategoryVc.
        self.categoryAdded = false
        self.addCategoryTableViewCell.selectionStyle = UITableViewCellSelectionStyle.Default
    }
}

extension EditPostTableViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        self.descriptionFakePlaceholderLabel.hidden = !textView.text.isEmpty
        
        // Changing height of the cell
        let currentOffset = self.tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        self.tableView.setContentOffset(currentOffset, animated: false)
    }
}

extension EditPostTableViewController: AddCategoryDelegate {
    
    func addCategory(category: Category) {
        self.categoryName = category.categoryName
        self.removeCategoryButton.hidden = false
        self.categoryLabel.text = category.categoryName
        self.categoryLabel.textColor = Colors.blue
        // Prevent segueToAddCategoryVc.
        self.categoryAdded = true
        self.addCategoryTableViewCell.selectionStyle = UITableViewCellSelectionStyle.None
    }
}
