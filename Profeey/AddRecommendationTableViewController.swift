//
//  AddRecommendationTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 14/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class AddRecommendationTableViewController: UITableViewController {

    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var recommendationTextView: UITextView!
    @IBOutlet weak var recommendationFakePlaceholderLabel: UILabel!
    
    // Before numberOfPosts is loaded.
    fileprivate var isLoadingNumberOfPosts: Bool = false
    fileprivate var activityIndicatorView: UIActivityIndicatorView?
    fileprivate var noNetworkConnection: Bool = false
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        self.profilePicImageView.image = PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB?.profilePic
        self.postButton.isEnabled = false
        self.recommendationTextView.delegate = self
        self.recommendationFakePlaceholderLabel.text = ""
        
        // Set background views.
        self.activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.tableView.backgroundView = self.activityIndicatorView
        
        // Disable textView until loaded numberOfPosts.
        self.recommendationTextView.isEditable = false
        self.isLoadingNumberOfPosts = true
        self.activityIndicatorView?.startAnimating()
        self.getNumberOfPosts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 72.0
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    // MARK: IBActions
    
    @IBAction func tableViewTapped(_ sender: AnyObject) {
        if !self.recommendationTextView.isFirstResponder {
            self.recommendationTextView.becomeFirstResponder()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.createRecommendation(self.recommendationTextView.text)
    }
    
    // MARK: AWS
    
    fileprivate func getNumberOfPosts() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().getUserNumberOfPostsDynamoDB({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard task.error == nil else {
                    print("getNumberOfPosts error: \(task.error!)")
                    self.isLoadingNumberOfPosts = false
                    self.activityIndicatorView?.stopAnimating()
                    // Handle error and show banner.
                    if (task.error as! NSError).code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                    }
                    self.tableView.reloadData()
                    return
                }
                // Reset flags and animations that were initiated.
                self.isLoadingNumberOfPosts = false
                self.activityIndicatorView?.stopAnimating()
                
                // Allow only user with 5 or more posts to recommend.
                if let awsUserNumberOfPosts = task.result as? AWSUserNumberOfPosts, let numberOfPosts = awsUserNumberOfPosts._numberOfPosts, numberOfPosts.intValue >= 5 {
                    self.recommendationTextView.isEditable = true
                    if let preferredUsername = self.user?.preferredUsername {
                       self.recommendationFakePlaceholderLabel.text = "Write a recommendation to \(preferredUsername)"
                    } else {
                       self.recommendationFakePlaceholderLabel.text = "Write a recommendation..."
                    }
                    self.recommendationTextView.becomeFirstResponder()
                } else {
                    self.recommendationFakePlaceholderLabel.text = "To give a recommendation, you need to be an experienced Profeey with at least 5 posts!"
                }
                UIView.performWithoutAnimation {
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
            })
            return nil
        })
    }
    
    fileprivate func createRecommendation(_ recommendationText: String) {
        guard let recommendingId = self.user?.userId else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        PRFYDynamoDBManager.defaultDynamoDBManager().createRecommendationDynamoDB(recommendingId, recommendationText: recommendationText, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("createRecommendation error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: RecommendUserNotificationKey), object: self, userInfo: ["recommendingId": recommendingId])
                    self.dismiss(animated: true, completion: nil)
                }
            })
            return nil
        })
    }
}

extension AddRecommendationTableViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.recommendationFakePlaceholderLabel.isHidden = !textView.text.isEmpty
        self.postButton.isEnabled = !textView.text.trimm().isEmpty
        
        // Changing height of the cell
        let currentOffset = self.tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        self.tableView.setContentOffset(currentOffset, animated: false)
    }
}
