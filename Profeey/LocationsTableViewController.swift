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

protocol LocationsTableViewControllerDelegate {
    // TODO change this to Location
    func didSelectLocation(_ locationName: String?)
}

class LocationsTableViewController: UITableViewController {
    
    var locationName: String?
    var locationsTableViewControllerDelegate: LocationsTableViewControllerDelegate?
    fileprivate var locations: [Location] = []
    fileprivate var allLocations: [Location] = []
    fileprivate var searchedLocations: [Location] = []
    fileprivate var isSearching: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scanLocations()
        self.isSearching = true
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if self.isSearching {
                return 1
            }
            if self.locations.count == 0 {
                return 1
            }
            return self.locations.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearchLocation", for: indexPath) as! SearchLocationTableViewCell
            if self.locationName != nil {
                cell.searchBar.text = self.locationName
            }
            cell.searchBar.delegate = self
            return cell
        case 1:
            if self.isSearching {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                cell.activityIndicator.startAnimating()
                return cell
            }
            if self.locations.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellLocation", for: indexPath) as! LocationTableViewCell
            let location = self.locations[indexPath.row]
            cell.locationNameLabel.text = location.fullLocationName
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is LocationTableViewCell {
            self.locationsTableViewControllerDelegate?.didSelectLocation(self.locations[indexPath.row].fullLocationName)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 45.0
        case 1:
            return 64.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 45.0
        case 1:
            return 64.0
        default:
            return 0.0
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        self.locationsTableViewControllerDelegate?.didSelectLocation(self.locationName)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: AWS
    
    fileprivate func scanLocations() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanLocationsDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearching = false
                if let error = error {
                    print("scanLocations error: \(error)")
                    self.reloadLocationsSection()
                } else {
                    guard let awsLocations = response?.items as? [AWSLocation] else {
                        self.reloadLocationsSection()
                        return
                    }
                    for awsLocation in awsLocations {
                        let location = Location(countryName: awsLocation._countryName, cityName: awsLocation._cityName, stateName: awsLocation._state, searchCountryName: awsLocation._searchCountryName, searchCityName: awsLocation._searchCityName)
                        self.allLocations.append(location)
                    }
                    self.locations = self.allLocations
                    self.reloadLocationsSection()
                }
            })
        })
    }
    
    // MARK: Helper
    
    fileprivate func filterLocations(_ searchText: String) {
        let searchCountryName = searchText.lowercased()
        let searchCityName = searchText.lowercased()
        let searchableLocations = self.allLocations.filter( { $0.searchCountryName != nil && $0.searchCityName != nil } )
        
        self.searchedLocations = searchableLocations.filter( { $0.searchCountryName!.hasPrefix(searchCountryName) || $0.searchCityName!.hasPrefix(searchCityName) } )
        self.locations = self.searchedLocations
        self.isSearching = false
        self.reloadLocationsSection()
    }
    
    fileprivate func reloadLocationsSection () {
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
        }
    }
}

extension LocationsTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let locationName = searchText.trimm()
        if locationName.isEmpty {
//            self.isSearching = false
            self.locations = self.allLocations
            self.reloadLocationsSection()
            self.locationName = nil
        } else {
//            self.isSearching = true
            self.filterLocations(locationName)
            self.locationName = locationName
        }
    }
}
