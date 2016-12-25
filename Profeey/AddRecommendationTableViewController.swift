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
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profilePicImageView.layer.cornerRadius = 4.0
        self.profilePicImageView.clipsToBounds = true
        self.profilePicImageView.image = PRFYDynamoDBManager.defaultDynamoDBManager().currentUserDynamoDB?.profilePic
        self.postButton.isEnabled = false
        self.recommendationTextView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.recommendationTextView.becomeFirstResponder()
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
