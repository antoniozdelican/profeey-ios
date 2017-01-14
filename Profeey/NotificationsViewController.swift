//
//  NotificationsViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 09/01/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB

enum NotificationsSegmentType {
    case notifications
    case conversations
}

protocol NotificationsTableViewControllerDelegate {
    func scrollToTop()
}

protocol ConversationsTableViewControllerDelegate {
    func scrollToTop()
}

class NotificationsViewController: UIViewController {
    
    @IBOutlet var notificationsSegmentsView: UIView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var indicatorScrollView: UIScrollView!
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var conversationsButton: UIButton!
    
    var notificationsTableViewControllerDelegate: NotificationsTableViewControllerDelegate?
    var conversationsTableViewControllerDelegate: ConversationsTableViewControllerDelegate?
    
    var notifications: [PRFYNotification] = []
    var isLoadingNotifications: Bool = false
    var notificationsLastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    
    var conversations: [Conversation] = []
    var isLoadingConversations: Bool = false
    var conversationsLastEvaluatedKey: [String : AWSDynamoDBAttributeValue]?
    
    var noNetworkConnection: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // SegmentsView.
        Bundle.main.loadNibNamed("NotificationsSegmentsView", owner: self, options: nil)
        self.navigationItem.titleView = self.notificationsSegmentsView
        
        // ScrollView
        self.mainScrollView.delegate = self
        self.adjustSegment(NotificationsSegmentType.notifications)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.indicatorScrollView.contentOffset.x = -self.mainScrollView.contentOffset.x / 2
    }
    
    // TEST
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (self.tabBarController as? MainTabBarController)?.toggleNewNotificationsView(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? NotificationsTableViewController {
            self.notificationsTableViewControllerDelegate = destinationViewController
            destinationViewController.notifications = self.notifications
            destinationViewController.isLoadingNotifications = self.isLoadingNotifications
            destinationViewController.lastEvaluatedKey = self.notificationsLastEvaluatedKey
            destinationViewController.noNetworkConnection = self.noNetworkConnection
        }
        if let destinationViewController = segue.destination as? ConversationsTableViewController {
            self.conversationsTableViewControllerDelegate = destinationViewController
            destinationViewController.conversations = self.conversations
            destinationViewController.isLoadingConversations = self.isLoadingConversations
            destinationViewController.lastEvaluatedKey = self.conversationsLastEvaluatedKey
            destinationViewController.noNetworkConnection = self.noNetworkConnection
        }
    }
    
    // MARK: IBActions
    
    @IBAction func notificationsButtonTapped(_ sender: Any) {
        let rect = CGRect(x: 0.0, y: 0.0, width: self.mainScrollView.bounds.width, height: self.mainScrollView.bounds.height)
        self.mainScrollView.scrollRectToVisible(rect, animated: true)
    }
    
    @IBAction func conversationsButtonTapped(_ sender: Any) {
        let rect = CGRect(x: self.view.bounds.width, y: 0.0, width: self.mainScrollView.bounds.width, height: self.mainScrollView.bounds.height)
        self.mainScrollView.scrollRectToVisible(rect, animated: true)
    }
    
    // MARK: Helpers
    
    fileprivate func adjustSegment(_ notificationsSegmentType: NotificationsSegmentType) {
        switch notificationsSegmentType {
        case NotificationsSegmentType.notifications:
            if self.notificationsButton.currentTitleColor != Colors.black {
                self.notificationsButton.setTitleColor(Colors.black, for: UIControlState.normal)
                self.conversationsButton.setTitleColor(Colors.grey, for: UIControlState.normal)
            }
        case NotificationsSegmentType.conversations:
            if self.conversationsButton.currentTitleColor != Colors.black {
                self.conversationsButton.setTitleColor(Colors.black, for: UIControlState.normal)
                self.notificationsButton.setTitleColor(Colors.grey, for: UIControlState.normal)
            }
        }
    }
    
    // MARK: Public
    
    func notificationsTabBarButtonTapped() {
        self.notificationsTableViewControllerDelegate?.scrollToTop()
        self.conversationsTableViewControllerDelegate?.scrollToTop()
    }
}

extension NotificationsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.indicatorScrollView.contentOffset.x = -scrollView.contentOffset.x / 2
        if scrollView.contentOffset.x > scrollView.bounds.width / 2 {
            self.adjustSegment(NotificationsSegmentType.conversations)
        } else {
            self.adjustSegment(NotificationsSegmentType.notifications)
        }
    }
}
