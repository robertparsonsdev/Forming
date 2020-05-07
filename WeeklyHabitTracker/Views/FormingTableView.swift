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
    var reminder: Date?
    var repeatability: Int64
    var tableDelegate: FormingTableViewDelegate?
    
    let priorities = [0: "None", 1: "1", 2: "2", 3: "3"]
    let repeatData = [0: "Just This Week", 1: "Every Week", 2: "Every Two Weeks", 3: "Every Three Weeks", 4: "Every Four Weeks"]
    
    let stepper = UIStepper()
    let haptics = UISelectionFeedbackGenerator()
    
    init(priority: Int64, reminder: Date?, repeatability: Int64) {
        self.priority = priority
        self.reminder = reminder
        self.repeatability = repeatability
        super.init(frame: .zero, style: .plain)
        
        delegate = self
        dataSource = self
        backgroundColor = .systemTeal
        register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        configureStepper()
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
            cell.detailTextLabel?.text = priorities[Int(self.priority)]
            cell.imageView?.image = UIImage(named: "exclamationmark.circle", in: nil, with: largeConfig)
            cell.accessoryView = stepper
            cell.selectionStyle = .none
        case 1:
            cell.textLabel?.text = "Reminder"
            if let reminder = self.reminder { cell.detailTextLabel?.text = CalUtility.getTimeAsString(time: reminder) } else { cell.detailTextLabel?.text = "None" }
            cell.imageView?.image = UIImage(named: "clock", in: nil, with: largeConfig)
            cell.accessoryType = .disclosureIndicator
        default:
            cell.textLabel?.text = "Repeat"
            cell.detailTextLabel?.text = repeatData[Int(self.repeatability)]
            cell.imageView?.image = UIImage(named: "arrow.clockwise.circle", in: nil, with: largeConfig)
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var reminderView: ReminderViewController, repeatView: RepeatViewController
        switch indexPath.row {
        case 1:
            if let reminder = self.reminder { reminderView = ReminderViewController(reminder: reminder) }
            else { reminderView = ReminderViewController(reminder: nil) }
            reminderView.updateDelegate = self
            if let parentView = tableView.findViewController() as? NewHabitViewController { reminderView.saveDelegate = parentView.self }
            tableDelegate?.pushViewController(view: reminderView)
        case 2:
            repeatView = RepeatViewController(repeatability: self.repeatability, data: repeatData)
            repeatView.updateDelegate = self
            if let parentView = tableView.findViewController() as? NewHabitViewController { repeatView.saveDelegate = parentView.self }
            tableDelegate?.pushViewController(view: repeatView)
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
    
    @objc func stepperTapped(sender: UIStepper) {
        haptics.selectionChanged()
        cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text = priorities[Int(sender.value)]
        tableDelegate?.savePriority(priority: Int64(sender.value))
    }
}

protocol FormingTableViewDelegate {
    func pushViewController(view: UIViewController)
    func savePriority(priority: Int64)
}

extension FormingTableView: UpdateReminderDelegate, UpdateRepeatDelegate {
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
    
    func updateRepeat(repeatability: Int64) {
        let cell = self.cellForRow(at: IndexPath(row: 2, section: 0))
        cell?.detailTextLabel?.text = repeatData[Int(repeatability)]
        self.repeatability = repeatability
    }
}
