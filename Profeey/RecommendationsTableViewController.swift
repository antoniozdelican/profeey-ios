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
    
    @IBOutlet var loadingTableFooterView: UIView!
    
    var userId: String?
    
    fileprivate var recommendations: [Recommendation] = []
    fileprivate var isLoadingRecommendations: Bool = false
    fileprivate var lastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    fileprivate var noNetworkConnection: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if let recommendingId = self.userId {
            // Query.
            self.isLoadingRecommendations = true
            self.tableView.tableFooterView = self.loadingTableFooterView
            self.queryRecommendationsDateSorted(recommendingId, startFromBeginning: true)
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
        if !self.isLoadingRecommendations && self.recommendations.count == 0 {
            return 1
        }
        return self.recommendations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !self.isLoadingRecommendations && self.recommendations.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! EmptyTableViewCell
            cell.emptyMessageLabel.text = "No recommendations yet."
            return cell
        }
        let recommendation = self.recommendations[indexPath.row]
        let user = recommendation.user
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellRecommendation", for: indexPath) as! RecommendationTableViewCell
        cell.profilePicImageView.image = user?.profilePicUrl != nil ? user?.profilePic : UIImage(named: "ic_no_profile_pic_feed")
        cell.preferredUsernameLabel.text = user?.preferredUsername
        cell.professionNameLabel.text = user?.professionName
        cell.createdLabel.text = recommendation.createdString
        cell.recommendationTextLabel.text = recommendation.recommendationText
        recommendation.isExpandedRecommendationText ? cell.untruncate() : cell.truncate()
        cell.recommendationTableViewCellDelegate = self
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        if !(cell is RecommendationTableViewCell) {
            cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
        }
        // Load next recommendations and reset tableFooterView.
        guard indexPath.row == self.recommendations.count - 1 && !self.isLoadingRecommendations && self.lastEvaluatedKey != nil else {
            return
        }
        guard let recommendingId = self.userId else {
            return
        }
        guard !self.noNetworkConnection else {
            return
        }
        self.isLoadingRecommendations = true
        self.tableView.tableFooterView = self.loadingTableFooterView
        self.queryRecommendationsDateSorted(recommendingId, startFromBeginning: false)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.recommendations.count == 0 {
            return 64.0
        }
        return 84.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.recommendations.count == 0 {
            return 64.0
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: IBActions
    
    @IBAction func refreshControlChanged(_ sender: AnyObject) {
        guard !self.isLoadingRecommendations else {
            self.refreshControl?.endRefreshing()
            return
        }
        guard let recommendingId = self.userId else {
            self.refreshControl?.endRefreshing()
            return
        }
        self.isLoadingRecommendations = true
        self.queryRecommendationsDateSorted(recommendingId, startFromBeginning: true)
    }
    
    // MARK: AWS
    
    fileprivate func queryRecommendationsDateSorted(_ recommendingId: String, startFromBeginning: Bool) {
        if startFromBeginning {
            self.lastEvaluatedKey = nil
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().queryRecommendationsDateSortedDynamoDB(recommendingId, lastEvaluatedKey: lastEvaluatedKey, completionHandler: {
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print("queryRecommendationsDateSorted error: \(error!)")
                    self.isLoadingRecommendations = false
                    self.refreshControl?.endRefreshing()
                    self.tableView.tableFooterView = UIView()
                    self.tableView.reloadData()
                    let nsError = error as! NSError
                    if nsError.code == -1009 {
                        (self.navigationController as? PRFYNavigationController)?.showBanner("No Internet Connection")
                        self.noNetworkConnection = true
                    }
                    return
                }
                if startFromBeginning {
                    self.recommendations = []
                }
                var numberOfNewRecommendations = 0
                if let awsRecommendations = response?.items as? [AWSRecommendation] {
                    for awsRecommendation in awsRecommendations {
                        let user = User(userId: awsRecommendation._userId, firstName: awsRecommendation._firstName, lastName: awsRecommendation._lastName, preferredUsername: awsRecommendation._preferredUsername, professionName: awsRecommendation._professionName, profilePicUrl: awsRecommendation._profilePicUrl)
                        let recommendation = Recommendation(userId: awsRecommendation._userId, recommendingId: awsRecommendation._recommendingId, recommendationText: awsRecommendation._recommendationText, created: awsRecommendation._created, user: user)
                        self.recommendations.append(recommendation)
                        numberOfNewRecommendations += 1
                    }
                }
                
                // Reset flags and animations that were initiated.
                self.isLoadingRecommendations = false
                self.refreshControl?.endRefreshing()
                self.noNetworkConnection = false
                self.lastEvaluatedKey = response?.lastEvaluatedKey
                self.tableView.tableFooterView = UIView()
                
                // Reload tableView.
                if startFromBeginning || numberOfNewRecommendations > 0 {
                    self.tableView.reloadData()
                }
                
                // Load profilePics.
                if let awsRecommendations = response?.items as? [AWSRecommendation] {
                    for awsRecommendation in awsRecommendations {
                        if let profilePicUrl = awsRecommendation._profilePicUrl {
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
            if let recommendationIndex = self.recommendations.index(of: recommendation) {
                // Update data source and cells.
                self.recommendations[recommendationIndex].user?.profilePic = UIImage(data: imageData)
                (self.tableView.cellForRow(at: IndexPath(row: recommendationIndex, section: 0)) as? RecommendationTableViewCell)?.profilePicImageView.image = self.recommendations[recommendationIndex].user?.profilePic
            }
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
            cell.untruncate()
            UIView.performWithoutAnimation {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
}
