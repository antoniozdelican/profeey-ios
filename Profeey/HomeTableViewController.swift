//
//  HomeTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 16/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class HomeTableViewController: UITableViewController {
    
    // Get users that currentUser is following as well as currentUser.
    var users: [User]?
    // Get latest post from users.
    var posts: [Post]?
    
    var storedOffsets = [Int: CGFloat]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 120.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorColor = Colors.grey
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.posts = []
        
        if let currentUser = AWSClientManager.defaultClientManager().userPool?.currentUser() where currentUser.signedIn {
            
//            self.downloadAllUserPosts()
//            
//            let contentManager = AWSClientManager.defaultClientManager().contentManager
//            let content: AWSContent = contentManager!.contentWithKey("public/media/c5bf6e6b89bb476397b22f7840b24791.jpg")
//            content.downloadWithDownloadType(
//                .IfNewerExists,
//                pinOnCompletion: false,
//                progressBlock: {
//                    (content: AWSContent, progress: NSProgress) in
//                    return
//                },
//                completionHandler: {
//                (content: AWSContent?, data: NSData?, error: NSError?) in
//                    print(content)
//                    print(data?.length)
//                    print(error)
//                }
//            )
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController, let childViewController = navigationController.childViewControllers[0] as? PostDetailsTableViewController, let indexPath = sender as? NSIndexPath {
            let post = self.posts?[indexPath.row]
            childViewController.imageData = post?.mediaData
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let posts = self.posts {
            return posts.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellPost", forIndexPath: indexPath) as! PostTableViewCell
        let post = self.posts?[indexPath.row]
        cell.fullNameLabel.text = post?.user?.fullName
        cell.professionsLabel.text = post?.user?.professions?.joinWithSeparator(" · ")
        cell.timeLabel.text = post?.creationDate?.stringValue
        // Needs some checking if it's image!!
        if let imageData = post?.mediaData {
            cell.postImageView.image = UIImage(data: imageData)
        }
        cell.captionLabel.text = post?.caption
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? PostTableViewCell else {
            return
        }
        cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        cell.collectionViewOffset = self.storedOffsets[indexPath.row] ?? 0
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? PostTableViewCell else {
            return
        }
        self.storedOffsets[indexPath.row] = cell.collectionViewOffset
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("segueToPostDetailsVc", sender: indexPath)
    }
    
    // MARK: IBActions
    
    @IBAction func signOutButtonTapped(sender: AnyObject) {
        //AWSRemoteService.defaultRemoteService().signOut()
        AWSClientManager.defaultClientManager().signOut({
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
                let signInViewController = storyboard.instantiateInitialViewController()!
                self.presentViewController(signInViewController, animated: true, completion: nil)
            })
            return nil
        })

    }
    
    @IBAction func unwindToHomeTableViewController(segue: UIStoryboardSegue) {
        if segue.identifier == "segueUnwindToHomeVc", let sourceViewController = segue.sourceViewController as? EditTableViewController {
            guard let imageData = sourceViewController.photoData else {
                print("Error: no photo data.")
                return
            }
            let captionText = sourceViewController.captionTextView.text.trimm()
            let caption: String? = captionText.isEmpty ? nil : captionText
            // Start post upload.
            self.uploadPost(imageData, caption: caption, categories: sourceViewController.categories)
        }
        
    }
    
    // MARK: AWS
    
    private func downloadAllUserPosts() {
        print("DownloadAllUserPosts:")
        let userId = "bro"
        let aWSPostsPrimaryIndex = AWSPostsPrimaryIndex()
        aWSPostsPrimaryIndex.queryAllUserPosts(userId, completionHandler: {
            (response, error) in
            print("Response: \(response)")
            print(error)
        })

    }
    
    // MARK: AWS
    
    /*
     * This controller is responsible for actual upload and download of post(s)
    */
    
    private func uploadPost(imageData: NSData, caption: String?, categories: [String]?) {
        // postId will be passed in the download process.
        //let postId = NSUUID().UUIDString.lowercaseString.stringByReplacingOccurrencesOfString("-", withString: "")
        //FullScreenIndicator.show()
//        AWSRemoteService.defaultRemoteService().uploadPost(
//            postId,
//            mediaData: imageData,
//            caption: caption,
//            categories: categories,
//            progressBlock: {
//                (content: AWSLocalContent?, progress: NSProgress?) in
//                return
//            },
//            completionHandler: {
//                (task: AWSTask) in
//                dispatch_async(dispatch_get_main_queue(), {
//                    //FullScreenIndicator.hide()
//                    if let error = task.error {
//                        print("Upload post error:")
//                        print("\(error.localizedDescription)")
//                        let alertController = self.getSimpleAlertWithTitle("Something went wrong :(", message: error.localizedDescription, cancelButtonTitle: "Ok")
//                        self.presentViewController(alertController, animated: true, completion: nil)
//                    } else {
//                        print("Upload post success!")
//                        let user = CurrentUser()
//                        let post = Post(user: user, postId: postId, caption: caption, categories: categories, creationDate: nil, mediaUrl: nil, mediaData: imageData)
//                        self.insertPost(post)
//                    }
//                })
//                return nil
//        })
    }
    
    private func downloadPost(postId: String) {
        // This is executed in background.
        AWSRemoteService.defaultRemoteService().downloadPost(
            postId,
            completionHandler: {
                (task: AWSTask) in
                dispatch_async(dispatch_get_main_queue(), {
                    //FullScreenIndicator.hide()
                    if let error = task.error {
                        print("Upload post error:")
                        print("\(error.localizedDescription)")
                        let alertController = self.getSimpleAlertWithTitle("Something went wrong :(", message: error.localizedDescription, cancelButtonTitle: "Ok")
                        self.presentViewController(alertController, animated: true, completion: nil)
                    } else {
                        print("Download post success!")
                    }
                })
                return nil
        })
    }
    
    private func downloadAllUserPosts2() {
        print("DownloadAllUserPosts:")
        let userId = AWSClientManager.defaultClientManager().credentialsProvider!.identityId!
        let aWSPostsPrimaryIndex = AWSPostsPrimaryIndex()
        aWSPostsPrimaryIndex.queryAllUserPosts(userId, completionHandler: {
            (response, error) in
            print(response)
            print(error)
        })
        
    }
    
    private func downloadImageS3(mediaUrl: String, post: Post) {
//        AWSRemoteService.defaultRemoteService().downloadImageS3(
//            mediaUrl,
//            progressBlock: {
//                (content: AWSContent, progress: NSProgress) -> Void in
//                return
//            },
//            completionHandler: {
//                (content: AWSContent?, data: NSData?, error: NSError?) -> Void in
//                if let error = error {
//                    print("Error: \(error)")
//                } else if let data = data {
//                    post.mediaData = data
//                    dispatch_async(dispatch_get_main_queue(), {
//                        self.tableView.reloadData()
//                    })
//                } else {
//                    print("No data!")
//                }
//                return
//        })
    }
    
    // MARK: Helper
    
    private func insertPost(post: Post) {
        self.posts?.insert(post, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}

extension HomeTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let post = self.posts?[collectionView.tag], let categories = post.categories {
            return categories.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellPostCategory", forIndexPath: indexPath) as! PostCategoryCollectionViewCell
        let post = self.posts?[collectionView.tag]
        cell.categoryLabel.text = post?.categories?[indexPath.row]
        return cell
    }
}

extension HomeTableViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // Constants for post category cell size.
        let itemLabelHeight: CGFloat = 17.0
        let itemFont: UIFont = UIFont.systemFontOfSize(14.0)
        let topInset: CGFloat = 4.0
        let leftInset: CGFloat = 8.0
        let rightInset: CGFloat = 8.0
        
        if let post = self.posts?[collectionView.tag], let categories = post.categories {
            let item = categories[indexPath.row]
            let labelRect = NSString(string: item).boundingRectWithSize(CGSize(width: CGFloat(MAXFLOAT), height: itemLabelHeight), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: itemFont], context: nil)
            let cellWidth = ceil(labelRect.size.width) + leftInset + rightInset
            let cellHeight = ceil(labelRect.size.height) + 2 * topInset
            return CGSizeMake(cellWidth, cellHeight)
        } else {
            return CGSizeZero
        }
    }
}
