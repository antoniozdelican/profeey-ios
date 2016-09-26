//
//  SearchNewTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class SearchNewTableViewController: UITableViewController {

    @IBOutlet weak var testCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.testCollectionView.dataSource = self
        self.testCollectionView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

extension SearchNewTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellTest", forIndexPath: indexPath)
        return cell
    }
}
