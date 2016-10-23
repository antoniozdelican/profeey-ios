//
//  EditWorkExperienceTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

protocol EditWorkExperienceTableViewControllerDelegate {
    func didEditWorkExperience(_ worExperience: WorkExperience, isNewWorkExperience: Bool, indexPath: IndexPath?)
}

class EditWorkExperienceTableViewController: UITableViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var workExperience: WorkExperience?
    var isNewWorkExperience: Bool = true
    var indexPath: IndexPath?
    var editWorkExperienceTableViewControllerDelegate: EditWorkExperienceTableViewControllerDelegate?
    
    fileprivate var fromDatePickerActive: Bool = false
    fileprivate var toDatePickerActive: Bool = false
    fileprivate var isCurrentlyDoing: Bool = false
    
    fileprivate var currentMonth = Calendar.current.component(.month, from: Date())
    fileprivate var currentYear = Calendar.current.component(.year, from: Date())
    fileprivate var workDescriptionIndexPath = IndexPath(row: 2, section: 0)
    fileprivate var fromDateIndexPath = IndexPath(row: 3, section: 0)
    fileprivate var fromDatePickerIndexPath = IndexPath(row: 4, section: 0)
    fileprivate var toDateIndexPath = IndexPath(row: 5, section: 0)
    fileprivate var toDatePickerIndexPath = IndexPath(row: 6, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isNewWorkExperience {
            self.workExperience = WorkExperience()
            self.workExperience?.fromMonth = NSNumber(value: currentMonth)
            self.workExperience?.fromYear = NSNumber(value: currentYear)
            self.workExperience?.toMonth = NSNumber(value: currentMonth)
            self.workExperience?.toYear = NSNumber(value: currentYear)
            self.isCurrentlyDoing = false
            self.saveButton.isEnabled = false
        } else {
            if self.workExperience?.toMonth == nil && self.workExperience?.toYear == nil {
                self.isCurrentlyDoing = true
                // Set initial dates in case user switches currentlyDoing.
                self.workExperience?.toMonth = NSNumber(value: currentMonth)
                self.workExperience?.toYear = NSNumber(value: currentYear)
            }
            // TODO
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditWorkTitle", for: indexPath) as! EditWorkTitleTableViewCell
            cell.titleTextField.text = self.workExperience?.title
            cell.titleTextField.delegate = self
            cell.editWorkTitleTableViewCellDelegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditWorkOrganization", for: indexPath) as! EditWorkOrganizationTableViewCell
            cell.organizationTextField.text = self.workExperience?.organization
            cell.organizationTextField.delegate = self
            cell.editWorkOrganizationTableViewCellDelegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditWorkDescription", for: indexPath) as! EditWorkDescriptionTableViewCell
            cell.workDescriptionTextView.text = self.workExperience?.workDescription
            cell.workDescriptionFakePlaceholderLabel.isHidden = self.workExperience?.workDescription != nil ? true : false
            cell.editWorkDescriptionTableViewCellDelegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDate", for: indexPath) as! DateTableViewCell
            cell.titleLabel.text = "From"
            cell.monthLabel.text = self.workExperience?.fromMonthInt?.numberToMonth()
            cell.yearLabel.text = self.workExperience?.fromYearInt?.numberToYear()
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDatePicker", for: indexPath) as! DatePickerTableViewCell
            cell.datePickerTableViewCellDelegate = self
            cell.indexPath = indexPath
            if let fromMonthInt = self.workExperience?.fromMonthInt {
                cell.setSelectedMonth(fromMonthInt)
            }
            if let fromYearInt = self.workExperience?.fromYearInt {
                cell.setSelectedYear(fromYearInt)
            }
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDate", for: indexPath) as! DateTableViewCell
            cell.titleLabel.text = "To"
            if self.isCurrentlyDoing {
                cell.monthLabel.text = nil
                cell.yearLabel.text = "Present"
            } else {
                cell.monthLabel.text = self.workExperience?.toMonthInt?.numberToMonth()
                cell.yearLabel.text = self.workExperience?.toYearInt?.numberToYear()
            }
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDatePicker", for: indexPath) as! DatePickerTableViewCell
            cell.datePickerTableViewCellDelegate = self
            cell.indexPath = indexPath
            if let toMonthInt = self.workExperience?.toMonthInt {
                cell.setSelectedMonth(toMonthInt)
            }
            if let toYearInt = self.workExperience?.toYearInt {
                cell.setSelectedYear(toYearInt)
            }
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCurrentlyDoing", for: indexPath) as! CurrentlyDoingTableViewCell
            cell.titleLabel.text = "I currently work here"
            cell.currentlyDoingSwitch.isOn = self.isCurrentlyDoing
            cell.currentlyDoingTableViewCellDelegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if cell is DateTableViewCell {
            cell.selectionStyle = UITableViewCellSelectionStyle.default
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath == self.fromDateIndexPath {
            self.fromDatePickerActive = !self.fromDatePickerActive
            if self.toDatePickerActive {
                self.toDatePickerActive = false
            }
            tableView.beginUpdates()
            tableView.endUpdates()
            self.view.endEditing(true)
        }
        if indexPath == self.toDateIndexPath && !self.isCurrentlyDoing {
            self.toDatePickerActive = !self.toDatePickerActive
            if self.fromDatePickerActive {
                self.fromDatePickerActive = false
            }
            tableView.beginUpdates()
            tableView.endUpdates()
            self.view.endEditing(true)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == self.fromDatePickerIndexPath {
            return self.fromDatePickerActive ? 216.0 : 0.0
        }
        if indexPath == self.toDatePickerIndexPath {
            return self.toDatePickerActive ? 216.0 : 0.0
        }
        if indexPath == self.workDescriptionIndexPath {
            return 52.0
        }
        return 52.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == self.fromDatePickerIndexPath {
            return self.fromDatePickerActive ? 216.0 : 0.0
        }
        if indexPath == self.toDatePickerIndexPath {
            return self.toDatePickerActive ? 216.0 : 0.0
        }
        if indexPath == self.workDescriptionIndexPath {
            return UITableViewAutomaticDimension
        }
        return 52.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: Helpers
    
    fileprivate func removeDatePickers() {
        if self.fromDatePickerActive {
            self.fromDatePickerActive = false
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        if self.toDatePickerActive {
            self.toDatePickerActive = false
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.removeDatePickers()
        if self.isCurrentlyDoing {
            // Remove values.
            self.workExperience?.toMonth = nil
            self.workExperience?.toYear = nil
        }
        if self.isNewWorkExperience {
            self.createWorkExperience()
        } else {
            self.updateWorkExperience()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.removeDatePickers()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: IBActions
    
    fileprivate func createWorkExperience() {
        guard let workExperience = self.workExperience else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        PRFYDynamoDBManager.defaultDynamoDBManager().createWorkExperienceDynamoDB(workExperience.title, organization: workExperience.organization, workDescription: workExperience.workDescription, fromMonth: workExperience.fromMonth, fromYear: workExperience.fromYear, toMonth: workExperience.toMonth, toYear: workExperience.toYear, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("createWorkExperience error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    guard let awsWorkExperience = task.result as? AWSWorkExperience else {
                        print("No awsWorkExperience")
                        return
                    }
                    let workExperience = WorkExperience(userId: awsWorkExperience._userId, workExperienceId: awsWorkExperience._workExperienceId, title: awsWorkExperience._title, organization: awsWorkExperience._organization, workDescription: awsWorkExperience._workDescription, fromMonth: awsWorkExperience._fromMonth, fromYear: awsWorkExperience._fromYear, toMonth: awsWorkExperience._toMonth, toYear: awsWorkExperience._toYear)
                    self.editWorkExperienceTableViewControllerDelegate?.didEditWorkExperience(workExperience, isNewWorkExperience: self.isNewWorkExperience, indexPath: self.indexPath)
                    self.dismiss(animated: true, completion: nil)
                }
            })
            return nil
        })
    }
    
    fileprivate func updateWorkExperience() {
        guard let workExperience = self.workExperience else {
            return
        }
        guard let workExperienceId = workExperience.workExperienceId else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        PRFYDynamoDBManager.defaultDynamoDBManager().updateWorkExperienceDynamoDB(workExperienceId, title: workExperience.title, organization: workExperience.organization, workDescription: workExperience.workDescription, fromMonth: workExperience.fromMonth, fromYear: workExperience.fromYear, toMonth: workExperience.toMonth, toYear: workExperience.toYear, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("updateWorkExperience error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    guard let awsWorkExperienceUpdate = task.result as? AWSWorkExperienceUpdate else {
                        print("No awsWorkExperienceUpdate")
                        return
                    }
                    let workExperience = WorkExperience(userId: awsWorkExperienceUpdate._userId, workExperienceId: awsWorkExperienceUpdate._workExperienceId, title: awsWorkExperienceUpdate._title, organization: awsWorkExperienceUpdate._organization, workDescription: awsWorkExperienceUpdate._workDescription, fromMonth: awsWorkExperienceUpdate._fromMonth, fromYear: awsWorkExperienceUpdate._fromYear, toMonth: awsWorkExperienceUpdate._toMonth, toYear: awsWorkExperienceUpdate._toYear)
                    self.editWorkExperienceTableViewControllerDelegate?.didEditWorkExperience(workExperience, isNewWorkExperience: self.isNewWorkExperience, indexPath: self.indexPath)
                    self.dismiss(animated: true, completion: nil)
                }
            })
            return nil
        })
    }
}

