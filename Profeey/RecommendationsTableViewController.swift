//
//  RecommendationsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 15/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class RecommendationsTableViewController: UITableViewController {
    
    var userId: String?
    
    fileprivate var recommendations: [Recommendation] = []
    fileprivate var isLoadingRecommendations: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if let recommendingId = self.userId {
            self.isLoadingRecommendations = true
            self.queryRecommendationsDateSorted(recommendingId)
        }
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImageNotification(_:)), name: NSNotification.Name(DownloadImageNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let cell = sender as? RecommendationTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            destinationViewController.user = self.recommendations[indexPath.row].user?.copyUser()
        }
    }
    

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoadingRecommendations {
            return 1
        }
        if self.recommendations.count == 0 {
            return 1
        }
        return self.recommendations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoadingRecommendations {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellLoading", for: indexPath) as! LoadingTableViewCell
            cell.activityIndicator?.startAnimating()
            return cell
        }
        if self.recommendations.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! EmptyTableViewCell
            cell.emptyMessageLabel.text = "No recommendations yet"
            return cell
        }
        let recommendation = self.recommendations[indexPath.row]
        let user = recommendation.user
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellRecommendation", for: indexPath) as! RecommendationTableViewCell
        cell.profilePicImageView.image = user?.profilePicUrl != nil ? user?.profilePic : UIImage(named: "ic_no_profile_pic_feed")
        cell.preferredUsernameLabel.text = user?.preferredUsername
        cell.professionNameLabel.text = user?.professionName
        cell.timeLabel.text = recommendation.createdString
        cell.recommendationTextLabel.text = recommendation.recommendationText
        recommendation.isExpandedRecommendationText ? cell.untruncate() : cell.truncate()
        cell.recommendationTableViewCellDelegate = self
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if !(cell is RecommendationTableViewCell) {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingRecommendations || self.recommendations.count == 0 {
            return 112
        }
        return 87.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isLoadingRecommendations || self.recommendations.count == 0 {
            return 112
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: AWS
    
    fileprivate func queryRecommendationsDateSorted(_ recommendingId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryRecommendationsDateSortedDynamoDB(recommendingId, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isLoadingRecommendations = false
                if let error = error {
                    print("queryRecommendationsDateSorted error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsRecommendations = response?.items as? [AWSRecommendation] else {
                        self.tableView.reloadData()
                        return
                    }
                    for awsRecommendation in awsRecommendations {
                        let user = User(userId: awsRecommendation._userId, firstName: awsRecommendation._firstName, lastName: awsRecommendation._lastName, preferredUsername: awsRecommendation._preferredUsername, professionName: awsRecommendation._professionName, profilePicUrl: awsRecommendation._profilePicUrl)
                        let recommendation = Recommendation(userId: awsRecommendation._userId, recommendingId: awsRecommendation._recommendingId, recommendationText: awsRecommendation._recommendationText, created: awsRecommendation._created, user: user)
                        self.recommendations.append(recommendation)
                    }
                    self.tableView.reloadData()
                    for recommendation in self.recommendations {
                        if let profilePicUrl = recommendation.user?.profilePicUrl {
                            PRFYS3Manager.defaultS3Manager().downloadImageS3(profilePicUrl, imageType: .userProfilePic)
                        }
                    }
                }
            })
        })
    }
}

extension RecommendationsTableViewController {
    
    // MARK: NotificationCenterActions
    
    func downloadImageNotification(_ notification: NSNotification) {
        guard let imageKey = notification.userInfo?["imageKey"] as? String, let imageType = notification.userInfo?["imageType"] as? ImageType, let imageData = notification.userInfo?["imageData"] as? Data else {
            return
        }
        guard imageType == .userProfilePic else {
            return
        }
        for recommendation in self.recommendations.filter( { $0.user?.profilePicUrl == imageKey } ) {
            guard let recommendationIndex = self.recommendations.index(of: recommendation) else {
                continue
            }
            self.recommendations[recommendationIndex].user?.profilePic = UIImage(data: imageData)
            self.tableView.reloadRows(at: [IndexPath(row: recommendationIndex, section: 0)], with: UITableViewRowAnimation.none)
        }
    }
}

extension RecommendationsTableViewController: RecommendationTableViewCellDelegate {
    
    func userTapped(_ cell: RecommendationTableViewCell) {
        self.performSegue(withIdentifier: "segueToProfileVc", sender: cell)
    }
    
    func recommendationTextLabelTapped(_ cell: RecommendationTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        if !self.recommendations[indexPath.row].isExpandedRecommendationText {
            self.recommendations[indexPath.row].isExpandedRecommendationText = true
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }
        }
    }
}
