//
//  ExperienceTableViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 19/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class ExperienceTableViewController: UITableViewController {
    
    var userExperience: UserExperience?
    
    private var fromDatePickerActive: Bool = false
    private var toDatePickerActive: Bool = false
    private var isCurrentlyWorking: Bool = true
    private var months: [Int] = []
    private var years: [Int] = []
    
    private var currentMonth: Int!
    private var currentYear: Int!
    
    private var fromMonth: Int?
    private var fromYear: Int?
    private var toMonth: Int?
    private var toYear: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDate()
        
        // TEST
        let fromDate = NSNumber(double: NSDate().timeIntervalSince1970)
        self.userExperience = UserExperience(userId: nil, position: nil, organization: nil, fromDate: fromDate, toDate: nil, experienceType: 0)
        if let fromDate = self.userExperience?.fromDate {
            self.fromMonth = fromDate.getMonth()
            self.fromYear = fromDate.getYear()
        }
        if let toDate = self.userExperience?.toDate {
            self.toMonth = toDate.getMonth()
            self.toYear = toDate.getYear()
        } else {
            // In case currentlyWorking is on.
            self.toMonth = self.currentMonth
            self.toYear = self.currentYear
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

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
                cell.positionTextField.text = self.userExperience?.position
                cell.positionTextField.addTarget(self, action: #selector(ExperienceTableViewController.positionTextFieldTapped(_:)), forControlEvents: UIControlEvents.EditingDidBegin)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("cellOrganization", forIndexPath: indexPath) as! OrganizationTableViewCell
                cell.organizationTextField.text = self.userExperience?.organization
                cell.organizationTextField.addTarget(self, action: #selector(ExperienceTableViewController.organizationTextFieldTapped(_:)), forControlEvents: UIControlEvents.EditingDidBegin)
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
            cell.titleLabel.text = "I currently work here"
            cell.currentlyWorkingSwitch.setOn(self.isCurrentlyWorking, animated: false)
            cell.currentlyWorkingSwitch.addTarget(self, action: #selector(ExperienceTableViewController.currentlyWorkingSwitchChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()
        if indexPath == NSIndexPath(forRow: 0, inSection: 1) {
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
            self.view.endEditing(true)
        }
        if indexPath == NSIndexPath(forRow: 0, inSection: 2) {
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
            self.view.endEditing(true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)
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
    
    func positionTextFieldTapped(sender: AnyObject) {
        self.removeDatePickers()
    }
    
    func organizationTextFieldTapped(sender: AnyObject) {
        self.removeDatePickers()
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
}

extension ExperienceTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
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
