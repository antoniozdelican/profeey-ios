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
    @IBOutlet weak var categoriesLabel: UILabel!
    
    var finalImage: UIImage?
    var imageData: NSData?
    private var categories: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.thumbnailImageView.image = self.finalImage
        self.descriptionTextView.delegate = self
        if let finalImage = self.finalImage {
            self.imageData = UIImageJPEGRepresentation(finalImage, 0.6)
        }
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
            let childViewController = navigationController.childViewControllers[0] as? EditCategoriesViewController {
            childViewController.oldCategories = self.categories
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
        self.descriptionTextView.resignFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction func postButtonTapped(sender: AnyObject) {
        self.titleTextField.resignFirstResponder()
        self.descriptionTextView.resignFirstResponder()
        // Upload is on homeVc.
        self.performSegueWithIdentifier("segueUnwindToHomeVc", sender: self)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func unwindToEditPostTableViewController(segue: UIStoryboardSegue) {
        if segue.identifier == "segueUnwindToEditPostVc",
            let sourceViewController = segue.sourceViewController as? EditCategoriesViewController {
            self.categories = sourceViewController.categories
            if self.categories.count > 0 {
              self.categoriesLabel.textColor = Colors.blue
                self.categoriesLabel.text = self.categories.joinWithSeparator(" · ")
            } else {
                self.categoriesLabel.textColor = Colors.disabled
                self.categoriesLabel.text = "Add categories"
            }
        }
    }
    
    private func prepareForUpload() {
        guard let imageData = self.imageData,
            let titleText = self.titleTextField.text,
            let descriptionText = self.descriptionTextView.text else {
                return
        }
    }
    
    private func createPost() {
        self.performSegueWithIdentifier("segueUnwindToHomeVc", sender: self)
//        guard let imageData = self.imageData,
//            let titleText = self.titleTextField.text else {
//            return
//        }
//        FullScreenIndicator.show()
//        let title: String? = titleText.trimm().isEmpty ? nil : titleText.trimm()
//        let description: String? = self.descriptionTextView.text.trimm().isEmpty ? nil : self.descriptionTextView.text.trimm()
//        
//        AWSClientManager.defaultClientManager().createPost(imageData, title: title, description: description, isProfilePic: false, completionHandler: {
//            (task: AWSTask) in
//            dispatch_async(dispatch_get_main_queue(), {
//                FullScreenIndicator.hide()
//                if let error = task.error {
//                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
//                    self.presentViewController(alertController, animated: true, completion: nil)
//                } else {
//                    //self.redirectToWelcome()
//                }
//            })
//            return nil
//        })
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