extension EditWorkExperienceTableViewController: DatePickerTableViewCellDelegate {
    
    func didSelectMonth(_ month: Int, indexPath: IndexPath) {
        if indexPath == self.fromDatePickerIndexPath {
            self.workExperience?.fromMonth = NSNumber(value: month)
            self.tableView.reloadRows(at: [self.fromDateIndexPath], with: UITableViewRowAnimation.none)
        }
        if indexPath == self.toDatePickerIndexPath {
            self.workExperience?.toMonth = NSNumber(value: month)
            self.tableView.reloadRows(at: [self.toDateIndexPath], with: UITableViewRowAnimation.none)
        }
    }
    
    func didSelectYear(_ year: Int, indexPath: IndexPath) {
        if indexPath == self.fromDatePickerIndexPath {
            self.workExperience?.fromYear = NSNumber(value: year)
            self.tableView.reloadRows(at: [self.fromDateIndexPath], with: UITableViewRowAnimation.none)
        }
        if indexPath == self.toDatePickerIndexPath {
            self.workExperience?.toYear = NSNumber(value: year)
            self.tableView.reloadRows(at: [self.toDateIndexPath], with: UITableViewRowAnimation.none)
        }
    }
}

extension EditWorkExperienceTableViewController: CurrentlyDoingTableViewCellDelegate {
    
    func switchChanged(_ isOn: Bool) {
        self.isCurrentlyDoing = isOn
        self.removeDatePickers()
        self.tableView.reloadRows(at: [self.toDateIndexPath], with: UITableViewRowAnimation.none)
        self.view.endEditing(true)
    }
}

extension EditWorkExperienceTableViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.removeDatePickers()
    }
}

extension EditWorkExperienceTableViewController: EditWorkTitleTableViewCellDelegate {
    
    func titleTextFieldChanged(_ text: String) {
        self.workExperience?.title = text.trimm().isEmpty ? nil : text.trimm()
        self.saveButton.isEnabled = text.trimm().isEmpty ? false : true
    }
}

extension EditWorkExperienceTableViewController: EditWorkOrganizationTableViewCellDelegate {
    
    func organizationTextFieldChanged(_ text: String) {
        self.workExperience?.organization = text.trimm().isEmpty ? nil : text.trimm()
    }
}

extension EditWorkExperienceTableViewController: EditWorkDescriptionTableViewCellDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.removeDatePickers()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // Change height of tableViewCell and scroll to bottom of tableView.
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
        self.workExperience?.workDescription = textView.text.trimm().isEmpty ? nil : textView.text.trimm()
    }
}
