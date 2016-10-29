//
//  SearchViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

protocol SearchUsersDelegate {
    func showUsers(_ users: [User], showAllUsers: Bool)
    func isSearchingUsers(_ isSearching: Bool)
}

protocol SearchProfessionsDelegate {
    func showProfessions(_ professions: [Profession], showAllProfessions: Bool)
    func isSearchingProfessions(_ isSearching: Bool)
}

protocol SearchScrollDelegate {
    func scrollViewWillBeginDragging()
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var indicatorScrollView: UIScrollView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var peopleLabel: UILabel!
    @IBOutlet weak var professionsLabel: UILabel!
    @IBOutlet weak var segmentedControlView: UIView!
    
    fileprivate var searchController: UISearchController?
    fileprivate var searchUsersDelegate: SearchUsersDelegate?
    fileprivate var searchProfessionsDelegate: SearchProfessionsDelegate?
    
    fileprivate var users: [User] = []
    fileprivate var allUsers: [User] = []
    fileprivate var searchedUsers: [User] = []
    
    fileprivate var professions: [Profession] = []
    fileprivate var allProfessions: [Profession] = []
    fileprivate var searchedProfessions: [Profession] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.configureSearchController()
        self.mainScrollView.delegate = self
        self.adjustSegment(0)
        
        self.searchUsersDelegate?.isSearchingUsers(true)
        self.scanUsers()
        self.searchProfessionsDelegate?.isSearchingProfessions(true)
        self.scanProfessions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.indicatorScrollView.contentOffset.x = -self.mainScrollView.contentOffset.x / 2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.hidesNavigationBarDuringPresentation = false
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.searchController?.searchBar.delegate = self
        self.definesPresentationContext = true
        self.navigationItem.titleView = self.searchController?.searchBar
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? SearchUsersTableViewController {
            self.searchUsersDelegate = destinationViewController
            destinationViewController.searchScrollDelegate = self
            destinationViewController.searchUsersTableViewControllerDelegate = self
        }
        if let destinationViewController = segue.destination as? SearchProfessionsTableViewController {
            self.searchProfessionsDelegate = destinationViewController
            destinationViewController.searchScrollDelegate = self
            destinationViewController.searchProfessionsTableViewControllerDelegate = self
        }
        if let destinationViewController = segue.destination as? ProfileTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.user = self.users[indexPath.row]
        }
        if let destinationViewController = segue.destination as? ProfessionTableViewController,
            let indexPath = sender as? IndexPath {
            destinationViewController.profession = self.professions[indexPath.row]
        }
    }
    
    // MARK: IBActions
    
    @IBAction func peopleSegmentTapped(_ sender: AnyObject) {
        let rect = CGRect(x: 0.0, y: 0.0, width: self.mainScrollView.bounds.width, height: self.mainScrollView.bounds.height)
        self.mainScrollView.scrollRectToVisible(rect, animated: true)
    }
    
    @IBAction func professionsSegmentTapped(_ sender: AnyObject) {
        let rect = CGRect(x: self.view.bounds.width, y: 0.0, width: self.mainScrollView.bounds.width, height: self.mainScrollView.bounds.height)
        self.mainScrollView.scrollRectToVisible(rect, animated: true)
    }
    
    // MARK: AWS
    
    fileprivate func scanUsers() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanUsersDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.searchUsersDelegate?.isSearchingUsers(false)
                if let error = error {
                    print("scanUsers error: \(error)")
                    self.searchUsersDelegate?.showUsers(self.users, showAllUsers: true)
                } else {
                    guard let awsUsers = response?.items as? [AWSUser] else {
                        self.searchUsersDelegate?.showUsers(self.users, showAllUsers: true)
                        return
                    }
                    for awsUser in awsUsers {
                        let user = User(userId: awsUser._userId, firstName: awsUser._firstName, lastName: awsUser._lastName, preferredUsername: awsUser._preferredUsername, professionName: awsUser._professionName, profilePicUrl: awsUser._profilePicUrl, locationName: awsUser._locationName)
                        self.allUsers.append(user)
                    }
                    
                    // If there is text already in text field, do the filter.
                    if let searchText = self.searchController?.searchBar.text, !searchText.isEmpty {
                        self.filterUsers(searchText)
                    } else {
                        self.users = self.allUsers
                        self.searchUsersDelegate?.showUsers(self.users, showAllUsers: true)
                    }
                }
            })
        })
    }
    
    fileprivate func scanProfessions() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanProfessionsDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.searchProfessionsDelegate?.isSearchingProfessions(false)
                if let error = error {
                    print("scanProfessions error: \(error)")
                    self.searchProfessionsDelegate?.showProfessions(self.professions, showAllProfessions: true)
                } else {
                    guard let awsProfessions = response?.items as? [AWSProfession] else {
                        self.searchProfessionsDelegate?.showProfessions(self.professions, showAllProfessions: true)
                        return
                    }
                    for awsProfession in awsProfessions {
                        let profession = Profession(professionName: awsProfession._professionName, searchProfessionName: awsProfession._searchProfessionName, numberOfUsers: awsProfession._numberOfUsers)
                        self.allProfessions.append(profession)
                    }
                    
                    // If there is text already in text field, do the filter.
                    if let searchText = self.searchController?.searchBar.text, !searchText.isEmpty {
                        self.filterProfessions(searchText)
                    } else {
                        self.professions = self.allProfessions
                        self.searchProfessionsDelegate?.showProfessions(self.professions, showAllProfessions: true)
                    }
                }
            })
        })
    }
    
    // MARK: Helpers
    
    fileprivate func adjustSegment(_ segmentIndex: Int) {
        switch segmentIndex {
        case 0:
            if self.peopleLabel.textColor != Colors.black {
                self.peopleLabel.textColor = Colors.black
                self.professionsLabel.textColor = Colors.greyDark
            }
        case 1:
            if self.professionsLabel.textColor != Colors.black {
                self.peopleLabel.textColor = Colors.greyDark
                self.professionsLabel.textColor = Colors.black
            }
        default:
            return
        }
    }
    
    fileprivate func filterUsers(_ searchText: String) {
        let searchName = searchText.lowercased()
        self.searchedUsers = self.allUsers.filter({
            (user: User) in
            if let searchFirstName = user.searchFirstName, searchFirstName.hasPrefix(searchName) {
                return true
            } else if let searchLastName = user.searchLastName, searchLastName.hasPrefix(searchName) {
                return true
            } else if let searchPreferredUsername = user.searchPreferredUsername, searchPreferredUsername.hasPrefix(searchName) {
                return true
            } else {
                return false
            }
        })
        self.users = self.searchedUsers
        self.searchUsersDelegate?.showUsers(self.users, showAllUsers: false)
    }
    
    fileprivate func filterProfessions(_ searchText: String) {
        let searchProfessionName = searchText.lowercased()
        let searchableProfessions = self.allProfessions.filter( { $0.searchProfessionName != nil } )
        
        self.searchedProfessions = searchableProfessions.filter( { $0.searchProfessionName!.hasPrefix(searchProfessionName) } )
        self.professions = self.searchedProfessions
        self.searchProfessionsDelegate?.showProfessions(self.professions, showAllProfessions: false)
    }
}

