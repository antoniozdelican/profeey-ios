//
//  SearchViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 02/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

enum SearchSegmentType {
    case people
    case professions
}

class SearchViewController: UIViewController {

    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var indicatorScrollView: UIScrollView!
    @IBOutlet weak var peopleButton: UIButton!
    @IBOutlet weak var professionsButton: UIButton!
    
    fileprivate var searchBar = UISearchBar()
    fileprivate var locationBarButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // SearchBar configuration.
        self.searchBar.searchBarStyle = UISearchBarStyle.minimal
        self.searchBar.tintColor = Colors.black
        self.searchBar.placeholder = "Search in Zagreb, Croatia"
        self.searchBar.delegate = self
        self.navigationItem.titleView = self.searchBar
        
        // BarButtonItem
        self.locationBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_location_off")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationItem.setRightBarButton(self.locationBarButtonItem, animated: true)
        
        // ScrollView
        self.mainScrollView.delegate = self
        self.adjustSegment(SearchSegmentType.people)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.indicatorScrollView.contentOffset.x = -self.mainScrollView.contentOffset.x / 2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? SearchUsersTableViewController {
            destinationViewController.searchUsersTableViewControllerDelegate = self
//            self.searchUsersDelegate = destinationViewController
//            destinationViewController.searchScrollDelegate = self
//            destinationViewController.searchUsersTableViewControllerDelegate = self
        }
        if let destinationViewController = segue.destination as? SearchProfessionsTableViewController {
            destinationViewController.searchProfessionsTableViewControllerDelegate = self
//            self.searchProfessionsDelegate = destinationViewController
//            destinationViewController.searchScrollDelegate = self
//            destinationViewController.searchProfessionsTableViewControllerDelegate = self
        }
//        if let destinationViewController = segue.destination as? ProfileTableViewController,
//            let indexPath = sender as? IndexPath {
//            destinationViewController.user = self.users[indexPath.row]
//        }
//        if let destinationViewController = segue.destination as? ProfessionTableViewController,
//            let indexPath = sender as? IndexPath {
//            destinationViewController.profession = self.professions[indexPath.row]
//        }
    }
    
    // MARK: IBActions
    
    @IBAction func peopleButtonTapped(_ sender: Any) {
        let rect = CGRect(x: 0.0, y: 0.0, width: self.mainScrollView.bounds.width, height: self.mainScrollView.bounds.height)
        self.mainScrollView.scrollRectToVisible(rect, animated: true)
    }
    
    @IBAction func professionButtonTapped(_ sender: Any) {
        let rect = CGRect(x: self.view.bounds.width, y: 0.0, width: self.mainScrollView.bounds.width, height: self.mainScrollView.bounds.height)
        self.mainScrollView.scrollRectToVisible(rect, animated: true)
    }
    
    // MARK: Helpers
    
    fileprivate func adjustSegment(_ searchSegmentType: SearchSegmentType) {
        switch searchSegmentType {
        case SearchSegmentType.people:
            if self.peopleButton.currentTitleColor != Colors.black {
                self.peopleButton.setTitleColor(Colors.black, for: UIControlState.normal)
                self.professionsButton.setTitleColor(Colors.grey, for: UIControlState.normal)
            }
        case SearchSegmentType.professions:
            if self.professionsButton.currentTitleColor != Colors.black {
                self.professionsButton.setTitleColor(Colors.black, for: UIControlState.normal)
                self.peopleButton.setTitleColor(Colors.grey, for: UIControlState.normal)
            }
        }
    }
}

extension SearchViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.indicatorScrollView.contentOffset.x = -scrollView.contentOffset.x / 2
        if scrollView.contentOffset.x > scrollView.bounds.width / 2 {
            self.adjustSegment(SearchSegmentType.professions)
        } else {
            self.adjustSegment(SearchSegmentType.people)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        self.navigationItem.setRightBarButton(self.locationBarButtonItem, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationItem.setRightBarButton(nil, animated: true)
        searchBar.setShowsCancelButton(true, animated: true)
    }
}

extension SearchViewController: SearchUsersTableViewControllerDelegate {
    
    func usersTableViewWillBeginDragging() {
        self.searchBar.resignFirstResponder()
    }
}

extension SearchViewController: SearchProfessionsTableViewControllerDelegate {
    
    func professionsTableViewWillBeginDragging() {
        self.searchBar.resignFirstResponder()
    }
}
