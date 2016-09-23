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
    private var workExperiences: [UserExperience] = []
    private var educationExperiences: [UserExperience] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.workExperiences = self.userExperiences.filter({$0.experienceType == 0})
        self.educationExperiences = self.userExperiences.filter({$0.experienceType == 1})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? UINavigationController,
            let childViewController = destinationViewController.childViewControllers[0] as? EditExperienceTableViewController {
            if let indexPath = sender as? NSIndexPath {
                if indexPath.section == 0 {
                    childViewController.experienceType = ExperienceType.Work
                    childViewController.userExperience = self.workExperiences[indexPath.row]
                    childViewController.experienceIndexPath = indexPath
                } else if indexPath.section == 1 {
                    childViewController.experienceType = ExperienceType.Education
                    childViewController.userExperience = self.educationExperiences[indexPath.row]
                    childViewController.experienceIndexPath = indexPath
                }
            } else if let addButton = sender as? UIButton {
                if addButton.tag == 0 {
                    childViewController.experienceType = ExperienceType.Work
                    childViewController.userExperience = UserExperience()
                    childViewController.experienceIndexPath = nil
                } else if addButton.tag == 1 {
                    childViewController.experienceType = ExperienceType.Education
                    childViewController.userExperience = UserExperience()
                    childViewController.experienceIndexPath = nil
                }
            }
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.workExperiences.count
        case 1:
            return self.educationExperiences.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let workExperience = self.workExperiences[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("cellExperience", forIndexPath: indexPath) as! ExperienceTableViewCell
            cell.positionLabel.text = workExperience.position
            cell.organizationLabel.text = workExperience.organization
            cell.timePeriodLabel.text = workExperience.timePeriod
            return cell
        case 1:
            let educationExperience = self.educationExperiences[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("cellExperience", forIndexPath: indexPath) as! ExperienceTableViewCell
            cell.positionLabel.text = educationExperience.position
            cell.organizationLabel.text = educationExperience.organization
            cell.timePeriodLabel.text = educationExperience.timePeriod
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader") as! HeaderTableViewCell
            cell.headerTitle.text = "WORK EXPERIENCE"
            cell.addButton?.tag = 0
            cell.addButton?.addTarget(self, action: #selector(ExperiencesTableViewController.addExperienceButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            // for bug returning contentView
            cell.contentView.backgroundColor = Colors.greyLight
            return cell.contentView
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellHeader") as! HeaderTableViewCell
            cell.headerTitle.text = "EDUCATION"
            cell.addButton?.tag = 1
            cell.addButton?.addTarget(self, action: #selector(ExperiencesTableViewController.addExperienceButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            // for bug returning contentView
            cell.contentView.backgroundColor = Colors.greyLight
            return cell.contentView
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is ExperienceTableViewCell {
            self.performSegueWithIdentifier("segueToEditExperienceVc", sender: indexPath)
        }
    }
    
    // MARK: Tappers
    
    func addExperienceButtonTapped(sender: AnyObject) {
        guard let addButton = sender as? UIButton else {
            return
        }
        self.performSegueWithIdentifier("segueToEditExperienceVc", sender: addButton)
    }
    
    // MARK: IBActions
    
    @IBAction func unwindToExperiencesTableViewController(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.sourceViewController as? EditExperienceTableViewController {
            guard let experienceType = sourceViewController.experienceType else {
                return
            }
            if let savedExperience = sourceViewController.savedUserExperience {
                // Create/update.
                if experienceType == .Work {
                    if let experienceIndexPath = sourceViewController.experienceIndexPath {
                        self.workExperiences[experienceIndexPath.row] = savedExperience
                    } else {
                        self.workExperiences.append(savedExperience)
                    }
                } else if experienceType == .Education {
                    if let experienceIndexPath = sourceViewController.experienceIndexPath {
                        self.educationExperiences[experienceIndexPath.row] = savedExperience
                    } else {
                        self.educationExperiences.append(savedExperience)
                    }
                }
            } else {
                // Remove.
                if experienceType == .Work {
                    if let experienceIndexPath = sourceViewController.experienceIndexPath {
                        self.workExperiences.removeAtIndex(experienceIndexPath.row)
                    }
                } else if experienceType == .Education {
                    if let experienceIndexPath = sourceViewController.experienceIndexPath {
                        self.educationExperiences.removeAtIndex(experienceIndexPath.row)
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
}
