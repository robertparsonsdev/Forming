//
//  GoalViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/22/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class GoalViewController: UIViewController {
    private var goal: Int64
    private var deadline: Date?
    private weak var delegate: HabitDetailTableViewDelegate?
    private let row: FirstSection
    private let section: SectionNumber
    
    private var segmentedControl: UISegmentedControl!
    private var segementItems = [String]()
    
    private let goalLabel = FormingPickerLabel()
    private let goalToggle = UISwitch()
    private let goalPicker = UIPickerView()
    private let goalData = Array(1...10000)
    
    private let deadlineLabel = FormingPickerLabel()
    private let deadlineToggle = UISwitch()
    private let deadlinePicker = UIDatePicker()
    
    private let descriptionLabel = FormingSecondaryLabel(text: "Set a goal to be notified when you reach a certain number of completed days for this habit. Or set a deadline to be notified on that date. \n\nProgress towards your goal or deadline can be checked in History.")

    init(goal: Int64, deadline: Date?, delegate: HabitDetailTableViewDelegate, row: FirstSection, section: SectionNumber) {
        self.goal = goal
        self.deadline = deadline
        self.delegate = delegate
        self.row = row
        self.section = section
        super.init(nibName: nil, bundle: nil)
        
        if goal > 0 {
            segementItems.append("Completion Goal: \(goal)")
            goalLabel.text = "\(goal)"
            goalToggle.isOn = true
        } else {
            segementItems.append("Completion Goal: Off")
            goalLabel.text = "Off"
            goalToggle.isOn = false
            setGoalPickerEnabled(false)
        }
        
        if let date = deadline {
            segementItems.append("Deadline: \(CalUtility.getDateAsString(date: date))")
            deadlineLabel.text = "\(CalUtility.getDateAsString(date: date))"
            deadlineToggle.isOn = true
            deadlinePicker.date = date
        } else {
            segementItems.append("Deadline: Off")
            deadlineLabel.text = "Off"
            deadlineToggle.isOn = false
            deadlinePicker.isEnabled = false
            deadlinePicker.date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Goals"
        
        configureSegmentedControl()
        
        configureGoalToggle()
        configureGoalPicker()
        configureDeadlineToggle()
        configureDeadlinePicker()
        
        configureConstraints()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        if parent == nil {
            if self.goal > 0 {
                self.delegate?.update(text: "\(self.goal)", data: self.goal, atSection: self.section.rawValue, andRow: self.row.rawValue)
            } else {
                self.delegate?.update(text: "Off", data: self.goal, atSection: self.section.rawValue, andRow: self.row.rawValue)
            }
        }
    }
    
    private func configureSegmentedControl() {
        segmentedControl = UISegmentedControl(items: self.segementItems)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    private func configureGoalToggle() {
        goalToggle.addTarget(self, action: #selector(goalToggleTapped), for: .valueChanged)
    }
    
    private func configureGoalPicker() {
        goalPicker.dataSource = self
        goalPicker.delegate = self
        goalPicker.selectRow(Int(self.goal) - 1, inComponent: 0, animated: false)
    }
    
    private func configureDeadlineToggle() {
        deadlineToggle.addTarget(self, action: #selector(deadlineToggleTapped), for: .valueChanged)
    }
    
    private func configureDeadlinePicker() {
        deadlinePicker.datePickerMode = .date
        deadlinePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        deadlinePicker.addTarget(self, action: #selector(deadlinePickerChanged), for: .valueChanged)
    }
    
    private func configureConstraints() {
        let top = view.safeAreaLayoutGuide.topAnchor, left = view.leftAnchor, right = view.rightAnchor
        view.addSubview(segmentedControl)
        segmentedControl.anchor(top: top, left: left, bottom: nil, right: right, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        
        let descriptionTopPadding = goalLabel.frame.height + goalPicker.frame.height + (4 * 20)
        view.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: segmentedControl.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: descriptionTopPadding, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        
        addGoalContraints()
    }
    
    private func addGoalContraints() {
        let left = view.leftAnchor, right = view.rightAnchor
        view.addSubview(goalToggle)
        goalToggle.anchor(top: segmentedControl.bottomAnchor, left: nil, bottom: nil, right: right, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        view.addSubview(goalLabel)
        goalLabel.anchor(top: segmentedControl.bottomAnchor, left: left, bottom: nil, right: goalToggle.leftAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 40)
        view.addSubview(goalPicker)
        goalPicker.anchor(top: goalLabel.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: goalPicker.frame.height)
    }
    
    private func addDeadlineConstraints() {
        let left = view.leftAnchor, right = view.rightAnchor
        view.addSubview(deadlineToggle)
        deadlineToggle.anchor(top: segmentedControl.bottomAnchor, left: nil, bottom: nil, right: right, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        view.addSubview(deadlineLabel)
        deadlineLabel.anchor(top: segmentedControl.bottomAnchor, left: left, bottom: nil, right: deadlineToggle.leftAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 40)
        view.addSubview(deadlinePicker)
        deadlinePicker.anchor(top: deadlineLabel.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: deadlinePicker.frame.height)
    }
    
    private func removeGoalConstraints() {
        goalLabel.removeFromSuperview()
        goalToggle.removeFromSuperview()
        goalPicker.removeFromSuperview()
    }
    
    private func removeDeadlineConstraints() {
        deadlineLabel.removeFromSuperview()
        deadlineToggle.removeFromSuperview()
        deadlinePicker.removeFromSuperview()
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
    
    @objc func segmentChanged(sender: UISegmentedControl) {
        DispatchQueue.main.async {
            UIView.transition(with: self.view, duration: 0.25, options: .transitionCrossDissolve, animations: {
                if sender.selectedSegmentIndex == 0 {
                    self.removeDeadlineConstraints()
                    self.addGoalContraints()
                } else {
                    self.removeGoalConstraints()
                    self.addDeadlineConstraints()
                }
            }, completion: nil)
        }
    }

    @objc func goalToggleTapped(sender: UISwitch) {
        if sender.isOn {
            setGoalPickerEnabled(true)
            let selectedGoal = goalPicker.selectedRow(inComponent: 0) + 1
            goalLabel.text = "\(selectedGoal)"
            segmentedControl.setTitle("Completion Goal: \(selectedGoal)", forSegmentAt: 0)
            self.goal = Int64(selectedGoal)
        } else {
            setGoalPickerEnabled(false)
            goalLabel.text = "Off"
            segmentedControl.setTitle("Completion Goal: Off", forSegmentAt: 0)
            self.goal = 0
        }
    }
    
    @objc func deadlineToggleTapped(sender: UISwitch) {
        if sender.isOn {
            deadlinePicker.isEnabled = true
            let dateString = CalUtility.getDateAsString(date: deadlinePicker.date)
            deadlineLabel.text = dateString
            segmentedControl.setTitle("Deadline: \(dateString)", forSegmentAt: 1)
            self.deadline = deadlinePicker.date
        } else {
            deadlinePicker.isEnabled = false
            deadlineLabel.text = "Off"
            segmentedControl.setTitle("Deadline: Off", forSegmentAt: 1)
            self.deadline = nil
        }
    }
    
    @objc func deadlinePickerChanged(sender: UIDatePicker) {
        if deadlinePicker.isEnabled {
            let dateString = CalUtility.getDateAsString(date: sender.date)
            deadlineLabel.text = dateString
            segmentedControl.setTitle("Deadline: \(dateString)", forSegmentAt: 1)
            self.deadline = sender.date
        } else {
            deadlineLabel.text = "Off"
            segmentedControl.setTitle("Deadline: Off", forSegmentAt: 1)
            self.deadline = nil
        }
    }
}

extension GoalViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.goalData.count
    }
}

extension GoalViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(self.goalData[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedGoal = row + 1
        goalLabel.text = "\(selectedGoal)"
        segmentedControl.setTitle("Completion Goal: \(selectedGoal)", forSegmentAt: 0)
        self.goal = Int64(selectedGoal)
    }
}
