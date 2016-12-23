//
//  EditEducationTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/10/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class EditEducationTableViewController: UITableViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var education: Education?
    var isNewEducation: Bool = true
    
    fileprivate var fromDatePickerActive: Bool = false
    fileprivate var toDatePickerActive: Bool = false
    fileprivate var isCurrentlyDoing: Bool = false
    
    fileprivate var currentMonth = Calendar.current.component(.month, from: Date())
    fileprivate var currentYear = Calendar.current.component(.year, from: Date())
    fileprivate var educationDescriptionIndexPath = IndexPath(row: 2, section: 0)
    fileprivate var fromDateIndexPath = IndexPath(row: 3, section: 0)
    fileprivate var fromDatePickerIndexPath = IndexPath(row: 4, section: 0)
    fileprivate var toDateIndexPath = IndexPath(row: 5, section: 0)
    fileprivate var toDatePickerIndexPath = IndexPath(row: 6, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureEducation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureEducation() {
        if self.isNewEducation {
            self.education = Education()
            self.education?.fromMonth = NSNumber(value: currentMonth)
            self.education?.fromYear = NSNumber(value: currentYear)
            self.education?.toMonth = NSNumber(value: currentMonth)
            self.education?.toYear = NSNumber(value: currentYear)
            self.isCurrentlyDoing = false
            self.saveButton.isEnabled = false
        } else {
            if self.education?.toMonth == nil && self.education?.toYear == nil {
                self.isCurrentlyDoing = true
                // Set initial dates in case user switches currentlyDoing.
                self.education?.toMonth = NSNumber(value: currentMonth)
                self.education?.toYear = NSNumber(value: currentYear)
            }
        }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditEducationSchool", for: indexPath) as! EditEducationSchoolTableViewCell
            cell.schoolTextField.text = self.education?.school
            cell.schoolTextField.delegate = self
            cell.editEducationSchoolTableViewCellDelegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditEducationFieldOfStudy", for: indexPath) as! EditEducationFieldOfStudyTableViewCell
            cell.fieldOfStudyTextField.text = self.education?.fieldOfStudy
            cell.fieldOfStudyTextField.delegate = self
            cell.editEducationFieldOfStudyTableViewCellDelegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEditEducationDescription", for: indexPath) as! EditEducationDescriptionTableViewCell
            cell.educationDescriptionTextView.text = self.education?.educationDescription
            cell.educationDescriptionFakePlaceholderLabel.isHidden = self.education?.educationDescription != nil ? true : false
            cell.editEducationDescriptionTableViewCellDelegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDate", for: indexPath) as! DateTableViewCell
            cell.titleLabel.text = "From"
            cell.monthLabel.text = self.education?.fromMonthInt?.numberToMonth()
            cell.yearLabel.text = self.education?.fromYearInt?.numberToYear()
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDatePicker", for: indexPath) as! DatePickerTableViewCell
            cell.datePickerTableViewCellDelegate = self
            cell.indexPath = indexPath
            if let fromMonthInt = self.education?.fromMonthInt {
                cell.setSelectedMonth(fromMonthInt)
            }
            if let fromYearInt = self.education?.fromYearInt {
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
                cell.monthLabel.text = self.education?.toMonthInt?.numberToMonth()
                cell.yearLabel.text = self.education?.toYearInt?.numberToYear()
            }
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDatePicker", for: indexPath) as! DatePickerTableViewCell
            cell.datePickerTableViewCellDelegate = self
            cell.indexPath = indexPath
            if let toMonthInt = self.education?.toMonthInt {
                cell.setSelectedMonth(toMonthInt)
            }
            if let toYearInt = self.education?.toYearInt {
                cell.setSelectedYear(toYearInt)
            }
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCurrentlyDoing", for: indexPath) as! CurrentlyDoingTableViewCell
            cell.titleLabel.text = "I currently study here"
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
        if indexPath == self.educationDescriptionIndexPath {
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
        if indexPath == self.educationDescriptionIndexPath {
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
            self.education?.toMonth = nil
            self.education?.toYear = nil
        }
        if self.isNewEducation {
            self.createEducation()
        } else {
            self.updateEducation()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.removeDatePickers()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: IBActions
    
    fileprivate func createEducation() {
        guard let education = self.education else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        PRFYDynamoDBManager.defaultDynamoDBManager().createEducationDynamoDB(education.school, fieldOfStudy: education.fieldOfStudy, educationDescription: education.educationDescription, fromMonth: education.fromMonth, fromYear: education.fromYear, toMonth: education.toMonth, toYear: education.toYear, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("createEducation error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    guard let awsEducation = task.result as? AWSEducation else {
                        print("No awsEducation")
                        return
                    }
                    let education = Education(userId: awsEducation._userId, educationId: awsEducation._educationId, school: awsEducation._school, fieldOfStudy: awsEducation._fieldOfStudy, educationDescription: awsEducation._educationDescription, fromMonth: awsEducation._fromMonth, fromYear: awsEducation._fromYear, toMonth: awsEducation._toMonth, toYear: awsEducation._toYear)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: CreateEducationNotificationKey), object: self, userInfo: ["education": education])
                    self.dismiss(animated: true, completion: nil)
                }
            })
            return nil
        })
    }
    
    fileprivate func updateEducation() {
        guard let education = self.education else {
            return
        }
        guard let educationId = education.educationId else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        PRFYDynamoDBManager.defaultDynamoDBManager().updateEducationDynamoDB(educationId, school: education.school, fieldOfStudy: education.fieldOfStudy, educationDescription: education.educationDescription, fromMonth: education.fromMonth, fromYear: education.fromYear, toMonth: education.toMonth, toYear: education.toYear, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("updateEducation error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    guard let awsEducationUpdate = task.result as? AWSEducationUpdate else {
                        print("No awsEducationUpdate")
                        return
                    }
                    let education = Education(userId: awsEducationUpdate._userId, educationId: awsEducationUpdate._educationId, school: awsEducationUpdate._school, fieldOfStudy: awsEducationUpdate._fieldOfStudy, educationDescription: awsEducationUpdate._educationDescription, fromMonth: awsEducationUpdate._fromMonth, fromYear: awsEducationUpdate._fromYear, toMonth: awsEducationUpdate._toMonth, toYear: awsEducationUpdate._toYear)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: UpdateEducationNotificationKey), object: self, userInfo: ["education": education])
                    self.dismiss(animated: true, completion: nil)
                }
            })
            return nil
        })
    }
}

