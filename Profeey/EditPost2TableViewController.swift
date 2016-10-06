//
//  EditPost2TableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class EditPost2TableViewController: UITableViewController {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionFakePlaceholderLabel: UILabel!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var removeCategoryButton: UIButton!
    @IBOutlet weak var addCategoryTableViewCell: UITableViewCell!
    
    var finalImage: UIImage?
    // Properties that will be passed to HomeVc through delegation.
    var imageData: Data?
    var caption: String?
    var categoryName: String?
    
    fileprivate var categoryAdded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.thumbnailImageView.image = self.finalImage
        if let finalImage = self.finalImage {
            self.imageData = UIImageJPEGRepresentation(finalImage, 0.6)
        }
        self.descriptionTextView.delegate = self
        self.removeCategoryButton.isHidden = true
        
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        if let destinationViewController = segue.destination as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? CategoriesTableViewController {
            if self.categoryNameLabel.textColor == Colors.blue {
                //childViewController.categoryName = self.categoryNameLabel.text
            }
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell == self.addCategoryTableViewCell && !self.categoryAdded {
            self.performSegue(withIdentifier: "segueToCategoriesVc", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func postButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        guard let captionText = self.descriptionTextView.text else {
                return
        }
        
        self.caption = captionText.trimm().isEmpty ? nil: captionText.trimm()
        
        // Upload is on HomeVc.
        self.performSegue(withIdentifier: "segueUnwindToHomeVc", sender: self)
    }
    
    @IBAction func removeCategoryButtonTapped(_ sender: AnyObject) {
        self.categoryName = nil
        self.removeCategoryButton.isHidden = true
        self.categoryNameLabel.text = "Add Skill"
        self.categoryNameLabel.textColor = Colors.black
        // Allow segueToCategoriesVc.
        self.categoryAdded = false
        self.addCategoryTableViewCell.selectionStyle = UITableViewCellSelectionStyle.default
    }
    
    @IBAction func unwindToEditPost2TableViewController(_ segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? CategoriesTableViewController {
//            guard let categoryName = sourceViewController.categoryName else {
//                return
//            }
//            if categoryName.isEmpty {
//                self.categoryName = nil
//                self.categoryNameLabel.text = "Add Skill"
//                self.categoryNameLabel.textColor = Colors.black
//                self.removeCategoryButton.isHidden = true
//                self.categoryAdded = false
//                self.addCategoryTableViewCell.selectionStyle = UITableViewCellSelectionStyle.default
//            } else {
//                self.categoryName = categoryName
//                self.categoryNameLabel.text = categoryName
//                self.categoryNameLabel.textColor = Colors.blue
//                self.removeCategoryButton.isHidden = false
//                self.categoryAdded = true
//                self.addCategoryTableViewCell.selectionStyle = UITableViewCellSelectionStyle.none
//            }
        }
    }
}

extension EditPost2TableViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.descriptionFakePlaceholderLabel.isHidden = !textView.text.isEmpty
        
        // Changing height of the cell
        let currentOffset = self.tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        self.tableView.setContentOffset(currentOffset, animated: false)
    }
}
