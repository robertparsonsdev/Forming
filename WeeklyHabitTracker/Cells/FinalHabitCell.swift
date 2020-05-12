//
//  FinalHabitCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 5/11/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class FinalHabitCell: UICollectionViewCell {
    private var delegate: HabitCellDelegate?
    private var currentDay = -1
    
    private let titleButton = UIButton()
    private let checkboxStackView = UIStackView()
    private let reminderLabel = UILabel()
    private let priorityLabel = UILabel()
    private var alertController: UIAlertController?
    private let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator()
    
    private let thinConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .thin), scale: .large)
    private let regularConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 15, weight: .regular), scale: .default)
    private let boldConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .bold), scale: .small)
    private let blackConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .black), scale: .large)
    private let priorityAttachment = NSTextAttachment()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureCell()
        configureTitleButton()
        configureReminderLabel()
        configurePriorityLabel()
        configureStackView()
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
    }
    
    func configureTitleButton() {
        titleButton.contentHorizontalAlignment = .left
        titleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        titleButton.titleLabel?.textColor = .white
//        titleButton.addTarget(self, action: #selector(titleTapped), for: .touchUpInside)
    }
    
    func configureReminderLabel() {
        reminderLabel.font = UIFont.systemFont(ofSize: 15)
        reminderLabel.textColor = .white
        reminderLabel.textAlignment = .right
        reminderLabel.isUserInteractionEnabled = false
    }
    
    func configurePriorityLabel() {
        priorityLabel.font = UIFont.systemFont(ofSize: 15)
        priorityLabel.textAlignment = .center
        priorityLabel.textColor = .white
        priorityLabel.isUserInteractionEnabled = false
        priorityAttachment.image = UIImage(named: "exclamationmark", in: nil, with: regularConfig)
        priorityAttachment.image = priorityAttachment.image?.withTintColor(.white)
    }
    
    func configureStackView() {
        checkboxStackView.axis = .horizontal
        checkboxStackView.alignment = .fill
        checkboxStackView.distribution = .fillEqually
    }
    
    func configureConstraints() {
        addSubview(titleButton)
        titleButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 25)
        addSubview(reminderLabel)
        reminderLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 70, height: 25)
        addSubview(priorityLabel)
        priorityLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: reminderLabel.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 20, height: 25)
        addSubview(checkboxStackView)
        checkboxStackView.anchor(top: titleButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    // MARK: Functions
    func set(delegate: HabitCellDelegate) {
        self.delegate = delegate
    }
    
    func set(habit: Habit) {
        // set UI elements
    }
    
    // MARK: Selectors
    
}

// MARK: - Protocols
protocol HabitCellDelegate {
    func presentNewHabitViewController(with habit: Habit)
    func presentAlertController(with alert: UIAlertController)
}
