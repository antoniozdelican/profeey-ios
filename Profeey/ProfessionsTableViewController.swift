//
//  ProfessionsTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 11/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSDynamoDB

protocol ProfessionsTableViewControllerDelegate {
    func didSelectProfession(_ professionName: String?)
}

class ProfessionsTableViewController: UITableViewController {
    
    var professionName: String?
    var professionsTableViewControllerDelegate: ProfessionsTableViewControllerDelegate?
    
    fileprivate var popularProfessions: [Profession] = []
    fileprivate var regularProfessions: [Profession] = []
    fileprivate var isSearchingPopularProfessions: Bool = false
    fileprivate var isSearchingRegularProfessions: Bool = false
    fileprivate var isShowingPopularProfessions: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        self.tableView.register(UINib(nibName: "TableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "tableSectionHeader")
        
        self.isShowingPopularProfessions = true
        self.isSearchingPopularProfessions = true
        self.getAllProfessions()
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
            self.professionsTableViewControllerDelegate?.didSelectProfession(selectedProfession.professionName)
            self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        // '_' is unallowed (CloudSearch professionNameId) so replace it with ' ' if user enters it.
        self.professionName = self.professionName?.replacingOccurrences(of: "_", with: " ")
        self.professionsTableViewControllerDelegate?.didSelectProfession(self.professionName)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: AWS
    
    fileprivate func getAllProfessions() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYCloudSearchProxyClient.defaultClient().getAllProfessions(locationId: nil).continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingPopularProfessions = false
                if let error = task.error {
                    print("getAllProfessions error: \(error)")
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                    }
                } else {
                    guard let cloudSearchProfessionsResult = task.result as? PRFYCloudSearchProfessionsResult, let cloudSearchProfessions = cloudSearchProfessionsResult.professions else {
                        UIView.performWithoutAnimation {
                            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                        }
                        return
                    }
                    for cloudSearchProfession in cloudSearchProfessions {
                        let profession = Profession(professionName: cloudSearchProfession.professionName, numberOfUsers: cloudSearchProfession.numberOfUsers)
                        self.popularProfessions.append(profession)
                    }
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                    }
                }
            })
            return nil
        })
    }
    
    fileprivate func getProfessions(_ namePrefix: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYCloudSearchProxyClient.defaultClient().getProfessions(namePrefix: namePrefix, locationId: nil).continue({
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isSearchingRegularProfessions = false
                if let error = task.error {
                    print("getProfessions error: \(error)")
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                    }
                } else {
                    guard let cloudSearchProfessionsResult = task.result as? PRFYCloudSearchProfessionsResult, let cloudSearchProfessions = cloudSearchProfessionsResult.professions else {
                        UIView.performWithoutAnimation {
                            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
                        }
                        return
                    }
                    // Clear old.
                    self.regularProfessions = []
                    for cloudSearchProfession in cloudSearchProfessions {
                        let profession = Profession(professionName: cloudSearchProfession.professionName, numberOfUsers: cloudSearchProfession.numberOfUsers)
                        self.regularProfessions.append(profession)
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
    
//    fileprivate func filterProfessions(_ searchText: String) {
//        self.searchedProfessions = self.allProfessions.filter({
//            (profession: Profession) in
//            if let searchProfessionName = profession.professionName?.lowercased(), searchProfessionName.hasPrefix(searchText.lowercased()) {
//                return true
//            } else {
//                return false
//            }
//        })
//        self.professions = self.searchedProfessions
//        self.isSearching = false
//        self.reloadProfessionsSection()
//    }
//    
//    fileprivate func reloadProfessionsSection () {
//        UIView.performWithoutAnimation {
//            self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
//        }
//    }
}

extension ProfessionsTableViewController: AddProfessionTableViewCellDelegate {
    
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
            self.getProfessions(professionName)
        }
    }
}
