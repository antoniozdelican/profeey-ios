//
//  LocationsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

protocol LocationsTableViewControllerDelegate: class {
    func didSelectLocation(_ location: Location)
}

class LocationsTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var locationName: String?
    weak var locationsTableViewControllerDelegate: LocationsTableViewControllerDelegate?
    
    fileprivate var popularLocations: [Location] = []
    fileprivate var regularLocations: [Location] = []
    fileprivate var isSearchingPopularLocations: Bool = false
    fileprivate var isSearchingRegularLocations: Bool = false
    fileprivate var isShowingPopularLocations: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "SearchTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchTableSectionHeader")
        self.navigationItem.title = "Choose a place"
        
        // Configure SearchBar.
        self.searchBar.text = self.locationName
        self.searchBar.delegate = self
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.backgroundColor = Colors.greyLighter
        
        // Query.
        self.isShowingPopularLocations = true
        self.isSearchingPopularLocations = true
        self.scanLocations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isShowingPopularLocations {
            if self.isSearchingPopularLocations {
                return 1
            }
            if self.popularLocations.count == 0 {
                return 1
            }
            return self.popularLocations.count
        } else {
            if self.isSearchingRegularLocations {
                return 1
            }
            if self.regularLocations.count == 0 {
                return 1
            }
            return self.regularLocations.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isShowingPopularLocations {
            if self.isSearchingPopularLocations {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                cell.activityIndicator.startAnimating()
                // TODO update text.
                return cell
            }
            if self.popularLocations.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellLocation", for: indexPath) as! LocationTableViewCell
            let location = self.popularLocations[indexPath.row]
            cell.locationNameLabel.text = location.locationName
            cell.numberOfUsersLabel.text = location.numberOfUsersString
            return cell
        } else {
            if self.isSearchingRegularLocations {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                cell.activityIndicator.startAnimating()
                // TODO update text.
                return cell
            }
            if self.regularLocations.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellLocation", for: indexPath) as! LocationTableViewCell
            let location = self.regularLocations[indexPath.row]
            cell.locationNameLabel.text = location.locationName
            cell.numberOfUsersLabel.text = location.numberOfUsersString
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is LocationTableViewCell {
            let selectedLocation = self.isShowingPopularLocations ? self.popularLocations[indexPath.row] : self.regularLocations[indexPath.row]
            self.locationsTableViewControllerDelegate?.didSelectLocation(selectedLocation)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "searchTableSectionHeader") as? SearchTableSectionHeader
        header?.titleLabel.text = self.isShowingPopularLocations ? "POPULAR" : "BEST MATCHES"
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helpers
    
    fileprivate func filterLocations(_ namePrefix: String) {
        // Clear old.
        self.regularLocations = []
        self.regularLocations = self.popularLocations.filter({
            (location: Location) in
            if let searchCountry = location.country?.lowercased(), searchCountry.hasPrefix(namePrefix.lowercased()) {
                return true
            } else if let searchState = location.state?.lowercased(), searchState.hasPrefix(namePrefix.lowercased()) {
                return true
            } else if let searchCity = location.city?.lowercased(), searchCity.hasPrefix(namePrefix.lowercased()) {
                return true
            } else if let searchLocationName = location.locationName?.lowercased(), searchLocationName.hasPrefix(namePrefix.lowercased()) {
                return true
            } else {
                return false
            }
        })
        self.regularLocations = self.sortLocations(self.regularLocations)
        self.isSearchingRegularLocations = false
        self.tableView.reloadData()
    }
    
    fileprivate func sortLocations(_ locations: [Location]) -> [Location] {
        return locations.sorted(by: {
            (location1, location2) in
            return location1.numberOfUsersInt > location2.numberOfUsersInt
        })
    }
    
    // MARK: AWS
    
    fileprivate func scanLocations() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanLocationsDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingPopularLocations = false
                if let error = error {
                    print("scanLocations error: \(error)")
                    self.tableView.reloadData()
                } else {
                    guard let awsLocations = response?.items as? [AWSLocation] else {
                        self.tableView.reloadData()
                        return
                    }
                    for awsLocation in awsLocations {
                        let location = Location(locationId: awsLocation._locationId, country: awsLocation._country, state: awsLocation._state, city: awsLocation._city, latitude: awsLocation._latitude, longitude: awsLocation._longitude, numberOfUsers: awsLocation._numberOfUsers)
                        self.popularLocations.append(location)
                    }
                    self.popularLocations = self.sortLocations(self.popularLocations)
                    self.tableView.reloadData()
                }
            })
        })
    }
}

extension LocationsTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let locationName = searchText.trimm()
        if locationName.isEmpty {
            self.isShowingPopularLocations = true
            // Clear old.
            self.regularLocations = []
            self.isSearchingRegularLocations = false
            self.tableView.reloadData()
        } else {
            self.isShowingPopularLocations = false
            // Clear old.
            self.regularLocations = []
            self.isSearchingRegularLocations = true
            self.tableView.reloadData()
            // Start search.
            self.filterLocations(locationName)
        }
    }
}
