//
//  ReminderViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/22/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ReminderViewController: UIViewController {
    var delegate: SaveReminderDelegate?
    var reminder: String?

    let reminderLabel = FormingPickerLabel()
    let toggle = UISwitch()
    let defaultLabel = UILabel()
    let picker = UIDatePicker()
    
    init(reminder: String?) {
        super.init(nibName: nil, bundle: nil)
        if let newReminder = reminder { self.reminder = newReminder }
        else { self.reminder = nil }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Reminder"
        
        if self.reminder != nil { reminderLabel.text = self.reminder }
        else { reminderLabel.text = "No Reminder" }
        configureToggle()
        configureDefaultLabel()
        configurePicker()
        configureConstraints()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            if toggle.isOn { self.reminder = getReminderAsString() }
            else { self.reminder = nil }
            delegate?.saveReminder(reminder: self.reminder)
        }
    }
    
    func configureToggle() {
        if self.reminder != nil { toggle.isOn = true }
        else { toggle.isOn = false }
        toggle.addTarget(self, action: #selector(toggleTapped), for: .valueChanged)
    }
    
    func configureDefaultLabel() {
        defaultLabel.text = "The default reminder is a grouped notification at 9:00 AM for all habits ocurring that day. \n\nSetting a custom reminder will send a notification only for this habit at the set time."
        defaultLabel.numberOfLines = 0
        defaultLabel.sizeToFit()
        defaultLabel.textAlignment = .center
        defaultLabel.textColor = .secondaryLabel
        defaultLabel.font = UIFont.systemFont(ofSize: 17)
    }
    
    func configurePicker() {
        picker.datePickerMode = .time
        picker.minuteInterval = 5
        if let reminder = self.reminder {
            if let date = getReminderAsDate(from: reminder) { picker.date = date }
        } else {
            if let date = getReminderAsDate(from: "9:00 AM") { picker.date = date }
            picker.isEnabled = false
        }
        picker.addTarget(self, action: #selector(pickerChanged), for: .valueChanged)
    }

    func configureConstraints() {
        let top = view.safeAreaLayoutGuide.topAnchor, left = view.leftAnchor, right = view.rightAnchor
        view.addSubview(reminderLabel)
        reminderLabel.anchor(top: top, left: left, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: view.frame.width - 96, height: 40)
        view.addSubview(toggle)
        toggle.anchor(top: top, left: reminderLabel.rightAnchor, bottom: nil, right: right, paddingTop: 20, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
        view.addSubview(picker)
        picker.anchor(top: reminderLabel.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: picker.frame.height)
        view.addSubview(defaultLabel)
        defaultLabel.anchor(top: picker.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
    }
    
    @objc func toggleTapped(sender: UISwitch) {
        if sender.isOn {
            picker.isEnabled = true
            reminderLabel.text = getReminderAsString()
        } else {
            picker.isEnabled = false
            reminderLabel.text = "No Reminder"
        }
    }
    
    @objc func pickerChanged() {
        if picker.isEnabled { reminderLabel.text = getReminderAsString() }
        else { reminderLabel.text = "No Reminder" }
    }
    
    func getReminderAsString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let time = picker.date
        return formatter.string(from: time)
    }
    
    func getReminderAsDate(from reminder: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        if let date = formatter.date(from: reminder) {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            return calendar.date(bySettingHour: hour, minute: minutes, second: 0, of: date)
        } else { return nil }
    }
}

protocol SaveReminderDelegate {
    func saveReminder(reminder: String?)
}
