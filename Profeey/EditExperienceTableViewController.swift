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
    case Work
    case Education
}

class EditExperienceTableViewController: UITableViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Incoming data.
    var userExperience: UserExperience?
    var experienceType: ExperienceType?
    var experienceIndexPath: NSIndexPath?
    
    // Outgoing data.
    var savedUserExperience: UserExperience?
    
    private var experienceId: String?
    private var position: String?
    private var organization: String?
    private var fromDate: NSNumber?
    private var toDate: NSNumber?
    private var experienceTypeNumber: NSNumber?
    
    private var fromMonth: Int?
    private var fromYear: Int?
    private var toMonth: Int?
    private var toYear: Int?
    
    private var fromDatePickerActive: Bool = false
    private var toDatePickerActive: Bool = false
    private var isCurrentlyWorking: Bool = true
    private var months: [Int] = []
    private var years: [Int] = []
    private var currentMonth: Int!
    private var currentYear: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDate()
        self.configureExperienceData()
        if self.experienceType == .Work {
            self.navigationItem.title = self.experienceIndexPath != nil ? "Edit work experience" : "Add work experience"
        }
        if self.experienceType == .Education {
            self.navigationItem.title = self.experienceIndexPath != nil ? "Edit education" : "Add education"
        }
        self.saveButton.enabled = (self.experienceIndexPath != nil)
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
    
    private func configureDate() {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month], fromDate: date)
        self.currentMonth = components.month
        self.currentYear = components.year
        self.months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        for year in components.year.stride(to: 1950, by: -1) {
            self.years.append(year)
        }
    }
    
    private func configureExperienceData() {
        self.experienceId = self.userExperience?.experienceId
        self.position = self.userExperience?.position
        self.organization = self.userExperience?.organization
        self.fromMonth = (self.userExperience?.fromMonth != nil) ? self.userExperience?.fromMonth : self.currentMonth
        self.fromYear = (self.userExperience?.fromYear != nil) ? self.userExperience?.fromYear : self.currentYear
        self.toMonth = (self.userExperience?.toMonth != nil) ? self.userExperience?.toMonth : self.currentMonth
        self.toYear = (self.userExperience?.toYear != nil) ? self.userExperience?.toYear : self.currentYear
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.experienceIndexPath != nil {
            return 5
        }
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellPosition", forIndexPath: indexPath) as! PositionTableViewCell
                if self.experienceType == .Work {
                    cell.positionTextField.placeholder = "Position"
                }
                if self.experienceType == .Education {
                    cell.positionTextField.placeholder = "Degree"
                }
                cell.positionTextField.text = self.position
                cell.positionTextField.delegate = self
                cell.positionTextField.addTarget(self, action: #selector(EditExperienceTableViewController.positionTextFieldDidEndEditing(_:)), forControlEvents: UIControlEvents.EditingChanged)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellOrganization", forIndexPath: indexPath) as! OrganizationTableViewCell
                if self.experienceType == .Work {
                    cell.organizationTextField.placeholder = "Organization"
                }
                if self.experienceType == .Education {
                    cell.organizationTextField.placeholder = "School"
                }
                cell.organizationTextField.text = self.organization
                cell.organizationTextField.delegate = self
                cell.organizationTextField.addTarget(self, action: #selector(EditExperienceTableViewController.organizationTextFieldDidEndEditing(_:)), forControlEvents: UIControlEvents.EditingChanged)
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellDate", forIndexPath: indexPath) as! DateTableViewCell
                cell.titleLabel.text = "From"
                if let fromMonth = self.fromMonth {
                    cell.monthLabel.text = fromMonth.numberToMonth()
                }
                if let fromYear = self.fromYear {
                    cell.yearLabel.text = String(fromYear)
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellDatePicker", forIndexPath: indexPath) as! DatePickerTableViewCell
                cell.pickerView.dataSource = self
                cell.pickerView.delegate = self
                if let fromMonth = self.fromMonth, let fromMonthIndex = self.months.indexOf(fromMonth) {
                    cell.pickerView.selectRow(fromMonthIndex, inComponent: 0, animated: false)
                }
                if let fromYear = self.fromYear, let fromYearIndex = self.years.indexOf(fromYear) {
                    cell.pickerView.selectRow(fromYearIndex, inComponent: 1, animated: false)
                }
                return cell
            default:
                return UITableViewCell()
            }
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellDate", forIndexPath: indexPath) as! DateTableViewCell
                cell.titleLabel.text = "To"
                if let toMonth = self.toMonth {
                    cell.monthLabel.text = toMonth.numberToMonth()
                }
                if let toYear = self.toYear {
                    cell.yearLabel.text = String(toYear)
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellDatePicker", forIndexPath: indexPath) as! DatePickerTableViewCell
                cell.pickerView.dataSource = self
                cell.pickerView.delegate = self
                if let toMonth = self.toMonth, let toMonthIndex = self.months.indexOf(toMonth) {
                    cell.pickerView.selectRow(toMonthIndex, inComponent: 0, animated: false)
                }
                if let toYear = self.toYear, let toYearIndex = self.years.indexOf(toYear) {
                    cell.pickerView.selectRow(toYearIndex, inComponent: 1, animated: false)
                }
                return cell
            default:
                return UITableViewCell()
            }
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellCurrentlyWorking", forIndexPath: indexPath) as! CurrentlyWorkingTableViewCell
            if self.experienceType == .Work {
                cell.titleLabel.text = "I currently work here"
            }
            if self.experienceType == .Education {
                cell.titleLabel.text = "I currently study here"
            }
            cell.currentlyWorkingSwitch.setOn(self.isCurrentlyWorking, animated: false)
            cell.currentlyWorkingSwitch.addTarget(self, action: #selector(EditExperienceTableViewController.currentlyWorkingSwitchChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellDeleteExperience", forIndexPath: indexPath) as! DeleteExperienceTableViewCell
            cell.deleteExperienceLabel.text = (self.experienceType == .Work) ? "Delete experience" : "Delete education"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath == NSIndexPath(forRow: 0, inSection: 1) {
            tableView.beginUpdates()
            if self.fromDatePickerActive {
                self.fromDatePickerActive = false
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Automatic)
            } else {
                if self.toDatePickerActive {
                    self.toDatePickerActive = false
                    tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                self.fromDatePickerActive = true
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            tableView.endUpdates()
            self.view.endEditing(true)
        }
        if indexPath == NSIndexPath(forRow: 0, inSection: 2) {
            tableView.beginUpdates()
            if self.toDatePickerActive {
                self.toDatePickerActive = false
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Automatic)
            } else {
                if self.fromDatePickerActive {
                    self.fromDatePickerActive = false
                    tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                self.toDatePickerActive = true
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            tableView.endUpdates()
            self.view.endEditing(true)
        }
        if indexPath == NSIndexPath(forRow: 0, inSection: 4) {
            self.prepareForRemove()
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        if cell is DateTableViewCell {
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
        }
        if cell is DeleteExperienceTableViewCell {
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == NSIndexPath(forRow: 1, inSection: 1) {
            return 216.0
        }
        if indexPath == NSIndexPath(forRow: 1, inSection: 2) {
            return 216.0
        }
        return 52.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == NSIndexPath(forRow: 1, inSection: 1) {
            return 216.0
        }
        if indexPath == NSIndexPath(forRow: 1, inSection: 2) {
            return 216.0
        }
        return 52.0
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: Tappers
    
    func positionTextFieldDidEndEditing(sender: AnyObject) {
        guard let textField = sender as? UITextField, let text = textField.text else {
            return
        }
        self.position = text.trimm().isEmpty ? nil : text.trimm()
        self.saveButton.enabled = (self.position != nil && self.organization != nil)
    }
    
    func organizationTextFieldDidEndEditing(sender: AnyObject) {
        guard let textField = sender as? UITextField, let text = textField.text else {
            return
        }
        self.organization = text.trimm().isEmpty ? nil : text.trimm()
        self.saveButton.enabled = (self.position != nil && self.organization != nil)
    }
    
    func currentlyWorkingSwitchChanged(sender: AnyObject) {
        guard let currentlyWorkingSwitch = sender as? UISwitch else {
            return
        }
        //self.removeDatePickers()
        if currentlyWorkingSwitch.on {
            self.isCurrentlyWorking = true
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Automatic)
            if self.toDatePickerActive {
                self.toDatePickerActive = false
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            self.tableView.endUpdates()
        } else {
            self.isCurrentlyWorking = false
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.endUpdates()
        }
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.prepareForSave()
    }
    
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Helpers
    
    private func removeDatePickers() {
        if self.fromDatePickerActive {
            self.tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.fromDatePickerActive = false
            self.tableView.endUpdates()
        }
        if self.toDatePickerActive {
            self.tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.toDatePickerActive = false
            self.tableView.endUpdates()
        }
    }
    
    private func prepareForSave() {
        // Set fromDate.
        guard let fromMonth = self.fromMonth, let fromYear = self.fromYear else {
            return
        }
        let calendar = NSCalendar.currentCalendar()
        let dateCompontents = NSDateComponents()
        dateCompontents.setValue(fromMonth, forComponent: .Month)
        dateCompontents.setValue(fromYear, forComponent: .Year)
        guard let fromDate = calendar.dateFromComponents(dateCompontents) else {
            return
        }
        self.fromDate = NSNumber(double: fromDate.timeIntervalSince1970)
        
        // Set toDate.
        if self.isCurrentlyWorking {
            self.toDate = nil
        } else {
            guard let toMonth = self.toMonth, let toYear = self.toYear else {
                return
            }
            dateCompontents.setValue(toMonth, forComponent: .Month)
            dateCompontents.setValue(toYear, forComponent: .Year)
            guard let toDate = calendar.dateFromComponents(dateCompontents) else {
                return
            }
            self.toDate = NSNumber(double: toDate.timeIntervalSince1970)
        }
        self.experienceTypeNumber = (self.experienceType == .Work) ? 0 : 1
        self.saveUserExperience()
    }
    
    private func prepareForRemove() {
        let alertController = UIAlertController(title: "Deleting experience", message: "Are you sure you want to delete this experience.", preferredStyle: UIAlertControllerStyle.Alert)
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {
            (alertAction: UIAlertAction) in
            self.removeUserExperience()
        })
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: AWS
    
    private func saveUserExperience() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        PRFYDynamoDBManager.defaultDynamoDBManager().saveUserExperienceDynamoDB(self.experienceId, position: self.position, organization: self.organization, fromDate: self.fromDate, toDate: self.toDate, experienceType: self.experienceTypeNumber, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("saveUserExperience error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    guard let awsUserExperience = task.result as? AWSUserExperience else {
                        return
                    }
                    self.savedUserExperience = UserExperience(userId: awsUserExperience._userId, experienceId: awsUserExperience._experienceId, position: awsUserExperience._position, organization: awsUserExperience._organization, fromDate: awsUserExperience._fromDate, toDate: awsUserExperience._toDate, experienceType: awsUserExperience._experienceType)
                    self.performSegueWithIdentifier("segueUnwindToExperiencesVc", sender: self)
                }
            })
            return nil
        })
    }
    
    private func removeUserExperience() {
        guard let experienceId = self.experienceId else {
            return
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        FullScreenIndicator.show()
        PRFYDynamoDBManager.defaultDynamoDBManager().removeUserExperienceDynamoDB(experienceId, completionHandler: {
            (task: AWSTask) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                FullScreenIndicator.hide()
                if let error = task.error {
                    print("removeUserExperience error: \(error)")
                    let alertController = self.getSimpleAlertWithTitle("Something went wrong", message: error.userInfo["message"] as? String, cancelButtonTitle: "Ok")
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    self.savedUserExperience = nil
                    self.performSegueWithIdentifier("segueUnwindToExperiencesVc", sender: self)
                }
            })
            return nil
        })
    }
}

extension EditExperienceTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return self.months.count
        } else {
            return self.years.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return self.months[row].numberToMonth()
        } else {
            return String(self.years[row])
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.fromDatePickerActive {
            if component == 0 {
                self.fromMonth = self.months[row]
            } else if component == 1 {
                self.fromYear = self.years[row]
            }
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: UITableViewRowAnimation.None)
        } else if self.toDatePickerActive {
            if component == 0 {
                self.toMonth = self.months[row]
            } else if component == 1 {
                self.toYear = self.years[row]
            }
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 2)], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
}

extension EditExperienceTableViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.removeDatePickers()
    }
}