extension SearchViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.indicatorScrollView.contentOffset.x = -scrollView.contentOffset.x / 2
        if scrollView.contentOffset.x > scrollView.bounds.width / 2 {
            self.adjustSegment(1)
        } else {
            self.adjustSegment(0)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.trimm().isEmpty {
            self.users = self.allUsers
            self.searchUsersDelegate?.showUsers(self.users, showAllUsers: true)
            
            self.professions = self.allProfessions
            self.searchProfessionsDelegate?.showProfessions(self.professions, showAllProfessions: true)
        } else {
            self.filterUsers(searchText.trimm())
            self.filterProfessions(searchText.trimm())
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.users = self.allUsers
        self.searchUsersDelegate?.showUsers(self.users, showAllUsers: true)
        
        self.professions = self.allProfessions
        self.searchProfessionsDelegate?.showProfessions(self.professions, showAllProfessions: true)
    }
}

extension SearchViewController: SearchScrollDelegate {
    
    func scrollViewWillBeginDragging() {
        self.searchController?.searchBar.resignFirstResponder()
    }
}

extension SearchViewController: SearchUsersTableViewControllerDelegate {
    
    func didSelectUser(_ indexPath: IndexPath) {
        self.performSegue(withIdentifier: "segueToProfileVc", sender: indexPath)
    }
}

extension SearchViewController: SearchProfessionsTableViewControllerDelegate {
    
    func didSelectProfession(_ indexPath: IndexPath) {
        self.performSegue(withIdentifier: "segueToProfessionVc", sender: indexPath)
    }
}
