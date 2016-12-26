//
//  FollowersFollowingViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

enum UsersSegmentType {
    case followers
    case following
}

class FollowersFollowingViewController: UIViewController {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var indicatorScrollView: UIScrollView!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    
    var userId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "ic_followers_following_screen"))
        
        // ScrollView
        self.mainScrollView.delegate = self
        self.adjustSegment(UsersSegmentType.followers)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.indicatorScrollView.contentOffset.x = -self.mainScrollView.contentOffset.x / 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? UsersTableViewController, segue.identifier == "segueToFollowersVc" {
            print("segueToFollowersVc")
            destinationViewController.usersType = UsersType.followers
            destinationViewController.userId = self.userId
        }
        if let destinationViewController = segue.destination as? UsersTableViewController, segue.identifier == "segueToFollowingVc" {
            print("segueToFollowingVc")
            destinationViewController.usersType = UsersType.following
            destinationViewController.userId = self.userId
        }
    }
    
    // MARK: IBActions
    
    @IBAction func followersButtonTapped(_ sender: Any) {
        let rect = CGRect(x: 0.0, y: 0.0, width: self.mainScrollView.bounds.width, height: self.mainScrollView.bounds.height)
        self.mainScrollView.scrollRectToVisible(rect, animated: true)
    }
    
    @IBAction func followingButtonTapped(_ sender: Any) {
        let rect = CGRect(x: self.view.bounds.width, y: 0.0, width: self.mainScrollView.bounds.width, height: self.mainScrollView.bounds.height)
        self.mainScrollView.scrollRectToVisible(rect, animated: true)
    }
    
    // MARK: Helpers
    
    fileprivate func adjustSegment(_ usersSegmentType: UsersSegmentType) {
        switch usersSegmentType {
        case UsersSegmentType.followers:
            if self.followersButton.currentTitleColor != Colors.black {
                self.followersButton.setTitleColor(Colors.black, for: UIControlState.normal)
                self.followingButton.setTitleColor(Colors.grey, for: UIControlState.normal)
            }
        case UsersSegmentType.following:
            if self.followingButton.currentTitleColor != Colors.black {
                self.followingButton.setTitleColor(Colors.black, for: UIControlState.normal)
                self.followersButton.setTitleColor(Colors.grey, for: UIControlState.normal)
            }
        }
    }
}

extension FollowersFollowingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.indicatorScrollView.contentOffset.x = -scrollView.contentOffset.x / 2
        if scrollView.contentOffset.x > scrollView.bounds.width / 2 {
            self.adjustSegment(UsersSegmentType.following)
        } else {
            self.adjustSegment(UsersSegmentType.followers)
        }
    }
}
