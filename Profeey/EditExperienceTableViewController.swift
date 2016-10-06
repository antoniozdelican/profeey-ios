//
//  EditExperienceTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 19/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

enum ExperienceType {
    case work
    case education
}

class EditExperienceTableViewController: UITableViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Incoming data.
    var userExperience: UserExperience?
    var experienceType: ExperienceType?
    var experienceIndexPath: IndexPath?
    
    // Outgoing data.
    var savedUserExperience: UserExperience?
    
    fileprivate var experienceId: String?
    fileprivate var position: String?
    fileprivate var organization: String?
    fileprivate var fromDate: NSNumber?
    fileprivate var toDate: NSNumber?
    fileprivate var experienceTypeNumber: NSNumber?
    
    fileprivate var fromMonth: Int?
    fileprivate var fromYear: Int?
    fileprivate var toMonth: Int?
    fileprivate var toYear: Int?
    
    fileprivate var fromDatePickerActive: Bool = false
    fileprivate var toDatePickerActive: Bool = false
    fileprivate var isCurrentlyWorking: Bool = true
    fileprivate var months: [Int] = []
    fileprivate var years: [Int] = []
    fileprivate var currentMonth: Int!
    fileprivate var currentYear: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDate()
        self.configureExperienceData()
        if self.experienceType == .work {
            self.navigationItem.title = self.experienceIndexPath != nil ? "Edit work experience" : "Add work experience"
        }
        if self.experienceType == .education {
            self.navigationItem.title = self.experienceIndexPath != nil ? "Edit education" : "Add education"
        }
        self.saveButton.isEnabled = (self.experienceIndexPath != nil)
        if self.experienceIndexPath != nil {
            self.isCurrentlyWorking = (self.userExperience?.toDate == nil)
        } else {
            self.isCurrentlyWorking = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Configuration
    
    fileprivate func configureDate() {
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month], from: date)
        self.currentMonth = components.month
        self.currentYear = components.year
        self.months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        for year in stride(from: currentYear, to: 1950, by: -1) {
            self.years.append(year)
        }
    }
    
    fileprivate func configureExperienceData() {
        self.experienceId = self.userExperience?.experienceId
        self.position = self.userExperience?.position
        self.organization = self.userExperience?.organization
        self.fromMonth = (self.userExperience?.fromMonth != nil) ? self.userExperience?.fromMonth : self.currentMonth
        self.fromYear = (self.userExperience?.fromYear != nil) ? self.userExperience?.fromYear : self.currentYear
        self.toMonth = (self.userExperience?.toMonth != nil) ? self.userExperience?.toMonth : self.currentMonth
        self.toYear = (self.userExperience?.toYear != nil) ? self.userExperience?.toYear : self.currentYear
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.experienceIndexPath != nil {
            return 5
        }
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return self.fromDatePickerActive ? 2 : 1
        case 2:
            guard !self.isCurrentlyWorking else {
                return 0
            }
            return self.toDatePickerActive ? 2 : 1
        case 3:
            return 1
        case 4:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellPosition", for: indexPath) as! PositionTableViewCell
                if self.experienceType == .work {
                    cell.positionTextField.placeholder = "Position"
                }
                if self.experienceType == .education {
                    cell.positionTextField.placeholder = "Degree"
                }
                cell.positionTextField.text = self.position
                cell.positionTextField.delegate = self
                cell.positionTextField.addTarget(self, action: #selector(EditExperienceTableViewController.positionTextFieldDidEndEditing(_:)), for: UIControlEvents.editingChanged)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellOrganization", for: indexPath) as! OrganizationTableViewCell
                if self.experienceType == .work {
                    cell.organizationTextField.placeholder = "Organization"
                }
                if self.experienceType == .education {
                    cell.organizationTextField.placeholder = "School"
                }
                cell.organizationTextField.text = self.organization
                cell.organizationTextField.delegate = self
                cell.organizationTextField.addTarget(self, action: #selector(EditExperienceTableViewController.organizationTextFieldDidEndEditing(_:)), for: UIControlEvents.editingChanged)
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            switch (indexPath as NSIndexPath).row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellDate", for: indexPath) as! DateTableViewCell
                cell.titleLabel.text = "From"
                if let fromMonth = self.fromMonth {
                    cell.monthLabel.text = fromMonth.numberToMonth()
                }
                if let fromYear = self.fromYear {
                    cell.yearLabel.text = String(fromYear)
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellDatePicker", for: indexPath) as! DatePickerTableViewCell
                cell.pickerView.dataSource = self
                cell.pickerView.delegate = self
                if let fromMonth = self.fromMonth, let fromMonthIndex = self.months.index(of: fromMonth) {
                    cell.pickerView.selectRow(fromMonthIndex, inComponent: 0, animated: false)
                }
                if let fromYear = self.fromYear, let fromYearIndex = self.years.index(of: fromYear) {
                    cell.pickerView.selectRow(fromYearIndex, inComponent: 1, animated: false)
                }
                return cell
            default:
                return UITableViewCell()
            }
        case 2:
            switch (indexPath as NSIndexPath).row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellDate", for: indexPath) as! DateTableViewCell
                cell.titleLabel.text = "To"
                if let toMonth = self.toMonth {
                    cell.monthLabel.text = toMonth.numberToMonth()
                }
                if let toYear = self.toYear {
                    cell.yearLabel.text = String(toYear)
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellDatePicker", for: indexPath) as! DatePickerTableViewCell
                cell.pickerView.dataSource = self
                cell.pickerView.delegate = self
                if let toMonth = self.toMonth, let toMonthIndex = self.months.index(of: toMonth) {
                    cell.pickerView.selectRow(toMonthIndex, inComponent: 0, animated: false)
                }
                if let toYear = self.toYear, let toYearIndex = self.years.index(of: toYear) {
                    cell.pickerView.selectRow(toYearIndex, inComponent: 1, animated: false)
                }
                return cell
            default:
                return UITableViewCell()
            }
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCurrentlyWorking", for: indexPath) as! CurrentlyWorkingTableViewCell
            if self.experienceType == .work {
                cell.titleLabel.text = "I currently work here"
            }
            if self.experienceType == .education {
                cell.titleLabel.text = "I currently study here"
            }
            cell.currentlyWorkingSwitch.setOn(self.isCurrentlyWorking, animated: false)
            cell.currentlyWorkingSwitch.addTarget(self, action: #selector(EditExperienceTableViewController.currentlyWorkingSwitchChanged(_:)), for: UIControlEvents.valueChanged)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDeleteExperience", for: indexPath) as! DeleteExperienceTableViewCell
            cell.deleteExperienceLabel.text = (self.experienceType == .work) ? "Delete experience" : "Delete education"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == IndexPath(row: 0, section: 1) {
            tableView.beginUpdates()
            if self.fromDatePickerActive {
                self.fromDatePickerActive = false
                tableView.deleteRows(at: [IndexPath(row: 1, section: 1)], with: UITableViewRowAnimation.automatic)
            } else {
                if self.toDatePickerActive {
                    self.toDatePickerActive = false
                    tableView.deleteRows(at: [IndexPath(row: 1, section: 2)], with: UITableViewRowAnimation.automatic)
                }
                self.fromDatePickerActive = true
                tableView.insertRows(at: [IndexPath(row: 1, section: 1)], with: UITableViewRowAnimation.automatic)
            }
            tableView.endUpdates()
            self.view.endEditing(true)
        }
        if indexPath == IndexPath(row: 0, section: 2) {
            tableView.beginUpdates()
            if self.toDatePickerActive {
                self.toDatePickerActive = false
                tableView.deleteRows(at: [IndexPath(row: 1, section: 2)], with: UITableViewRowAnimation.automatic)
            } else {
                if self.fromDatePickerActive {
                    self.fromDatePickerActive = false
                    tableView.deleteRows(at: [IndexPath(row: 1, section: 1)], with: UITableViewRowAnimation.automatic)
                }
                self.toDatePickerActive = true
                tableView.insertRows(at: [IndexPath(row: 1, section: 2)], with: UITableViewRowAnimation.automatic)
            }
            tableView.endUpdates()
            self.view.endEditing(true)
        }
        if indexPath == IndexPath(row: 0, section: 4) {
            self.prepareForRemove()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if cell is DateTableViewCell {
            cell.selectionStyle = UITableViewCellSelectionStyle.default
        }
        if cell is DeleteExperienceTableViewCell {
            cell.selectionStyle = UITableViewCellSelectionStyle.default
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(row: 1, section: 1) {
            return 216.0
        }
        if indexPath == IndexPath(row: 1, section: 2) {
            return 216.0
        }
        return 52.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(row: 1, section: 1) {
            return 216.0
        }
        if indexPath == IndexPath(row: 1, section: 2) {
            return 216.0
        }
        return 52.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: Tappers
    
    func positionTextFieldDidEndEditing(_ sender: AnyObject) {
        guard let textField = sender as? UITextField, let text = textField.text else {
            return
        }
        self.position = text.trimm().isEmpty ? nil : text.trimm()
        self.saveButton.isEnabled = (self.position != nil && self.organization != nil)
    }
    
    func organizationTextFieldDidEndEditing(_ sender: AnyObject) {
        guard let textField = sender as? UITextField, let text = textField.text else {
            return
        }
        self.organization = text.trimm().isEmpty ? nil : text.trimm()
        self.saveButton.isEnabled = (self.position != nil && self.organization != nil)
    }
    
    func currentlyWorkingSwitchChanged(_ sender: AnyObject) {
        guard let currentlyWorkingSwitch = sender as? UISwitch else {
            return
        }
        //self.removeDatePickers()
        if currentlyWorkingSwitch.isOn {
            self.isCurrentlyWorking = true
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [IndexPath(row: 0, section: 2)], with: UITableViewRowAnimation.automatic)
            if self.toDatePickerActive {
                self.toDatePickerActive = false
                self.tableView.deleteRows(at: [IndexPath(row: 1, section: 2)], with: UITableViewRowAnimation.automatic)
            }
            self.tableView.endUpdates()
        } else {
            self.isCurrentlyWorking = false
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 2)], with: UITableViewRowAnimation.automatic)
            self.tableView.endUpdates()
        }
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.prepareForSave()
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helpers
    
    fileprivate func removeDatePickers() {
        if self.fromDatePickerActive {
            self.tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: 1, section: 1)], with: UITableViewRowAnimation.automatic)
            self.fromDatePickerActive = false
            self.tableView.endUpdates()
        }
        if self.toDatePickerActive {
            self.tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: 1, section: 2)], with: UITableViewRowAnimation.automatic)
            self.toDatePickerActive = false
            self.tableView.endUpdates()
        }
    }
    
    fileprivate func prepareForSave() {
        // Set fromDate.
        guard let fromMonth = self.fromMonth, let fromYear = self.fromYear else {
            return
        }
        let calendar = Calendar.current
        let dateCompontents = DateComponents()
        (dateCompontents as NSDateComponents).setValue(fromMonth, forComponent: .month)
        (dateCompontents as NSDateComponents).setValue(fromYear, forComponent: .year)
        guard let fromDate = calendar.date(from: dateCompontents) else {
            return
        }
        self.fromDate = NSNumber(value: fromDate.timeIntervalSince1970 as Double)
        
        // Set toDate.
        if self.isCurrentlyWorking {
            self.toDate = nil
        } else {
            guard let toMonth = self.toMonth, let toYear = self.toYear else {
                return
            }
            (dateCompontents as NSDateComponents).setValue(toMonth, forComponent: .month)
            (dateCompontents as NSDateComponents).setValue(toYear, forComponent: .year)
            guard let toDate = calendar.date(from: dateCompontents) else {
                return
            }
            self.toDate = NSNumber(value: toDate.timeIntervalSince1970 as Double)
        }
        self.experienceTypeNumber = (self.experienceType == .work) ? 0 : 1
        self.saveUserExperience()
    }
    
    fileprivate func prepareForRemove() {
        let alertController = UIAlertController(title: "Deleting experience", message: "Are you sure you want to delete this experience.", preferredStyle: UIAlertControllerStyle.alert)
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {
            (alertAction: UIAlertAction) in
            self.removeUserExperience()
        })
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: AWS
    
    fileprivate func saveUserExperience() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserExperienceDynamoDB(self.experienceId, position: self.position, organization: self.organization, fromDate: self.fromDate, toDate: self.toDate, experienceType: self.experienceTypeNumber, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("saveUserExperience error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    guard let awsUserExperience = task.result as? AWSUserExperience else {
                        return
                    }
                    self.savedUserExperience = UserExperience(userId: awsUserExperience._userId, experienceId: awsUserExperience._experienceId, position: awsUserExperience._position, organization: awsUserExperience._organization, fromDate: awsUserExperience._fromDate, toDate: awsUserExperience._toDate, experienceType: awsUserExperience._experienceType)
                    self.performSegue(withIdentifier: "segueUnwindToExperiencesVc", sender: self)
                }
            })
            return nil
        })
    }
    
    fileprivate func removeUserExperience() {
        guard let experienceId = self.experienceId else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        PRFYDynamoDBManager.defaultDynamoDBManager().removeUserExperienceDynamoDB(experienceId, completionHandler: {
            (task: AWSTask) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("removeUserExperience error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.localizedDescription, cancelButtonTitle: "Ok")
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.savedUserExperience = nil
                    self.performSegue(withIdentifier: "segueUnwindToExperiencesVc", sender: self)
                }
            })
            return nil
        })
    }
}

extension EditExperienceTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return self.months.count
        } else {
            return self.years.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return self.months[row].numberToMonth()
        } else {
            return String(self.years[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.fromDatePickerActive {
            if component == 0 {
                self.fromMonth = self.months[row]
            } else if component == 1 {
                self.fromYear = self.years[row]
            }
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: UITableViewRowAnimation.none)
        } else if self.toDatePickerActive {
            if component == 0 {
                self.toMonth = self.months[row]
            } else if component == 1 {
                self.toYear = self.years[row]
            }
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: UITableViewRowAnimation.none)
        }
    }
}

extension EditExperienceTableViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.removeDatePickers()
    }
}
