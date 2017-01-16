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

protocol ExperiencesTableViewControllerDelegate: class {
    func workExperiencesUpdated(_ workExperiences: [WorkExperience])
    func educationsUpdated(_ educations: [Education])
}

class ExperiencesTableViewController: UITableViewController {
    
    var workExperiences: [WorkExperience] = []
    var educations: [Education] = []
    weak var experiencesTableViewControllerDelegate: ExperiencesTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Register custom header.
        self.tableView.register(UINib(nibName: "ExperiencesTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "experiencesTableSectionHeader")
        
        self.sortWorkExperiencesByToDate()
        self.sortEducationsByToDate()
        
        // Add observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.createWorkExperienceNotification(_:)), name: NSNotification.Name(CreateWorkExperienceNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateWorkExperienceNotification(_:)), name: NSNotification.Name(UpdateWorkExperienceNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createEducationNotification(_:)), name: NSNotification.Name(CreateEducationNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateEducationNotification(_:)), name: NSNotification.Name(UpdateEducationNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationViewController = segue.destination as? UINavigationController,
            let childViewController = navigationViewController.childViewControllers[0] as? EditWorkExperienceTableViewController {
            if let cell = sender as? WorkExperienceTableViewCell,
                let indexPath = self.tableView.indexPath(for: cell) {
                childViewController.workExperience = self.workExperiences[indexPath.row].copyWorkExperience()
                childViewController.isNewWorkExperience = false
            } else {
                childViewController.isNewWorkExperience = true
            }
        }
        if let navigationViewController = segue.destination as? UINavigationController,
            let childViewController = navigationViewController.childViewControllers[0] as? EditEducationTableViewController {
            if let cell = sender as? EducationTableViewCell,
                let indexPath = self.tableView.indexPath(for: cell) {
                childViewController.education = self.educations[indexPath.row].copyEducation()
                childViewController.isNewEducation = false
            } else {
                childViewController.isNewEducation = true
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
            workExperience.isExpandedWorkDescription ? cell.untruncate() : cell.truncate()
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
            education.isExpandedEducationDescription ? cell.untruncate() : cell.truncate()
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
                }
            })
            return nil
        })
    }
    
    // MARK: Helpers
    
    fileprivate func expandButtonTapped(_ cell: UITableViewCell, experienceType: ExperienceType) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
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
                self.performSegue(withIdentifier: "segueToEditWorkExperienceVc", sender: cell)
            } else {
                self.performSegue(withIdentifier: "segueToEditEducationVc", sender: cell)
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
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet([0]), with: UITableViewRowAnimation.none)
        }
    }
    
    fileprivate func sortEducationsByToDate() {
        let currentEducations = self.educations.filter( { $0.toMonthInt == nil && $0.toYearInt == nil } )
        let otherEducations = self.educations.filter( { $0.toMonthInt != nil && $0.toYearInt != nil } )
        let sortedOtherEducations = otherEducations.sorted(by: {
            (education1, education2) in
            return education1.toYearInt! == education2.toYearInt! ? (education1.toMonthInt! > education2.toMonthInt!) : (education1.toYearInt! > education2.toYearInt!)
        })
        self.educations = currentEducations + sortedOtherEducations
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet([1]), with: UITableViewRowAnimation.none)
        }
    }
}

extension ExperiencesTableViewController {
    
    // MARK: NSNotification
    
    func createWorkExperienceNotification(_ notification: NSNotification) {
        guard let workExperience = notification.userInfo?["workExperience"] as? WorkExperience else {
            return
        }
        self.workExperiences.append(workExperience)
        self.sortWorkExperiencesByToDate()
        self.experiencesTableViewControllerDelegate?.workExperiencesUpdated(self.workExperiences)
    }
    
    func updateWorkExperienceNotification(_ notification: NSNotification) {
        guard let workExperience = notification.userInfo?["workExperience"] as? WorkExperience else {
            return
        }
        guard let workExperienceIndex = self.workExperiences.index(where: { $0.workExperienceId == workExperience.workExperienceId }) else {
            return
        }
        self.workExperiences[workExperienceIndex] = workExperience
        self.sortWorkExperiencesByToDate()
        self.experiencesTableViewControllerDelegate?.workExperiencesUpdated(self.workExperiences)
    }
    
    func createEducationNotification(_ notification: NSNotification) {
        guard let education = notification.userInfo?["education"] as? Education else {
            return
        }
        self.educations.append(education)
        self.sortEducationsByToDate()
        self.experiencesTableViewControllerDelegate?.educationsUpdated(self.educations)
    }
    
    func updateEducationNotification(_ notification: NSNotification) {
        guard let education = notification.userInfo?["education"] as? Education else {
            return
        }
        guard let educationIndex = self.educations.index(where: { $0.educationId == education.educationId }) else {
            return
        }
        self.educations[educationIndex] = education
        self.sortEducationsByToDate()
        self.experiencesTableViewControllerDelegate?.educationsUpdated(self.educations)
    }
}

extension ExperiencesTableViewController: WorkExperienceTableViewCellDelegate {
    
    func workExperienceExpandButtonTapped(_ cell: WorkExperienceTableViewCell) {
        self.expandButtonTapped(cell, experienceType: ExperienceType.workExperience)
    }
    
    func workDescriptionLabelTapped(_ cell: WorkExperienceTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        if !self.workExperiences[indexPath.row].isExpandedWorkDescription {
            self.workExperiences[indexPath.row].isExpandedWorkDescription = true
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }
        }
    }
}

extension ExperiencesTableViewController: EducationTableViewCellDelegate {
    
    func educationExpandButtonTapped(_ cell: EducationTableViewCell) {
        self.expandButtonTapped(cell, experienceType: ExperienceType.education)
    }
    
    func educationDescriptionLabelTapped(_ cell: EducationTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        if !self.educations[indexPath.row].isExpandedEducationDescription {
            self.educations[indexPath.row].isExpandedEducationDescription = true
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }
        }
    }
}
