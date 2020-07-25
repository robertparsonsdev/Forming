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
    private let delegate: HabitDetailTableViewDelegate
    private let row: FirstSection
    private let section: SectionNumber
    
    private let goalTextField = FormingTextField(placeholder: "Enter a goal", keyboardType: .numberPad, returnKeyType: .done)
    private let toggle = UISwitch()
    private let explanationLabel = FormingSecondaryLabel(text: "Set a goal to be notified when you reach a certain number of completed days for this habit. Progress towards your goal can be checked in History.\n\nBy default, goals are never-ending. But a habit can be finished at any time by tapping the checkmark on that habit's Habit Detail screen.")
    private var toolBar: UIToolbar!

    init(goal: Int64, delegate: HabitDetailTableViewDelegate, row: FirstSection, section: SectionNumber) {
        self.goal = goal
        self.delegate = delegate
        self.row = row
        self.section = section
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Goal"
        
        configureToolbar()
        configureTextField()
        configureToggle()
        configureConstraints()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        if parent == nil {
            if self.goal > 0 {
                self.delegate.update(text: "\(self.goal)", data: self.goal, atSection: self.section.rawValue, andRow: self.row.rawValue)
            } else {
                self.delegate.update(text: "Never-ending", data: self.goal, atSection: self.section.rawValue, andRow: self.row.rawValue)
            }
        }
    }
    
    func configureTextField() {
        goalTextField.inputAccessoryView = self.toolBar
        if self.goal > 0 {
            self.goalTextField.text = "\(self.goal)"
        } else {
            self.goalTextField.isEnabled = false
            self.goalTextField.text = "Never-ending"
        }
    }
    
    func configureToggle() {
        if self.goal > 0 {
            toggle.isOn = true
        } else {
            toggle.isOn = false
        }
        
        toggle.addTarget(self, action: #selector(toggleTapped), for: .valueChanged)
    }
    
    func configureToolbar() {
        toolBar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: 30)))
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        saveButton.tintColor = .systemGreen
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), saveButton], animated: false)
        toolBar.sizeToFit()
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
    
    func presentIncompleteAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = .systemGreen
        alert.addAction(UIAlertAction(title: "Okay", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }

    @objc func toggleTapped(sender: UISwitch) {
        if sender.isOn {
            if goalTextField.text == "Never-ending" {
                goalTextField.text = ""
            }
            goalTextField.isEnabled = true
            goalTextField.becomeFirstResponder()
        } else {
            goalTextField.isEnabled = false
            goalTextField.resignFirstResponder()
            goalTextField.text = "Never-ending"
            self.goal = 0
        }
    }
    
    @objc func saveButtonTapped() {
        if let text = self.goalTextField.text {
            if let goal = Int64(text) {
                guard goal > 0 else {
                    presentIncompleteAlert(withTitle: "Cannot Be 0", andMessage: "A goal must be greater than 0.")
                    return
                }
                self.goal = goal
                self.view.endEditing(true)
            } else {
                presentIncompleteAlert(withTitle: "Not a Number", andMessage: "Please ensure that you have entered a valid integer in the text field.")
            }
        } else {
            presentIncompleteAlert(withTitle: "Empty Text Field", andMessage: "Please ensure that you have entered a valid integer in the text field.")
        }
    }
}
