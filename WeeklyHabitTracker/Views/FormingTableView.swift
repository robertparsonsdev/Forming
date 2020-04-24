//
//  FormingTableView.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/21/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class FormingTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    let stepper = UIStepper()
    let haptics = UISelectionFeedbackGenerator()
    var secondDelegate: FormingTableViewDelegate?
    let persistenceManager: PersistenceService
    var habit: Habit? {
        didSet {
            print("didset")
            if let priority = habit?.priority {
                print(priority)
                let cell = cellForRow(at: IndexPath(row: 0, section: 1))
                cell?.detailTextLabel?.text = priorities[Int(priority)]
            }
        }
    }
    
    let priorities = [0: "None", 1: "1", 2: "2", 3: "3"]
    
    init(persistenceManager: PersistenceService) {
        self.persistenceManager = persistenceManager
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
            cell.detailTextLabel?.text = priorities[0]
            cell.imageView?.image = UIImage(named: "exclamationmark.circle", in: nil, with: largeConfig)
            cell.accessoryView = stepper
            cell.selectionStyle = .none
        case 1:
            cell.textLabel?.text = "Reminder"
            cell.detailTextLabel?.text = "9:00 AM"
            cell.imageView?.image = UIImage(named: "clock", in: nil, with: largeConfig)
            cell.accessoryType = .disclosureIndicator
        default:
            cell.textLabel?.text = "Repeat"
            cell.detailTextLabel?.text = "Every Week"
            cell.imageView?.image = UIImage(named: "arrow.clockwise.circle", in: nil, with: largeConfig)
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var reminderView: ReminderViewController, repeatView: RepeatViewController
        switch indexPath.row {
        case 1:
            reminderView = ReminderViewController()
            reminderView.delegate = self
            secondDelegate?.pushViewController(view: reminderView)
        case 2:
            repeatView = RepeatViewController()
            repeatView.delegate = self
            secondDelegate?.pushViewController(view: repeatView)
        default: ()
        }
        deselectRow(at: indexPath, animated: true)
    }
            
    func configureStepper() {
        stepper.minimumValue = 0
        stepper.maximumValue = 3
        stepper.addTarget(self, action: #selector(stepperTapped), for: .valueChanged)
    }
    
    @objc func stepperTapped(sender: UIStepper) {
        haptics.selectionChanged()
        cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text = priorities[Int(sender.value)]
    }
    
    @objc func reminderChanged(sender: UIDatePicker) {
        print("reminder changed")
    }
}

protocol FormingTableViewDelegate {
    func pushViewController(view: UIViewController)
}

extension FormingTableView: SaveReminderDelegate, SaveRepeatDelegate {
    func saveReminder(reminder: String?) {
        let cell = self.cellForRow(at: IndexPath(row: 1, section: 0))
        if let reminderStr = reminder { cell?.detailTextLabel?.text = reminderStr }
        else { cell?.detailTextLabel?.text = "None" }
        // also save to core data
    }
    
    func saveRepeat(repeatability: Int64) {
        let cell = self.cellForRow(at: IndexPath(row: 2, section: 0))
        cell?.detailTextLabel?.text = String(repeatability)
    }
}
