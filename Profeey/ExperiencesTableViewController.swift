//
//  ExperiencesTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

enum ExperienceType {
    case workExperience
    case education
}

class ExperiencesTableViewController: UITableViewController {
    
    var workExperiences: [WorkExperience] = []
    var educations: [Education] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Register custom header.
        self.tableView.register(UINib(nibName: "ExperiencesTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "experiencesTableSectionHeader")
        
        // MOCK
        let workExperience = WorkExperience(userId: nil, workExperienceId: nil, title: "Engineer", organization: "Organization, Inc.", workDescription: "Lorem ipsum dolor sit amet, at mei detracto similique assueverit. In eos sumo inermis, ipsum partiendo no sit.", fromMonth: 4, fromYear: 2014, toMonth: 6, toYear: 2016)
        let workExperience2 = WorkExperience(userId: nil, workExperienceId: nil, title: "Engineer", organization: "Organization, Inc.", workDescription: "Some description", fromMonth: 5, fromYear: 1999, toMonth: nil, toYear: nil)
        let workExperience3 = WorkExperience(userId: nil, workExperienceId: nil, title: "Maestro", organization: "Organization, Inc.", workDescription: "Some description", fromMonth: 10, fromYear: 1995, toMonth: 3, toYear: 2000)
        let workExperience4 = WorkExperience(userId: nil, workExperienceId: nil, title: "Director", organization: "Organization, Inc.", workDescription: "Some description", fromMonth: 10, fromYear: 1995, toMonth: 4, toYear: 2000)
        self.workExperiences.append(workExperience)
        self.workExperiences.append(workExperience2)
        self.workExperiences.append(workExperience3)
        self.workExperiences.append(workExperience4)
        
        let education = Education(userId: nil, educationId: nil, school: "Stanford University", fieldOfStudy: "Computer Science", educationDescription: nil, fromMonth: 9, fromYear: 2012, toMonth: 7, toYear: 2014)
        self.educations.append(education)
        
        
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
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if cell is AddTableViewCell {
           cell.selectionStyle = UITableViewCellSelectionStyle.default
        }
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
            return 108.0
        case 1:
            if indexPath.row == self.educations.count {
                return 52.0
            }
            return 108.0
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
        return 52.0
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
                    self.workExperiences.remove(at: indexPath.row)
                } else {
                    self.educations.remove(at: indexPath.row)
                }
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                self.tableView.endUpdates()
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
    
    func didEditWorkExperience(_ workExperience: WorkExperience, isNewWorkExperience: Bool) {
        if isNewWorkExperience {
            self.workExperiences.append(workExperience)
        } else {
            guard let index = self.workExperiences.index(of: workExperience) else {
                return
            }
            self.workExperiences[index] = workExperience
        }
        self.sortWorkExperiencesByToDate()
        self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.automatic)
    }
}

extension ExperiencesTableViewController: EditEducationTableViewControllerDelegate {
    
    func didEditEducation(_ education: Education, isNewEducation: Bool) {
        if isNewEducation {
            self.educations.append(education)
        } else {
            guard let index = self.educations.index(of: education) else {
                return
            }
            self.educations[index] = education
        }
        self.sortEducationsByToDate()
        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.automatic)
    }
}
