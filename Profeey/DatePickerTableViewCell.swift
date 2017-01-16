//
//  DatePickerTableViewCell.swift
//  Profeey
//
//  Created by Antonio Zdelican on 19/09/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

protocol DatePickerTableViewCellDelegate: class {
    func didSelectMonth(_ month: Int, indexPath: IndexPath)
    func didSelectYear(_ year: Int, indexPath: IndexPath)
}

class DatePickerTableViewCell: UITableViewCell {

    @IBOutlet weak var pickerView: UIPickerView!
    
    weak var datePickerTableViewCellDelegate: DatePickerTableViewCellDelegate?
    var indexPath: IndexPath?
    
    fileprivate var months: [Int] = []
    fileprivate var years: [Int] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.configureMonthsAndYears()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Configuration
    
    fileprivate func configureMonthsAndYears() {
        let currentYear = Calendar.current.component(.year, from: Date())
        self.months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        for year in stride(from: currentYear, to: 1950, by: -1) {
            self.years.append(year)
        }
    }
    
    func setSelectedMonth(_ month: Int) {
        if let selectedMonthIndex = self.months.index(of: month) {
            self.pickerView.selectRow(selectedMonthIndex, inComponent: 0, animated: false)
        }
    }
    
    func setSelectedYear(_ year: Int) {
        if let selectedYearIndex = self.years.index(of: year) {
            self.pickerView.selectRow(selectedYearIndex, inComponent: 1, animated: false)
        }
    }
}

extension DatePickerTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
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
            return self.years[row].numberToYear()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let indexPath = self.indexPath else {
            return
        }
        if component == 0 {
            self.datePickerTableViewCellDelegate?.didSelectMonth(self.months[row], indexPath: indexPath)
        } else if component == 1 {
            self.datePickerTableViewCellDelegate?.didSelectYear(self.years[row], indexPath: indexPath)
        }
    }
}
