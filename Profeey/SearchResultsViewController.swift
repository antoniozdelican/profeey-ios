//
//  SearchResultsViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol SearchUsersDelegate {
    func showUsers(users: [User])
    func toggleSearchingIndicator(show: Bool)
}

protocol SearchCategoriesDelegate {
    func showCategories(categories: [Category])
    func toggleSearchingIndicator(show: Bool)
}

class SearchResultsViewController: UIViewController {

    @IBOutlet weak var indicatorScrollView: UIScrollView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var peopleImageView: UIImageView!
    @IBOutlet weak var peopleLabel: UILabel!
    @IBOutlet weak var categoriesImageView: UIImageView!
    @IBOutlet weak var categoriesLabel: UILabel!
    
    // TEST
    @IBOutlet weak var segmentedControlView: UIView!
    
    var scrollViewDelegate: ScrollViewDelegate?
    var selectUserDelegate: SelectUserDelegate?
    private var searchUsersDelegate: SearchUsersDelegate?
    private var searchCategoriesDelegate: SearchCategoriesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainScrollView.delegate = self
        self.adjustSegment(0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.indicatorScrollView.contentOffset.x = -self.mainScrollView.contentOffset.x / 2
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? SearchUsersTableViewController {
            destinationViewController.scrollViewDelegate = self.scrollViewDelegate
            self.searchUsersDelegate = destinationViewController
            destinationViewController.selectUserDelegate = self.selectUserDelegate
        }
        if let destinationViewController = segue.destinationViewController as? SearchCategoriesTableViewController {
            destinationViewController.scrollViewDelegate = self.scrollViewDelegate
            self.searchCategoriesDelegate = destinationViewController
        }
    }
    
    // MARK: IBActions
    
    @IBAction func peopleSegmentTapped(sender: AnyObject) {
        let rect = CGRectMake(0.0, 0.0, self.mainScrollView.bounds.width, self.mainScrollView.bounds.height)
        self.mainScrollView.scrollRectToVisible(rect, animated: true)
    }
    
    @IBAction func categoriesSegmentTapped(sender: AnyObject) {
        let rect = CGRectMake(self.view.bounds.width, 0.0, self.mainScrollView.bounds.width, self.mainScrollView.bounds.height)
        self.mainScrollView.scrollRectToVisible(rect, animated: true)
    }
    
    
    // MARK: Helper
    
    private func adjustSegment(segmentIndex: Int) {
        switch segmentIndex {
        case 0:
            if self.peopleLabel.textColor != Colors.black {
                self.peopleImageView.image = UIImage(named: "ic_people_black")
                self.peopleLabel.textColor = Colors.black
                self.categoriesImageView.image = UIImage(named: "ic_categories_grey")
                self.categoriesLabel.textColor = Colors.greyDark
            }
            
        default:
            if self.categoriesLabel.textColor != Colors.black {
                self.peopleImageView.image = UIImage(named: "ic_people_grey")
                self.peopleLabel.textColor = Colors.greyDark
                self.categoriesImageView.image = UIImage(named: "ic_categories_black")
                self.categoriesLabel.textColor = Colors.black
            }
        }
    }
}

extension SearchResultsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.indicatorScrollView.contentOffset.x = -scrollView.contentOffset.x / 2
        
        if scrollView.contentOffset.x > scrollView.bounds.width / 2 {
            self.adjustSegment(1)
        } else {
            self.adjustSegment(0)
        }
    }
}

extension SearchResultsViewController: SearchDelegate {
    
    func showUsers(users: [User]) {
        self.searchUsersDelegate?.showUsers(users)
    }
    
    func showCategories(categories: [Category]) {
        self.searchCategoriesDelegate?.showCategories(categories)
    }
    
    func toggleSearchingIndicator(show: Bool) {
        self.searchUsersDelegate?.toggleSearchingIndicator(show)
        self.searchCategoriesDelegate?.toggleSearchingIndicator(show)
    }
}
