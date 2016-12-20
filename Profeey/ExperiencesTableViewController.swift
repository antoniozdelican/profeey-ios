//
//  ExperiencesTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

enum ExperienceType {
    case workExperience
    case education
}

protocol ExperiencesTableViewControllerDelegate {
    func workExperiencesUpdated(_ workExperiences: [WorkExperience])
    func educationsUpdated(_ educations: [Education])
}

class ExperiencesTableViewController: UITableViewController {
    
    var workExperiences: [WorkExperience] = []
    var educations: [Education] = []
    var experiencesTableViewControllerDelegate: ExperiencesTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Register custom header.
        self.tableView.register(UINib(nibName: "ExperiencesTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "experiencesTableSectionHeader")
        
        self.sortWorkExperiencesByToDate()
        self.sortEducationsByToDate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationViewController = segue.destination as? UINavigationController,
            let childViewController = navigationViewController.childViewControllers[0] as? EditWorkExperienceTableViewController {
            if let indexPath = sender as? IndexPath {
                childViewController.workExperience = self.workExperiences[indexPath.row]
                childViewController.isNewWorkExperience = false
                childViewController.indexPath = indexPath
            } else {
                childViewController.isNewWorkExperience = true
            }
            childViewController.editWorkExperienceTableViewControllerDelegate = self
        }
        if let navigationViewController = segue.destination as? UINavigationController,
            let childViewController = navigationViewController.childViewControllers[0] as? EditEducationTableViewController {
            if let indexPath = sender as? IndexPath {
                childViewController.education = self.educations[indexPath.row]
                childViewController.isNewEducation = false
                childViewController.indexPath = indexPath
            } else {
                childViewController.isNewEducation = true
            }
            childViewController.editEducationTableViewControllerDelegate = self
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.workExperiences.count + 1
        case 1:
            return self.educations.count + 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == self.workExperiences.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellAdd", for: indexPath) as! AddTableViewCell
                cell.titleLabel.text = "Add Work Experience"
                return cell
            }
            let workExperience = self.workExperiences[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellWorkExperience", for: indexPath) as! WorkExperienceTableViewCell
            cell.titleLabel.text = workExperience.title
            cell.organizationLabel.text = workExperience.organization
            cell.timePeriodLabel.text = workExperience.timePeriod
            cell.workDescriptionLabel.text = workExperience.workDescription
            cell.workExperienceTableViewCellDelegate = self
            return cell
        case 1:
            if indexPath.row == self.educations.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellAdd", for: indexPath) as! AddTableViewCell
                cell.titleLabel.text = "Add Education"
                return cell
            }
            let education = self.educations[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEducation", for: indexPath) as! EducationTableViewCell
            cell.schoolLabel.text = education.school
            cell.fieldOfStudyLabel.text = education.fieldOfStudy
            cell.timePeriodLabel.text = education.timePeriod
            cell.educationDescriptionLabel.text = education.educationDescription
            cell.educationTableViewCellDelegate = self
            return cell
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
        switch indexPath.section {
        case 0:
            if indexPath.row == self.workExperiences.count {
                self.performSegue(withIdentifier: "segueToEditWorkExperienceVc", sender: nil)
            }
        case 1:
            if indexPath.row == self.educations.count {
                self.performSegue(withIdentifier: "segueToEditEducationVc", sender: nil)
            }
        default:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == self.workExperiences.count {
                return 52.0
            }
            return 105.0
        case 1:
            if indexPath.row == self.educations.count {
                return 52.0
            }
            return 105.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == self.workExperiences.count {
                return 52.0
            }
            return UITableViewAutomaticDimension
        case 1:
            if indexPath.row == self.educations.count {
                return 52.0
            }
            return UITableViewAutomaticDimension
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "experiencesTableSectionHeader") as? ExperiencesTableSectionHeader
            header?.titleLabel.text = "WORK EXPERIENCE"
            return header
        case 1:
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "experiencesTableSectionHeader") as? ExperiencesTableSectionHeader
            header?.titleLabel.text = "EDUCATION"
            return header
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48.0
    }
    
    // MARK: IBActions
    
    // In background
    fileprivate func removeWorkExperience(_ workExperienceId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removeWorkExperienceDynamoDB(workExperienceId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("removeWorkExperience error: \(error)")
                } else {
                    print("removeWorkExperience success!")
                }
            })
            return nil
        })
    }
    
    fileprivate func removeEducation(_ educationId: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PRFYDynamoDBManager.defaultDynamoDBManager().removeEducationDynamoDB(educationId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = task.error {
                    print("removeEducation error: \(error)")
                } else {
                    print("removeEducation success!")
                }
            })
            return nil
        })
    }
    
    // MARK: Helpers
    
    fileprivate func expandButtonTapped(_ indexPath: IndexPath, experienceType: ExperienceType) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        // DELETE
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {
            (alert: UIAlertAction) in
            let title = (experienceType == ExperienceType.workExperience) ? "Work Experience" : "Education"
            let alertController = UIAlertController(title: "Delete \(title)?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(cancelAction)
            let deleteConfirmAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction) in
                if experienceType == ExperienceType.workExperience {
                    guard let workExperienceId = self.workExperiences[indexPath.row].workExperienceId else {
                        return
                    }
                    self.removeWorkExperience(workExperienceId)
                    self.workExperiences.remove(at: indexPath.row)
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    self.tableView.endUpdates()
                    self.experiencesTableViewControllerDelegate?.workExperiencesUpdated(self.workExperiences)
                } else {
                    guard let educationId = self.educations[indexPath.row].educationId else {
                        return
                    }
                    self.removeEducation(educationId)
                    self.educations.remove(at: indexPath.row)
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    self.tableView.endUpdates()
                    self.experiencesTableViewControllerDelegate?.educationsUpdated(self.educations)
                }
            })
            alertController.addAction(deleteConfirmAction)
            self.present(alertController, animated: true, completion: nil)
        })
        alertController.addAction(deleteAction)
        // EDIT
        let editAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction) in
            if experienceType == ExperienceType.workExperience {
                self.performSegue(withIdentifier: "segueToEditWorkExperienceVc", sender: indexPath)
            } else {
                self.performSegue(withIdentifier: "segueToEditEducationVc", sender: indexPath)
            }
        })
        alertController.addAction(editAction)
        // CANCEL
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func sortWorkExperiencesByToDate() {
        let currentWorkExperiences = self.workExperiences.filter( { $0.toMonthInt == nil && $0.toYearInt == nil } )
        let otherWorkExperiences = self.workExperiences.filter( { $0.toMonthInt != nil && $0.toYearInt != nil } )
        let sortedOtherWorkExperiences = otherWorkExperiences.sorted(by: {
            (workExperience1, workExperience2) in
            return workExperience1.toYearInt! == workExperience2.toYearInt! ? (workExperience1.toMonthInt! > workExperience2.toMonthInt!) : (workExperience1.toYearInt! > workExperience2.toYearInt!)
        })
        self.workExperiences = currentWorkExperiences + sortedOtherWorkExperiences
    }
    
    fileprivate func sortEducationsByToDate() {
        let currentEducations = self.educations.filter( { $0.toMonthInt == nil && $0.toYearInt == nil } )
        let otherEducations = self.educations.filter( { $0.toMonthInt != nil && $0.toYearInt != nil } )
        let sortedOtherEducations = otherEducations.sorted(by: {
            (education1, education2) in
            return education1.toYearInt! == education2.toYearInt! ? (education1.toMonthInt! > education2.toMonthInt!) : (education1.toYearInt! > education2.toYearInt!)
        })
        self.educations = currentEducations + sortedOtherEducations
    }
}

