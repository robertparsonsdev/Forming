//
//  GoalViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/22/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class GoalsViewController: UIViewController {
    private var goal: Int64
    private weak var delegate: HabitDetailTableViewDelegate?
    private let row: FirstSection
    private let section: SectionNumber
    
    private let goalLabel = FormingPickerLabel()
    private let goalToggle = UISwitch()
    private let goalPicker = UIPickerView()
    private let goalData = Array(1...10000)
    
    private let descriptionLabel = FormingSecondaryLabel(text: "Set a goal to be notified when you reach a certain number of completed days for this habit. \n\nProgress towards your goal can be checked in History.")

    init(goal: Int64, delegate: HabitDetailTableViewDelegate, row: FirstSection, section: SectionNumber) {
        self.goal = goal
        self.delegate = delegate
        self.row = row
        self.section = section
        super.init(nibName: nil, bundle: nil)
        
        if goal > 0 {
            goalLabel.text = "\(goal)"
            goalToggle.isOn = true
        } else {
            goalLabel.text = "Off"
            goalToggle.isOn = false
            setGoalPickerEnabled(false)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Goal"
        
        configureGoalToggle()
        configureGoalPicker()
        
        configureConstraints()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            self.delegate?.update(text: self.goal == 0 ? "Off" : "Complete \(self.goal)", data: self.goal, atSection: self.section.rawValue, andRow: self.row.rawValue)
        }
    }
    
    private func configureGoalToggle() {
        goalToggle.addTarget(self, action: #selector(goalToggleTapped), for: .valueChanged)
    }
    
    private func configureGoalPicker() {
        goalPicker.dataSource = self
        goalPicker.delegate = self
        if self.goal > 0 {
            goalPicker.selectRow(Int(self.goal) - 1, inComponent: 0, animated: false)
        } else {
            goalPicker.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    private func configureConstraints() {
        let top = view.safeAreaLayoutGuide.topAnchor, left = view.leftAnchor, right = view.rightAnchor
        let descriptionTopPadding = goalLabel.frame.height + goalPicker.frame.height + (4 * 20)
        
        view.addSubview(goalToggle)
        goalToggle.anchor(top: top, left: nil, bottom: nil, right: right, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        view.addSubview(goalLabel)
        goalLabel.anchor(top: top, left: left, bottom: nil, right: goalToggle.leftAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 40)
        view.addSubview(goalPicker)
        goalPicker.anchor(top: goalLabel.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: goalPicker.frame.height)
        view.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: top, left: left, bottom: nil, right: right, paddingTop: descriptionTopPadding, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    private func removeGoalConstraints() {
        goalLabel.removeFromSuperview()
        goalToggle.removeFromSuperview()
        goalPicker.removeFromSuperview()
    }
    
    private func setGoalPickerEnabled(_ isEnabled: Bool) {
        if isEnabled {
            self.goalPicker.isUserInteractionEnabled = true
            self.goalPicker.alpha = 1.0
        } else {
            self.goalPicker.isUserInteractionEnabled = false
            self.goalPicker.alpha = 0.5
        }
    }

    @objc func goalToggleTapped(sender: UISwitch) {
        if sender.isOn {
            setGoalPickerEnabled(true)
            let selectedGoal = goalPicker.selectedRow(inComponent: 0) + 1
            goalLabel.text = "\(selectedGoal)"
            self.goal = Int64(selectedGoal)
        } else {
            setGoalPickerEnabled(false)
            goalLabel.text = "Off"
            self.goal = 0
        }
    }
}

extension GoalsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.goalData.count
    }
}

extension GoalsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(self.goalData[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedGoal = row + 1
        goalLabel.text = "\(selectedGoal)"
        self.goal = Int64(selectedGoal)
    }
}
