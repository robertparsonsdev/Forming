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
    var buttonState = false

    let titleLabel = UILabel()
    let checkboxStackView = UIStackView()
    let editButton = UIButton()
    
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
//        NotificationCenter.default.addObserver(self, selector: #selector(updateBoxes), name: .NSCalendarDayChanged, object: nil)
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
        self.buttonState = habit.buttonState
        
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
        button.isSelected = self.buttonState
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
    
    // MARK: - Selectors
    @objc func editButtonTapped() {
        if let habit = self.habit {
            delegate?.presentNewHabitViewController(with: habit)
        }
    }
    
    @objc func todayCheckboxTapped(sender: UIButton) {
        print(sender.tag, "tapped")
    }
    
    @objc func checkboxTapped(sender: UIButton) {
        DispatchQueue.main.async { sender.shake() }
    }
    
    @objc func checkBoxLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            print("long pressed")
        }
    }
}

// MARK: - Protocols
protocol HabitCellDelegate {
    func presentNewHabitViewController(with habit: Habit)
    func presentAlertController(with alert: UIAlertController)
}
