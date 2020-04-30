//
//  NewHabitCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/29/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class NewHabitCell: UICollectionViewCell {
    var persistenceManager: PersistenceService?
    var delegate: HabitCellDelegate?
    var calendarManager = CalendarManager.shared
    var currentDay = -1
    var habit: Habit? {
        didSet { if let habit = self.habit { self.configureData(habit: habit) } }
    }
    var title = ""
    var color: Int64 = -1
    var days = [Bool]()
    var statuses = [Status]()

    let titleLabel = UILabel()
    let checkboxStackView = UIStackView()
    let editButton = UIButton()
    var alertController: UIAlertController?
    let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    let selectionGenerator = UISelectionFeedbackGenerator()
    let impactGenerator = UIImpactFeedbackGenerator()
    
    let thinConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .thin), scale: .large)
    let regularConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 15, weight: .regular), scale: .medium)
    let blackConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .black), scale: .large)
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureCell()
        configureTitleLabel()
        configureStackView()
        configureEditButton()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration Functions
    func configureCell() {
        layer.cornerRadius = 14
        backgroundColor = .tertiarySystemFill
        clipsToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(dayChanged), name: .NSCalendarDayChanged, object: nil)
    }
    
    func configureTitleLabel() {
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = .white
    }
    
    func configureStackView() {
        checkboxStackView.axis = .horizontal
        checkboxStackView.alignment = .fill
        checkboxStackView.distribution = .fillEqually
    }
    
    func configureEditButton() {
        let symbolAttachment = NSTextAttachment(image: UIImage(named: "chevron.right", in: nil, with: regularConfig)!)
        symbolAttachment.image = symbolAttachment.image?.withTintColor(.white)
        let title = NSMutableAttributedString(string: "Edit ", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.white])
        title.append(NSAttributedString(attachment: symbolAttachment))
        
        editButton.setAttributedTitle(title, for: .normal)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    
    func configureConstraints() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 25)
        addSubview(editButton)
        editButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 0, height: 25)
        addSubview(checkboxStackView)
        checkboxStackView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func configureData(habit: Habit) {
        self.currentDay = calendarManager.getCurrentDay()
        if let title = habit.title { self.title = title; titleLabel.text = "   \(title)" }
        titleLabel.backgroundColor = FormingColors.getColor(fromValue: habit.color)
        self.color = habit.color
        self.days = habit.days
        self.statuses = habit.statuses
        
        setupCheckboxes()
    }
    
    // MARK: - Functions
    func setupCheckboxes() {
        if !checkboxStackView.arrangedSubviews.isEmpty { for view in checkboxStackView.arrangedSubviews { view.removeFromSuperview() } }
        
        for (index, day) in days.enumerated() {
            if day && index == currentDay { checkboxStackView.addArrangedSubview(createTodayCheckbox(withTag: index)) }
            else if day { checkboxStackView.addArrangedSubview(createCheckbox(withTag: index)) }
            else { checkboxStackView.addArrangedSubview(UIView()) }
        }
    }
    
    func createTodayCheckbox(withTag tag: Int) -> UIButton {
        let button = UIButton()
        if let state = habit?.buttonState { button.isSelected = state }
        button.tag = tag
        button.addTarget(self, action: #selector(todayCheckboxTapped), for: .touchUpInside)
        button.addGestureRecognizer(createLongGesture())
        button.setImage(UIImage(named: "square", in: nil, with: self.blackConfig), for: .normal)
        switch statuses[tag] {
        case .incomplete: button.imageView?.tintColor = .label
        case .completed:
            button.setImage(UIImage(named: "checkmark.square.fill", in: nil, with: self.blackConfig), for: .selected)
            button.imageView?.tintColor = .systemGreen
        case .failed:
            button.setImage(UIImage(named: "xmark.square.fill", in: nil, with: self.blackConfig), for: .selected)
            button.imageView?.tintColor = .systemRed
        default: ()
        }
        return button
    }
    
    func createCheckbox(withTag tag: Int) -> UIButton {
        let button = UIButton()
        button.tag = tag
        button.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        button.addGestureRecognizer(createLongGesture())
        switch statuses[tag] {
        case .incomplete:
            button.setImage(UIImage(named: "square", in: nil, with: self.thinConfig), for: .normal)
            button.imageView?.tintColor = .label
        case .completed:
            button.setImage(UIImage(named: "checkmark.square", in: nil, with: self.thinConfig), for: .normal)
            button.imageView?.tintColor = .systemGreen
        case .failed:
            button.setImage(UIImage(named: "xmark.square", in: nil, with: thinConfig), for: .normal)
            button.imageView?.tintColor = .systemRed
        default: ()
        }
        return button
    }
    
    func changeStatus(forIndex index: Int, andStatus status: Status) {
        self.statuses[index] = status
        habit?.statuses = self.statuses
        persistenceManager?.save()
        habit?.statuses.forEach { print($0.rawValue) }
        print()
    }
    
    func createLongGesture() -> UILongPressGestureRecognizer {
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(checkBoxLongPressed))
        longGesture.minimumPressDuration = 0.5
        return longGesture
    }
    
    func createAlertActions(checkbox: UIButton) {
        alertController?.addAction(UIAlertAction(title: "Complete", style: .default, handler: { [weak self] (_) in
            guard let self = self else { return }
            if checkbox.tag == self.currentDay {
                checkbox.isSelected = true
                self.habit?.buttonState = checkbox.isSelected
            }
            self.changeStatus(forIndex: checkbox.tag, andStatus: .completed)
            self.replace(checkbox: checkbox, atIndex: checkbox.tag)
        }))
        alertController?.addAction(UIAlertAction(title: "Failed", style: .default, handler:{ [weak self] (_) in
            guard let self = self else { return }
            if checkbox.tag == self.currentDay {
                checkbox.isSelected = true
                self.habit?.buttonState = checkbox.isSelected
            }
            self.changeStatus(forIndex: checkbox.tag, andStatus: .failed)
            self.replace(checkbox: checkbox, atIndex: checkbox.tag)
        }))
        alertController?.addAction(UIAlertAction(title: "Incomplete", style: .default, handler: { [weak self] (_) in
            guard let self = self else { return }
            if checkbox.tag == self.currentDay {
                checkbox.isSelected = false
                self.habit?.buttonState = checkbox.isSelected
            }
            self.changeStatus(forIndex: checkbox.tag, andStatus: .incomplete)
            self.replace(checkbox: checkbox, atIndex: checkbox.tag)
        }))
        alertController?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    func replace(checkbox: UIButton, atIndex index: Int) {
        DispatchQueue.main.async {
            checkbox.removeFromSuperview()
            if index == self.currentDay {
                self.checkboxStackView.insertArrangedSubview(self.createTodayCheckbox(withTag: checkbox.tag), at: index)
            } else {
                self.checkboxStackView.insertArrangedSubview(self.createCheckbox(withTag: checkbox.tag), at: index)
            }
        }
    }
    
    // MARK: - Selectors
    @objc func editButtonTapped() {
        if let habit = self.habit {
            delegate?.presentNewHabitViewController(with: habit)
        }
    }
    
    @objc func todayCheckboxTapped(sender: UIButton) {
        selectionGenerator.selectionChanged()
        if sender.isSelected == true {
            sender.isSelected = false
            self.habit?.buttonState = sender.isSelected
            sender.imageView?.tintColor = .label
            changeStatus(forIndex: sender.tag, andStatus: .incomplete)
        } else {
            sender.isSelected = true
            self.habit?.buttonState = sender.isSelected
            if sender.image(for: .selected) == UIImage(named: "xmark.square.fill", in: nil, with: blackConfig) {
                sender.setImage(UIImage(named: "xmark.square.fill", in: nil, with: blackConfig), for: .selected)
                sender.imageView?.tintColor = .systemRed
                changeStatus(forIndex: sender.tag, andStatus: .failed)
            } else {
                sender.setImage(UIImage(named: "checkmark.square.fill", in: nil, with: blackConfig), for: .selected)
                sender.imageView?.tintColor = .systemGreen
                changeStatus(forIndex: sender.tag, andStatus: .completed)
            }
        }
    }
    
    @objc func checkboxTapped(sender: UIButton) {
        DispatchQueue.main.async { sender.shake() }
    }
    
    @objc func checkBoxLongPressed(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            impactGenerator.impactOccurred()
            guard let checkbox = gesture.view as? UIButton else { return }
            alertController = UIAlertController(title: "Change \(dayNames[checkbox.tag])'s status?", message: "Knowing the correct status of what you've done (e.g. completing or failing a habit) helps you to form better habits.", preferredStyle: .actionSheet)
            alertController?.view.tintColor = .systemGreen
            createAlertActions(checkbox: checkbox)
            delegate?.presentAlertController(with: alertController!)
        }
    }
    
    @objc func dayChanged() {
        DispatchQueue.main.async {
            let oldDay = self.currentDay
            self.currentDay = self.calendarManager.getCurrentDay()
            
            if oldDay != 6 && self.checkboxStackView.arrangedSubviews[oldDay] is UIButton {
                if self.statuses[oldDay] == .incomplete { self.changeStatus(forIndex: oldDay, andStatus: .failed) }
                self.replace(checkbox: self.checkboxStackView.arrangedSubviews[oldDay] as! UIButton, atIndex: oldDay)
                if self.statuses[self.currentDay] == .completed || self.statuses[self.currentDay] == .failed { self.habit?.buttonState = true }
                else { self.habit?.buttonState = false }
                self.replace(checkbox: self.checkboxStackView.arrangedSubviews[self.currentDay] as! UIButton, atIndex: self.currentDay)
            } else if oldDay == 6 {
                self.habit?.buttonState = false
                // print("update status to failed or completed for oldIndex and save week to history")
                for (index, view) in self.checkboxStackView.arrangedSubviews.enumerated() {
                    if view is UIButton {
                        self.changeStatus(forIndex: index, andStatus: .incomplete)
                        self.replace(checkbox: view as! UIButton, atIndex: index)
                    }
                }
            }
        }
    }
}

// MARK: - Protocols
protocol HabitCellDelegate {
    func presentNewHabitViewController(with habit: Habit)
    func presentAlertController(with alert: UIAlertController)
}
