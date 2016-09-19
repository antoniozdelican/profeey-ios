//
//  LocationTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import MapKit

class LocationsTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var locationManager: CLLocationManager?
    private var localSearchCompleter: MKLocalSearchCompleter?
    private var locations: [MKLocalSearchCompletion] = []
    private var recentLocations: [MKLocalSearchCompletion] = []
    
    var locationName: String?
    
    // TEST
    private var region: MKCoordinateRegion?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLocationManager()
        self.configureLocalSearchCompleter()
        
        // Override appearance.
        self.searchBar.searchBarStyle = UISearchBarStyle.Default
        self.tableView.tableFooterView = nil
        
        self.searchBar.delegate = self
        if let locationName = self.locationName {
            self.searchBar.text = locationName
            self.localSearchCompleter?.queryFragment = self.searchBar.text!
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Mark: Configuration
    
    private func configureLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        if  CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            self.locationManager?.requestWhenInUseAuthorization()
        } else {
            self.locationManager?.requestLocation()
        }
    }
    
    private func configureLocalSearchCompleter() {
        self.localSearchCompleter = MKLocalSearchCompleter()
        self.localSearchCompleter?.delegate = self
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let searchText = self.searchBar.text else {
            return 0
        }
        return searchText.isEmpty ? self.recentLocations.count : self.locations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let searchText = self.searchBar.text else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("cellLocation", forIndexPath: indexPath) as! LocationTableViewCell
        let location = searchText.isEmpty ? self.recentLocations[indexPath.row] : self.locations[indexPath.row]
        cell.titleLabel.text = location.title
        cell.subtitleLabel.text = location.subtitle
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let searchText = self.searchBar.text else {
            return nil
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader") as! HeaderTableViewCell
        cell.headerTitle.text = searchText.isEmpty ? "RECENT" : "BEST MATCHES"
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is LocationTableViewCell {
            // Update location and unwind to EditProfileVc
            self.locationName = self.locations[indexPath.row].title
            self.performSegueWithIdentifier("segueUnwindToEditProfileVc", sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        // Update location and unwind to EditProfileVc
        self.locationName = self.searchBar.text?.trimm()
        self.performSegueWithIdentifier("segueUnwindToEditProfileVc", sender: self)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension LocationsTableViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.trimm().isEmpty {
            // Show cached recentLocations.
            self.tableView.reloadData()
        } else {
            // Update search completer aka do the search!
            self.localSearchCompleter?.queryFragment = searchText
        }
    }
}

extension LocationsTableViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            self.locationManager?.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Not needed atm but will be used later.
        if let location = locations.first {
            let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 5000, 5000)
            self.region = region
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("locationManager error: \(error)")
    }
}

extension LocationsTableViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(completer: MKLocalSearchCompleter) {
        // Reload search results.
        self.locations = completer.results
        self.tableView.reloadData()
    }
    
    func completer(completer: MKLocalSearchCompleter, didFailWithError error: NSError) {
        print("completer error: \(error)")
    }
}
