//
//  WelcomeProfessionsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 23/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB

protocol WelcomeProfessionsTableViewControllerDelegate: class {
    func didSelectProfession(_ professionName: String?)
}

class WelcomeProfessionsTableViewController: UITableViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    
    fileprivate var professionName: String?
    fileprivate weak var welcomeProfessionsTableViewControllerDelegate: WelcomeProfessionsTableViewControllerDelegate?
    
    fileprivate var popularProfessions: [Profession] = []
    fileprivate var regularProfessions: [Profession] = []
    fileprivate var isSearchingPopularProfessions: Bool = false
    fileprivate var isSearchingRegularProfessions: Bool = false
    fileprivate var isShowingPopularProfessions: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        self.tableView.register(UINib(nibName: "TableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "tableSectionHeader")
        self.configureNavigationBar()
        
        self.isShowingPopularProfessions = true
        self.isSearchingPopularProfessions = true
        self.scanProfessions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    // MARK: Configuration
    
    fileprivate func configureNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.barTintColor = Colors.whiteDark
        self.navigationController?.navigationBar.tintColor = Colors.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.black]
        // Fix alignment for custom rightBarButtonItem.
        self.nextButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -8.0)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? DiscoverPeopleTableViewController {
            destinationViewController.isOnboardingFlow = true
        }
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
            if self.isShowingPopularProfessions {
                if self.isSearchingPopularProfessions {
                    return 1
                }
                if self.popularProfessions.count == 0 {
                    return 1
                }
                return self.popularProfessions.count
            } else {
                if self.isSearchingRegularProfessions {
                    return 1
                }
                if self.regularProfessions.count == 0 {
                    return 1
                }
                return self.regularProfessions.count
            }
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellAddProfession", for: indexPath) as! AddProfessionTableViewCell
            cell.addProfessionTextField.text = self.professionName
            cell.addProfessionTableViewCellDelegate = self
            self.welcomeProfessionsTableViewControllerDelegate = cell
            return cell
        case 1:
            if self.isShowingPopularProfessions {
                if self.isSearchingPopularProfessions {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                    cell.activityIndicator.startAnimating()
                    // TODO update text.
                    return cell
                }
                if self.popularProfessions.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                    return cell
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfession", for: indexPath) as! ProfessionTableViewCell
                let profession = self.popularProfessions[indexPath.row]
                cell.professionNameLabel.text = profession.professionName
                cell.numberOfUsersLabel.text = profession.numberOfUsersString
                return cell
            } else {
                if self.isSearchingRegularProfessions {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearching", for: indexPath) as! SearchingTableViewCell
                    cell.activityIndicator.startAnimating()
                    // TODO update text.
                    return cell
                }
                if self.regularProfessions.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoResults", for: indexPath) as! NoResultsTableViewCell
                    return cell
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfession", for: indexPath) as! ProfessionTableViewCell
                let profession = self.regularProfessions[indexPath.row]
                cell.professionNameLabel.text = profession.professionName
                cell.numberOfUsersLabel.text = profession.numberOfUsersString
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
        if cell is ProfessionTableViewCell {
            let selectedProfession = self.isShowingPopularProfessions ? self.popularProfessions[indexPath.row] : self.regularProfessions[indexPath.row]
            self.welcomeProfessionsTableViewControllerDelegate?.didSelectProfession(selectedProfession.professionName)
            self.professionName = selectedProfession.professionName
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 52.0
        case 1:
            return 64.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 52.0
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
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "tableSectionHeader") as? TableSectionHeader
        header?.titleLabel.text = self.isShowingPopularProfessions ? "POPULAR" : "BEST MATCHES"
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
    
    // MARK: IBActions
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        if let professionName = self.professionName {
            self.saveUserProfession(professionName)
        } else {
            let alertController = UIAlertController(title: "No Profession", message: "Are you sure you don't want to pick a profession?", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
                (alertAction: UIAlertAction) in
                self.performSegue(withIdentifier: "segueToDiscoverPeopleVc", sender: self)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: Helpers
    
    fileprivate func filterProfessions(_ namePrefix: String) {
        // Clear old.
        self.regularProfessions = []
        self.regularProfessions = self.popularProfessions.filter({
            (profession: Profession) in
            if let searchProfessionName = profession.professionName?.lowercased(), searchProfessionName.hasPrefix(namePrefix.lowercased()) {
                return true
            } else {
                return false
            }
        })
        self.regularProfessions = self.sortProfessions(self.regularProfessions)
        self.isSearchingRegularProfessions = false
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
        }
    }
    
    fileprivate func sortProfessions(_ professions: [Profession]) -> [Profession] {
        return professions.sorted(by: {
            (profession1, profession2) in
            return profession1.numberOfUsersInt > profession2.numberOfUsersInt
        })
    }
    
    // MARK: AWS
    
    fileprivate func scanProfessions() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().scanProfessionsDynamoDB({
            (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingPopularProfessions = false
                if let error = error {
                    print("scanProfessions error: \(error)")
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                    }
                } else {
                    guard let awsProfessions = response?.items as? [AWSProfession] else {
                        UIView.performWithoutAnimation {
                            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                        }
                        return
                    }
                    for awsProfession in awsProfessions {
                        let profession = Profession(professionName: awsProfession._professionName, numberOfUsers: awsProfession._numberOfUsers)
                        self.popularProfessions.append(profession)
                    }
                    self.popularProfessions = self.sortProfessions(self.popularProfessions)
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                    }
                }
            })
        })
    }
    
    fileprivate func saveUserProfession(_ professionName: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        PRFYDynamoDBManager.defaultDynamoDBManager().updateUserProfessionDynamoDB(professionName, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("saveUserProfession error: \(error)")
                    let alertController = UIAlertController(title: "Save profession failed", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: "segueToDiscoverPeopleVc", sender: self)
                }
            })
            return nil
        })
    }
}

extension WelcomeProfessionsTableViewController: AddProfessionTableViewCellDelegate {
    
    func addProfessionTextFieldChanged(_ text: String) {
        var professionName = text.trimm()
        professionName = professionName.replacingOccurrences(of: "_", with: " ")
        if professionName.isEmpty {
            self.isShowingPopularProfessions = true
            // Clear old.
            self.regularProfessions = []
            self.isSearchingRegularProfessions = false
            UIView.performWithoutAnimation {
                self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
            }
            self.professionName = nil
        } else {
            self.isShowingPopularProfessions = false
            // Clear old.
            self.regularProfessions = []
            self.isSearchingRegularProfessions = true
            UIView.performWithoutAnimation {
                self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
            }
            self.professionName = professionName
            // Start search for existing professions.
            self.filterProfessions(professionName)
        }
    }
}
