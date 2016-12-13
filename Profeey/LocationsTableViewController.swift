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
    func didSelectLocation(_ location: Location)
}

class LocationsTableViewController: UITableViewController {
    
    var locationName: String?
    var locationsTableViewControllerDelegate: LocationsTableViewControllerDelegate?
    
    fileprivate var popularLocations: [Location] = []
    fileprivate var regularLocations: [Location] = []
    fileprivate var isSearchingPopularLocations: Bool = false
    fileprivate var isSearchingRegularLocations: Bool = false
    fileprivate var isShowingPopularLocations: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "SearchTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchTableSectionHeader")
        self.navigationItem.title = "Choose city"
        
        self.isShowingPopularLocations = true
        self.isSearchingPopularLocations = true
        self.getAllLocations()
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
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearchLocation", for: indexPath) as! SearchLocationTableViewCell
            cell.searchBar.text = self.locationName
            cell.searchBar.delegate = self
            return cell
        case 1:
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
        default:
            return UITableViewCell()
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        }
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "searchTableSectionHeader") as? SearchTableSectionHeader
        header?.titleLabel.text = self.isShowingPopularLocations ? "POPULAR" : "BEST MATCHES"
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1.0
        }
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: AWS
    
    fileprivate func getAllLocations() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYCloudSearchProxyClient.defaultClient().getAllLocations().continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingPopularLocations = false
                if let error = task.error {
                    print("getAllLocations error: \(error)")
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                    }
                } else {
                    guard let cloudSearchLocationsResult = task.result as? PRFYCloudSearchLocationsResult, let cloudSearchLocations = cloudSearchLocationsResult.locations else {
                        UIView.performWithoutAnimation {
                            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                        }
                        return
                    }
                    for cloudSearchLocation in cloudSearchLocations {
                        let location = Location(locationId: cloudSearchLocation.locationId, country: cloudSearchLocation.country, state: cloudSearchLocation.state, city: cloudSearchLocation.city, latitude: cloudSearchLocation.latitude, longitude: cloudSearchLocation.longitude, numberOfUsers: cloudSearchLocation.numberOfUsers)
                        self.popularLocations.append(location)
                    }
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                    }
                }
            })
            return nil
        })
    }
    
    fileprivate func getLocations(_ namePrefix: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYCloudSearchProxyClient.defaultClient().getLocations(namePrefix: namePrefix).continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingRegularLocations = false
                if let error = task.error {
                    print("getLocations error: \(error)")
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                    }
                } else {
                    guard let cloudSearchLocationsResult = task.result as? PRFYCloudSearchLocationsResult, let cloudSearchLocations = cloudSearchLocationsResult.locations else {
                        UIView.performWithoutAnimation {
                            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                        }
                        return
                    }
                    // Clear old.
                    self.regularLocations = []
                    for cloudSearchLocation in cloudSearchLocations {
                        let location = Location(locationId: cloudSearchLocation.locationId, country: cloudSearchLocation.country, state: cloudSearchLocation.state, city: cloudSearchLocation.city, latitude: cloudSearchLocation.latitude, longitude: cloudSearchLocation.longitude, numberOfUsers: cloudSearchLocation.numberOfUsers)
                        self.regularLocations.append(location)
                    }
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                    }
                }
            })
            return nil
        })
    }
    
    // MARK: Helper
    
//    fileprivate func filterLocations(_ searchText: String) {
//        let searchCountryName = searchText.lowercased()
//        let searchCityName = searchText.lowercased()
//        let searchableLocations = self.allLocations.filter( { $0.searchCountryName != nil && $0.searchCityName != nil } )
//        
//        self.searchedLocations = searchableLocations.filter( { $0.searchCountryName!.hasPrefix(searchCountryName) || $0.searchCityName!.hasPrefix(searchCityName) } )
//        self.locations = self.searchedLocations
//        self.isSearching = false
//        self.reloadLocationsSection()
//    }
//    
//    fileprivate func reloadLocationsSection () {
//        UIView.performWithoutAnimation {
//            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
//        }
//    }
}

extension LocationsTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let locationName = searchText.trimm()
        if locationName.isEmpty {
            self.isShowingPopularLocations = true
            // Clear old.
            self.regularLocations = []
            self.isSearchingRegularLocations = false
            UIView.performWithoutAnimation {
                self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
            }
        } else {
            self.isShowingPopularLocations = false
            // Clear old.
            self.regularLocations = []
            self.isSearchingRegularLocations = true
            UIView.performWithoutAnimation {
                self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
            }
            // Start search.
            self.getLocations(locationName)
        }
    }
}
