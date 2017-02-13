//
//  LocationsGoogleViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 13/02/17.
//  Copyright © 2017 Profeey. All rights reserved.
//

import UIKit
import GooglePlaces

class LocationsGoogleViewController: UIViewController {
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultsViewController = GMSAutocompleteResultsViewController()
        self.resultsViewController?.delegate = self
        
        self.searchController = UISearchController(searchResultsController: resultsViewController)
        self.searchController?.searchResultsUpdater = self.resultsViewController
        
        self.searchController?.searchBar.searchBarStyle = UISearchBarStyle.default
        self.searchController?.searchBar.barTintColor = Colors.greyLighter
        self.searchController?.searchBar.tintColor = Colors.black
        self.searchController?.searchBar.backgroundImage = UIImage()
        self.searchController?.searchBar.backgroundColor = Colors.greyLighter
        self.searchController?.searchBar.placeholder = "Search"
        
        if let navigationBar = self.navigationController?.navigationBar, let searchBar = self.searchController?.searchBar {
            let subView = UIView(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.size.height + navigationBar.frame.height, width: self.view.bounds.width, height: 44.0))
            subView.addSubview(searchBar)
            self.view.addSubview(subView)
            self.searchController?.searchBar.sizeToFit()
            self.searchController?.hidesNavigationBarDuringPresentation = false
            definesPresentationContext = true
        }
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.searchController?.hidesNavigationBarDuringPresentation = false
        
        // This makes the view area include the nav bar even though it is opaque.
        // Adjust the view placement down.
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .top
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: IBActions
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

// Handle the user's selection.
extension LocationsGoogleViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        print("LocationsGoogleViewController error: ", error.localizedDescription)
    }
    
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
