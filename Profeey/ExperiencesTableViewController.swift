//
//  ExperiencesTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 21/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class ExperiencesTableViewController: UITableViewController {
    
    var userExperiences: [UserExperience] = []
    fileprivate var workExperiences: [UserExperience] = []
    fileprivate var educationExperiences: [UserExperience] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.workExperiences = self.userExperiences.filter({$0.experienceType == 0})
        self.educationExperiences = self.userExperiences.filter({$0.experienceType == 1})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? EditExperienceTableViewController {
            if let indexPath = sender as? IndexPath {
                if (indexPath as NSIndexPath).section == 0 {
                    childViewController.experienceType = ExperienceType.work
                    childViewController.userExperience = self.workExperiences[(indexPath as NSIndexPath).row]
                    childViewController.experienceIndexPath = indexPath
                } else if (indexPath as NSIndexPath).section == 1 {
                    childViewController.experienceType = ExperienceType.education
                    childViewController.userExperience = self.educationExperiences[(indexPath as NSIndexPath).row]
                    childViewController.experienceIndexPath = indexPath
                }
            } else if let addButton = sender as? UIButton {
                if addButton.tag == 0 {
                    childViewController.experienceType = ExperienceType.work
                    childViewController.userExperience = UserExperience()
                    childViewController.experienceIndexPath = nil
                } else if addButton.tag == 1 {
                    childViewController.experienceType = ExperienceType.education
                    childViewController.userExperience = UserExperience()
                    childViewController.experienceIndexPath = nil
                }
            }
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.workExperiences.count
        case 1:
            return self.educationExperiences.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
        case 0:
            let workExperience = self.workExperiences[(indexPath as NSIndexPath).row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellExperience", for: indexPath) as! ExperienceTableViewCell
            cell.positionLabel.text = workExperience.position
            cell.organizationLabel.text = workExperience.organization
            cell.timePeriodLabel.text = workExperience.timePeriod
            return cell
        case 1:
            let educationExperience = self.educationExperiences[(indexPath as NSIndexPath).row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellExperience", for: indexPath) as! ExperienceTableViewCell
            cell.positionLabel.text = educationExperience.position
            cell.organizationLabel.text = educationExperience.organization
            cell.timePeriodLabel.text = educationExperience.timePeriod
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! HeaderTableViewCell
            cell.headerTitle.text = "WORK EXPERIENCE"
            cell.addButton?.tag = 0
            cell.addButton?.addTarget(self, action: #selector(ExperiencesTableViewController.addExperienceButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            // for bug returning contentView
            cell.contentView.backgroundColor = Colors.greyLight
            return cell.contentView
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! HeaderTableViewCell
            cell.headerTitle.text = "EDUCATION"
            cell.addButton?.tag = 1
            cell.addButton?.addTarget(self, action: #selector(ExperiencesTableViewController.addExperienceButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            // for bug returning contentView
            cell.contentView.backgroundColor = Colors.greyLight
            return cell.contentView
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellFooter")
        cell!.contentView.backgroundColor = Colors.greyLight
        return cell!.contentView
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 83.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 83.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is ExperienceTableViewCell {
            self.performSegue(withIdentifier: "segueToEditExperienceVc", sender: indexPath)
        }
    }
    
    // MARK: Tappers
    
    func addExperienceButtonTapped(_ sender: AnyObject) {
        guard let addButton = sender as? UIButton else {
            return
        }
        self.performSegue(withIdentifier: "segueToEditExperienceVc", sender: addButton)
    }
    
    // MARK: IBActions
    
    @IBAction func unwindToExperiencesTableViewController(_ segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? EditExperienceTableViewController {
            guard let experienceType = sourceViewController.experienceType else {
                return
            }
            if let savedExperience = sourceViewController.savedUserExperience {
                // Create/update.
                if experienceType == .work {
                    if let experienceIndexPath = sourceViewController.experienceIndexPath {
                        self.workExperiences[(experienceIndexPath as NSIndexPath).row] = savedExperience
                    } else {
                        self.workExperiences.append(savedExperience)
                    }
                } else if experienceType == .education {
                    if let experienceIndexPath = sourceViewController.experienceIndexPath {
                        self.educationExperiences[(experienceIndexPath as NSIndexPath).row] = savedExperience
                    } else {
                        self.educationExperiences.append(savedExperience)
                    }
                }
            } else {
                // Remove.
                if experienceType == .work {
                    if let experienceIndexPath = sourceViewController.experienceIndexPath {
                        self.workExperiences.remove(at: (experienceIndexPath as NSIndexPath).row)
                    }
                } else if experienceType == .education {
                    if let experienceIndexPath = sourceViewController.experienceIndexPath {
                        self.educationExperiences.remove(at: (experienceIndexPath as NSIndexPath).row)
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
}
