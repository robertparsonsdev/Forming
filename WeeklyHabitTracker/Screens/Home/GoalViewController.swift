//
//  GoalViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/22/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class GoalViewController: UIViewController {
    private var updateDelegate: UpdateGoalDelegate?
    private var saveDelegate: SaveGoalDelegate?
    private var goal: Int64?
    
    private let goalTextField = FormingTextField(placeholder: "Enter a Goal", keyboardType: .decimalPad, returnKeyType: .done)
    private let toggle = UISwitch()
    private let explanationLabel = FormingSecondaryLabel(text: "Set a goal to be notified when you reach a certain number of completed days for this habit. By default, habit goals are never-ending. \n\nProgress towards your goal can be checked in History.")

    init(goal: Int64?) {
        super.init(nibName: nil, bundle: nil)
        self.goal = goal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Goal"
        
        configureTextField()
        configureToggle()
        configureConstraints()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            updateDelegate?.update(goal: self.goal)
            saveDelegate?.save(goal: self.goal)
        }
    }
    
    func setUpdateDelegate(delegate: UpdateGoalDelegate) {
        self.updateDelegate = delegate
    }
    
    func setSaveDelegate(delegate: SaveGoalDelegate) {
        self.saveDelegate = delegate
    }
    
    func configureTextField() {
        if let goal = self.goal {
            self.goalTextField.text = "\(goal)"
        } else {
            self.goalTextField.isEnabled = false
            self.goalTextField.placeholder = "Never-ending"
        }
    }
    
    func configureToggle() {
        if self.goal != nil {
            toggle.isOn = true
        } else {
            toggle.isOn = false
        }
        
        toggle.addTarget(self, action: #selector(toggleTapped), for: .valueChanged)
    }
    
    func configureConstraints() {
        let top = view.safeAreaLayoutGuide.topAnchor, left = view.leftAnchor, right = view.rightAnchor
        view.addSubview(goalTextField)
        goalTextField.anchor(top: top, left: left, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: view.frame.width - toggle.frame.width - 60, height: 40)
        view.addSubview(toggle)
        toggle.anchor(top: top, left: goalTextField.rightAnchor, bottom: nil, right: right, paddingTop: 25, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        view.addSubview(explanationLabel)
        explanationLabel.anchor(top: goalTextField.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }

    @objc func toggleTapped(sender: UISwitch) {
        if sender.isOn {
            goalTextField.isEnabled = true
            goalTextField.becomeFirstResponder()
            goalTextField.placeholder = "Enter a Goal"
            self.goal = 1
        } else {
            goalTextField.isEnabled = false
            goalTextField.resignFirstResponder()
            goalTextField.text = ""
            goalTextField.placeholder = "Never-ending"
            self.goal = nil
        }
    }
}

protocol UpdateGoalDelegate {
    func update(goal: Int64?)
}

protocol SaveGoalDelegate {
    func save(goal: Int64?)
}
