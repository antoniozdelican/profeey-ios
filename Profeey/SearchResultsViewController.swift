//
//  SearchResultsViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/08/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol SearchUsersDelegate {
    func toggleSearchUsers(users: [User], isSearching: Bool)
}

protocol SearchCategoriesDelegate {
    func toggleSearchCategories(categories: [Category], isSearching: Bool)
}

class SearchResultsViewController: UIViewController {

    @IBOutlet weak var indicatorScrollView: UIScrollView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var peopleImageView: UIImageView!
    @IBOutlet weak var peopleLabel: UILabel!
    @IBOutlet weak var categoriesImageView: UIImageView!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var segmentedControlView: UIView!
    
    var scrollViewDelegate: ScrollViewDelegate?
    var selectUserDelegate: SelectUserDelegate?
    var selectCategoryDelegate: SelectCategoryDelegate?
    
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
            destinationViewController.selectUserDelegate = self.selectUserDelegate
            self.searchUsersDelegate = destinationViewController
        }
        if let destinationViewController = segue.destinationViewController as? SearchCategoriesTableViewController {
            destinationViewController.scrollViewDelegate = self.scrollViewDelegate
            destinationViewController.selectCategoryDelegate = self.selectCategoryDelegate
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
    
    func toggleSearchUsers(users: [User], isSearching: Bool) {
        self.searchUsersDelegate?.toggleSearchUsers(users, isSearching: isSearching)
    }
    
    func toggleSearchCategories(categories: [Category], isSearching: Bool) {
        self.searchCategoriesDelegate?.toggleSearchCategories(categories, isSearching: isSearching)
    }
}
