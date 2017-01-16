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

protocol SearchUsersDelegate: class {
    func addLocation(_ location: Location)
    func removeLocation()
    func searchBarTextChanged(_ searchText: String)
    func scrollToTop()
}

protocol SearchProfessionsDelegate: class {
    func addLocation(_ location: Location)
    func removeLocation()
    func searchBarTextChanged(_ searchText: String)
    func scrollToTop()
}

class SearchViewController: UIViewController {

    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var indicatorScrollView: UIScrollView!
    @IBOutlet weak var peopleButton: UIButton!
    @IBOutlet weak var professionsButton: UIButton!
    
    fileprivate var searchBar = UISearchBar()
    fileprivate var locationBarButtonItem: UIBarButtonItem?
    fileprivate var isLocationActive: Bool = false
    fileprivate weak var searchUsersDelegate: SearchUsersDelegate?
    fileprivate weak var searchProfessionsDelegate: SearchProfessionsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // SearchBar configuration.
        self.searchBar.searchBarStyle = UISearchBarStyle.minimal
        self.searchBar.tintColor = Colors.black
        self.searchBar.placeholder = "Search"
        self.searchBar.delegate = self
        self.navigationItem.titleView = self.searchBar
        
        // BarButtonItem
        self.locationBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_location_off")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.locationBarButtonItemTapped(_:)))
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
            self.searchUsersDelegate = destinationViewController
        }
        if let destinationViewController = segue.destination as? SearchProfessionsTableViewController {
            destinationViewController.searchProfessionsTableViewControllerDelegate = self
            self.searchProfessionsDelegate = destinationViewController
        }
        if let navigationController = segue.destination as? UINavigationController,
            let childViewController = navigationController.childViewControllers[0] as? LocationsTableViewController {
            childViewController.locationsTableViewControllerDelegate = self
        }
    }
    
    // MARK: Tappers
    
    func locationBarButtonItemTapped(_ sender: Any) {
        if self.isLocationActive {
            self.isLocationActive = false
            self.locationBarButtonItem?.image = UIImage(named: "ic_location_off")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            self.searchBar.placeholder = "Search"
            self.searchUsersDelegate?.removeLocation()
            self.searchProfessionsDelegate?.removeLocation()
        } else {
            self.performSegue(withIdentifier: "segueToLocationsVc", sender: self)
        }
    }
    
    // From MainTabBarController to scroll to top.
    func searchTabBarButtonTapped() {
        self.searchUsersDelegate?.scrollToTop()
        self.searchProfessionsDelegate?.scrollToTop()
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
        self.searchUsersDelegate?.searchBarTextChanged(searchText)
        self.searchProfessionsDelegate?.searchBarTextChanged(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        self.navigationItem.setRightBarButton(self.locationBarButtonItem, animated: true)
        self.searchUsersDelegate?.searchBarTextChanged("")
        self.searchProfessionsDelegate?.searchBarTextChanged("")
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

extension SearchViewController: LocationsTableViewControllerDelegate {
    
    func didSelectLocation(_ location: Location) {
        guard let locationName = location.locationName else {
            return
        }
        self.isLocationActive = true
        self.locationBarButtonItem?.image = UIImage(named: "ic_location_active")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.searchBar.placeholder = "Search in \(locationName)"
        self.searchUsersDelegate?.addLocation(location)
        self.searchProfessionsDelegate?.addLocation(location)
    }
}
