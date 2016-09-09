//
//  LocationTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import MapKit

class LocationTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var locationManager: CLLocationManager?
    private var localSearchCompleter: MKLocalSearchCompleter?
    private var locations: [MKLocalSearchCompletion] = []
    
    // TEST
    private var region: MKCoordinateRegion?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLocationManager()
        self.configureLocalSearchCompleter()
        //self.configureSearchController()
        
        // Overrie appearance.
        self.searchBar.searchBarStyle = UISearchBarStyle.Default
        self.searchBar.delegate = self
        
        // Overrie appearance.
        self.tableView.tableFooterView = nil
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 12.0, 0.0, 0.0)
    }
    
    deinit {
        // For bug on dismiss Vc and SearchController.
        //self.searchController?.loadViewIfNeeded()
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
    
    private func configureSearchController() {
//        self.searchController = UISearchController(searchResultsController: nil)
//        self.searchController?.searchResultsUpdater = self
//        self.searchController?.hidesNavigationBarDuringPresentation = false
//        self.searchController?.dimsBackgroundDuringPresentation = false
//        self.searchController?.searchBar.searchBarStyle = UISearchBarStyle.Default
//        self.searchController?.searchBar.barTintColor = Colors.grey
//        self.searchController?.searchBar.placeholder = "Search a location"
//        
//        self.definesPresentationContext = true
//        self.tableView.tableHeaderView = self.searchController?.searchBar
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellLocation", forIndexPath: indexPath) as! LocationTableViewCell
        cell.titleLabel.text = self.locations[indexPath.row].title
        cell.subtitleLabel.text = self.locations[indexPath.row].subtitle
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 12.0, 0.0, 0.0)
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension LocationTableViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.trimm().isEmpty {
            // Update search completere aka do the search!
            self.localSearchCompleter?.queryFragment = searchText
        }
    }
}

extension LocationTableViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            self.locationManager?.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 5000, 5000)
            self.region = region
            
            print(region)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("locationManager error: \(error)")
    }
}

extension LocationTableViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(completer: MKLocalSearchCompleter) {
        // Reload search results.
        self.locations = completer.results
        self.tableView.reloadData()
    }
    
    func completer(completer: MKLocalSearchCompleter, didFailWithError error: NSError) {
        print("completer error: \(error)")
    }
}
