//
//  ReminderViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/22/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ReminderViewController: UIViewController {
    var updateDelegate: UpdateReminderDelegate?
    var saveDelegate: SaveReminderDelegate?
    let calendarManger = CalendarManager.shared
    var reminderDate: Date?

    let reminderLabel = FormingPickerLabel()
    let toggle = UISwitch()
    let defaultLabel = UILabel()
    let picker = UIDatePicker()
    
    init(reminder: Date?) {
        super.init(nibName: nil, bundle: nil)
        if let newReminder = reminder { self.reminderDate = newReminder }
        else { self.reminderDate = nil }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Reminder"

        if self.reminderDate != nil { reminderLabel.text = calendarManger.getTimeAsString(time: self.reminderDate!) }
        else { reminderLabel.text = "No Reminder" }
        configureToggle()
        configureDefaultLabel()
        configurePicker()
        configureConstraints()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            if toggle.isOn { self.reminderDate = picker.date }
            else { self.reminderDate = nil }
            updateDelegate?.updateReminder(reminder: self.reminderDate)
            saveDelegate?.saveReminder(reminder: self.reminderDate)
        }
    }
    
    func configureToggle() {
        if self.reminderDate != nil { toggle.isOn = true }
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
        if let reminder = self.reminderDate { picker.date = reminder }
        else {
            if let date = calendarManger.getTimeAsDate(time: "9:00 AM") { picker.date = date }
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
            reminderLabel.text = calendarManger.getTimeAsString(time: picker.date)
        } else {
            picker.isEnabled = false
            reminderLabel.text = "No Reminder"
        }
    }
    
    @objc func pickerChanged() {
        if picker.isEnabled { reminderLabel.text = calendarManger.getTimeAsString(time: picker.date) }
        else { reminderLabel.text = "No Reminder" }
    }
}

protocol UpdateReminderDelegate {
    func updateReminder(reminder: Date?)
}

protocol SaveReminderDelegate {
    func saveReminder(reminder: Date?)
}
