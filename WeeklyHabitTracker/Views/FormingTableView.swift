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
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        cell.imageView?.tintColor = .label
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Priority"
            cell.detailTextLabel?.text = "0"
            cell.imageView?.image = UIImage(named: "exclamationmark.circle")
            cell.accessoryView = stepper
            cell.selectionStyle = .none
        case 1:
            cell.textLabel?.text = "Reminder"
            cell.detailTextLabel?.text = "9:00 AM"
            cell.imageView?.image = UIImage(named: "clock")
            cell.accessoryType = .disclosureIndicator
        default:
            cell.textLabel?.text = "Repeat"
            cell.detailTextLabel?.text = "Every Week"
            cell.imageView?.image = UIImage(named: "arrow.clockwise.circle")
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1: ()
            
        case 2: ()
            
        default: ()
        }
    }
            
    func configureStepper() {
        stepper.minimumValue = 0
        stepper.maximumValue = 3
        stepper.addTarget(self, action: #selector(stepperTapped), for: .valueChanged)
    }
    
    @objc func stepperTapped(sender: UIStepper) {
        haptics.selectionChanged()
        cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text = String(Int(sender.value))
    }
    
    @objc func reminderChanged(sender: UIDatePicker) {
        print("reminder changed")
    }
}
