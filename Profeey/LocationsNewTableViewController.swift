//
//  LocationsNewTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 27/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import MapKit

protocol LocationsDelegate {
    func didSelect(_ locationName: String)
}

class LocationsNewTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate var locationManager: CLLocationManager?
    fileprivate var localSearchCompleter: MKLocalSearchCompleter?
    fileprivate var locations: [MKLocalSearchCompletion] = []
    fileprivate var recentLocations: [MKLocalSearchCompletion] = []
    
    fileprivate var nearbyLocations: [MKLocalSearchCompletion] = []
    
    var locationName: String?
    
    // TEST
    fileprivate var region: MKCoordinateRegion?

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.searchBar.searchBarStyle = UISearchBarStyle.Default
        //self.searchBar.delegate = self
        
        self.configureLocationManager()
        //self.configureLocalSearchCompleter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
}

extension LocationsNewTableViewController: UISearchBarDelegate {
    
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

extension LocationsNewTableViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            self.locationManager?.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
//            let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 5000, 5000)
//            self.region = region
//            print(region)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location, completionHandler: {
                (placemarks: [CLPlacemark]?, error: NSError?) in
                if let error = error {
                    print("reverseGeocodeLocation error: \(error)")
                } else {
                    print(placemarks?.first?.locality)
                }
            } as! CLGeocodeCompletionHandler)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager error: \(error)")
    }
}

extension LocationsNewTableViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Reload search results.
        self.locations = completer.results
        self.tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("completer error: \(error)")
    }
}