extension ExperiencesTableViewController: WorkExperienceTableViewCellDelegate {
    
    func workExperienceExpandButtonTapped(_ button: UIButton) {
        guard let indexPath = self.tableView.indexPathForView(view: button) else {
            return
        }
        self.expandButtonTapped(indexPath, experienceType: ExperienceType.workExperience)
    }
}

extension ExperiencesTableViewController: EducationTableViewCellDelegate {
    
    func educationExpandButtonTapped(_ button: UIButton) {
        guard let indexPath = self.tableView.indexPathForView(view: button) else {
            return
        }
        self.expandButtonTapped(indexPath, experienceType: ExperienceType.education)
    }
}

extension ExperiencesTableViewController: EditWorkExperienceTableViewControllerDelegate {
    
    func didEditWorkExperience(_ workExperience: WorkExperience, isNewWorkExperience: Bool, indexPath: IndexPath?) {
        if isNewWorkExperience {
            self.workExperiences.append(workExperience)
        } else {
            guard let indexPath = indexPath else {
                return
            }
            self.workExperiences[indexPath.row] = workExperience
        }
        self.sortWorkExperiencesByToDate()
        self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.automatic)
        self.experiencesTableViewControllerDelegate?.workExperiencesUpdated(self.workExperiences)
    }
}

extension ExperiencesTableViewController: EditEducationTableViewControllerDelegate {
    
    func didEditEducation(_ education: Education, isNewEducation: Bool, indexPath: IndexPath?) {
        if isNewEducation {
            self.educations.append(education)
        } else {
            guard let indexPath = indexPath else {
                return
            }
            self.educations[indexPath.row] = education
        }
        self.sortEducationsByToDate()
        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.automatic)
        self.experiencesTableViewControllerDelegate?.educationsUpdated(self.educations)
    }
}