extension EditEducationTableViewController: DatePickerTableViewCellDelegate {
    
    func didSelectMonth(_ month: Int, indexPath: IndexPath) {
        if indexPath == self.fromDatePickerIndexPath {
            self.education?.fromMonth = NSNumber(value: month)
            self.tableView.reloadRows(at: [self.fromDateIndexPath], with: UITableViewRowAnimation.none)
        }
        if indexPath == self.toDatePickerIndexPath {
            self.education?.toMonth = NSNumber(value: month)
            self.tableView.reloadRows(at: [self.toDateIndexPath], with: UITableViewRowAnimation.none)
        }
    }
    
    func didSelectYear(_ year: Int, indexPath: IndexPath) {
        if indexPath == self.fromDatePickerIndexPath {
            self.education?.fromYear = NSNumber(value: year)
            self.tableView.reloadRows(at: [self.fromDateIndexPath], with: UITableViewRowAnimation.none)
        }
        if indexPath == self.toDatePickerIndexPath {
            self.education?.toYear = NSNumber(value: year)
            self.tableView.reloadRows(at: [self.toDateIndexPath], with: UITableViewRowAnimation.none)
        }
    }
}

extension EditEducationTableViewController: CurrentlyDoingTableViewCellDelegate {
    
    func switchChanged(_ isOn: Bool) {
        self.isCurrentlyDoing = isOn
        self.removeDatePickers()
        self.tableView.reloadRows(at: [self.toDateIndexPath], with: UITableViewRowAnimation.none)
        self.view.endEditing(true)
    }
}

extension EditEducationTableViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.removeDatePickers()
    }
}

extension EditEducationTableViewController: EditEducationSchoolTableViewCellDelegate {
    
    func schoolTextFieldChanged(_ text: String) {
        self.education?.school = text.trimm().isEmpty ? nil : text.trimm()
        self.saveButton.isEnabled = text.trimm().isEmpty ? false : true
    }
}

extension EditEducationTableViewController: EditEducationFieldOfStudyTableViewCellDelegate {
    
    func fieldOfStudyTextFieldChanged(_ text: String) {
        self.education?.fieldOfStudy = text.trimm().isEmpty ? nil : text.trimm()
    }
}

extension EditEducationTableViewController: EditEducationDescriptionTableViewCellDelegate {
    
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
        self.education?.educationDescription = textView.text.trimm().isEmpty ? nil : textView.text.trimm()
    }
}
