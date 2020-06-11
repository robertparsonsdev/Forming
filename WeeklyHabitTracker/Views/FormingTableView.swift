//
//  FormingTableView.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/21/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class FormingTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    var priority: Int64
    var flag: Bool
    var reminder: Date?
    var tableDelegate: FormingTableViewDelegate?
    
    let priorities = [0: "None", 1: "1", 2: "2", 3: "3"]
    
    let stepper = UIStepper()
    let flagSwitch = UISwitch()
    let haptics = UISelectionFeedbackGenerator()
    
    init(priority: Int64, reminder: Date?, flag: Bool) {
        self.priority = priority
        self.flag = flag
        self.reminder = reminder
        super.init(frame: .zero, style: .plain)
        
        delegate = self
        dataSource = self
        backgroundColor = .systemTeal
        register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        configureStepper()
        configureFlagSwitch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let largeConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17), scale: .large)
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        cell.imageView?.tintColor = .label
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Priority"
            cell.detailTextLabel?.text = exclamation(index: Int(self.priority))
            cell.imageView?.image = UIImage(named: "exclamationmark.circle", in: nil, with: largeConfig)
            cell.accessoryView = stepper
            cell.selectionStyle = .none
        case 1:
            cell.textLabel?.text = "Reminder"
            if let reminder = self.reminder { cell.detailTextLabel?.text = CalUtility.getTimeAsString(time: reminder) } else { cell.detailTextLabel?.text = "None" }
            cell.imageView?.image = UIImage(named: "clock", in: nil, with: largeConfig)
            cell.accessoryType = .disclosureIndicator
        case 2:
            cell.textLabel?.text = "Flag"
            cell.imageView?.image = UIImage(named: "flag.circle", in: nil, with: largeConfig)
            cell.accessoryView = flagSwitch
            cell.selectionStyle = .none
        default: ()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var reminderView: ReminderViewController
        switch indexPath.row {
        case 1:
            if let reminder = self.reminder { reminderView = ReminderViewController(reminder: reminder) }
            else { reminderView = ReminderViewController(reminder: nil) }
            reminderView.updateDelegate = self
            if let parentView = tableView.findViewController() as? NewHabitViewController { reminderView.saveDelegate = parentView.self }
            tableDelegate?.pushViewController(view: reminderView)
        default: ()
        }
        deselectRow(at: indexPath, animated: true)
    }
            
    func configureStepper() {
        stepper.minimumValue = 0
        stepper.maximumValue = 3
        stepper.value = Double(self.priority)
        stepper.addTarget(self, action: #selector(stepperTapped), for: .valueChanged)
    }
    
    func configureFlagSwitch() {
        flagSwitch.isOn = self.flag
        flagSwitch.addTarget(self, action: #selector(flagSwitchTapped), for: .valueChanged)
    }
    
    @objc func stepperTapped(sender: UIStepper) {
        haptics.selectionChanged()
        cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text = exclamation(index: Int(sender.value))
        tableDelegate?.savePriority(priority: Int64(sender.value))
    }
    
    @objc func flagSwitchTapped(sender: UISwitch) {
        haptics.selectionChanged()
        tableDelegate?.saveFlag(flag: sender.isOn)
    }
    
    func exclamation(index: Int) -> String {
        switch index {
        case 1: return "!"
        case 2: return "!!"
        case 3: return "!!!"
        default: return "None"
        }
    }
}

protocol FormingTableViewDelegate {
    func pushViewController(view: UIViewController)
    func savePriority(priority: Int64)
    func saveFlag(flag: Bool)
}

extension FormingTableView: UpdateReminderDelegate {
    func updateReminder(reminder: Date?) {
        let cell = self.cellForRow(at: IndexPath(row: 1, section: 0))
        if let unwrappedReminder = reminder {
            self.reminder = unwrappedReminder
            cell?.detailTextLabel?.text = CalUtility.getTimeAsString(time: unwrappedReminder)
        }
        else {
            self.reminder = nil
            cell?.detailTextLabel?.text = "None"
        }
    }
}
