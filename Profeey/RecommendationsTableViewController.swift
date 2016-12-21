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
    
    var user: User?
    
    fileprivate var recommendations: [Recommendation] = []
    fileprivate var isLoadingRecommendations: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if let recommendingId = self.user?.userId {
            self.isLoadingRecommendations = true
            self.queryRecommendationsDateSorted(recommendingId)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let cell = sender as? RecommendationTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            
            // TODO: refactor copy
            destinationViewController.user = self.recommendations[indexPath.row].user
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
        cell.profilePicImageView.image = user?.profilePic
        cell.preferredUsernameLabel.text = user?.preferredUsername
        cell.professionNameLabel.text = user?.professionName
        cell.timeLabel.text = recommendation.creationDateString
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
        return 89.0
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
                        let recommendation = Recommendation(userId: awsRecommendation._userId, recommendingId: awsRecommendation._recommendingId, recommendationText: awsRecommendation._recommendationText, creationDate: awsRecommendation._creationDate, user: user)
                        self.recommendations.append(recommendation)
                    }
                    self.tableView.reloadData()
                    for (index, recommendation) in self.recommendations.enumerated() {
                        if let profilePicUrl = recommendation.user?.profilePicUrl {
                            let indexPath = IndexPath(row: index, section: 0)
                            self.downloadImage(profilePicUrl, imageType: .userProfilePic, indexPath: indexPath)
                        }
                    }
                }
            })
        })
    }
    
    fileprivate func downloadImage(_ imageKey: String, imageType: ImageType, indexPath: IndexPath) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let content = AWSUserFileManager.defaultUserFileManager().content(withKey: imageKey)
        // TODO check if content.isImage()
        if content.isCached {
            print("Content cached:")
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            let image = UIImage(data: content.cachedData)
            switch imageType {
            case .userProfilePic:
                self.recommendations[indexPath.row].user?.profilePic = image
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            default:
                return
            }
        } else {
            print("Download content:")
            content.download(
                with: AWSContentDownloadType.ifNewerExists,
                pinOnCompletion: false,
                progressBlock: {
                    (content: AWSContent?, progress: Progress?) -> Void in
                    // TODO
                },
                completionHandler: {
                    (content: AWSContent?, data: Data?, error: Error?) in
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if let error = error {
                            print("downloadImage error: \(error)")
                        } else {
                            guard let imageData = data else {
                                return
                            }
                            let image = UIImage(data: imageData)
                            switch imageType {
                            case .userProfilePic:
                                self.recommendations[indexPath.row].user?.profilePic = image
                                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                            default:
                                return
                            }
                        }
                    })
            })
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
