//
//  LocationsOldTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 08/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import MapKit

class LocationsOldTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate var locationManager: CLLocationManager?
    fileprivate var localSearchCompleter: MKLocalSearchCompleter?
    fileprivate var locations: [MKLocalSearchCompletion] = []
    fileprivate var recentLocations: [MKLocalSearchCompletion] = []
    
    var locationName: String?
    
    // TEST
    fileprivate var region: MKCoordinateRegion?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLocationManager()
        self.configureLocalSearchCompleter()
        
        // Override appearance.
        self.searchBar.searchBarStyle = UISearchBarStyle.default
        self.tableView.tableFooterView = nil
        
        self.searchBar.delegate = self
        if let locationName = self.locationName {
            self.searchBar.text = locationName
            self.localSearchCompleter?.queryFragment = self.searchBar.text!
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Mark: Configuration
    
    fileprivate func configureLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        if  CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined {
            self.locationManager?.requestWhenInUseAuthorization()
        } else {
            self.locationManager?.requestLocation()
        }
    }
    
    fileprivate func configureLocalSearchCompleter() {
        self.localSearchCompleter = MKLocalSearchCompleter()
        self.localSearchCompleter?.delegate = self
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let searchText = self.searchBar.text else {
            return 0
        }
        return searchText.isEmpty ? self.recentLocations.count : self.locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let searchText = self.searchBar.text else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellLocation", for: indexPath) as! LocationOldTableViewCell
        let location = searchText.isEmpty ? self.recentLocations[(indexPath as NSIndexPath).row] : self.locations[(indexPath as NSIndexPath).row]
        cell.titleLabel.text = location.title
        cell.subtitleLabel.text = location.subtitle
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let searchText = self.searchBar.text else {
            return nil
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! HeaderTableViewCell
        cell.headerTitle.text = searchText.isEmpty ? "RECENT" : "BEST MATCHES"
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is LocationOldTableViewCell {
            // Update location and unwind to EditProfileVc
            self.locationName = self.locations[(indexPath as NSIndexPath).row].title
            self.performSegue(withIdentifier: "segueUnwindToEditProfileVc", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        // Update location and unwind to EditProfileVc
        self.locationName = self.searchBar.text?.trimm()
        self.performSegue(withIdentifier: "segueUnwindToEditProfileVc", sender: self)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension LocationsOldTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.trimm().isEmpty {
            // Show cached recentLocations.
            self.tableView.reloadData()
        } else {
            // Update search completer aka do the search!
            self.localSearchCompleter?.queryFragment = searchText
        }
    }
}

extension LocationsOldTableViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            self.locationManager?.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Not needed atm but will be used later.
        if let location = locations.first {
            let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 5000, 5000)
            self.region = region
        }
        
        if let location = locations.first {
            //            let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 5000, 5000)
            //            self.region = region
            //            print(region)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location, completionHandler: {
                (placemarks: [CLPlacemark]?, error: Error?) in
                if let error = error {
                    print("reverseGeocodeLocation error: \(error.localizedDescription)")
                } else {
                    //print(placemarks?.count)
                }
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager error: \(error)")
    }
}

extension LocationsOldTableViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Reload search results.
        self.locations = completer.results
        self.tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("completer error: \(error)")
    }
}
