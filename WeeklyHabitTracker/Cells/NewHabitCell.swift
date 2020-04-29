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
    var calendarManager = CalendarManager.shared
    var habit: Habit? {
        didSet { if let habit = self.habit { self.configureData(habit: habit) } }
    }
    var title = ""
    var color: Int64 = -1
    var days = [Bool]()
    var statuses = [Status]()

    let titleLabel = UILabel()
    let boxStackView = UIStackView()
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
        boxStackView.axis = .horizontal
        boxStackView.alignment = .fill
        boxStackView.distribution = .fillEqually
    }
    
    func configureEditButton() {
        let symbolAttachment = NSTextAttachment(image: UIImage(named: "chevron.right", in: nil, with: regularConfig)!)
        symbolAttachment.image = symbolAttachment.image?.withTintColor(.white)
        let title = NSMutableAttributedString(string: "Edit ", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.white])
        title.append(NSAttributedString(attachment: symbolAttachment))
        
        editButton.setAttributedTitle(title, for: .normal)
//        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    
    func configureConstraints() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 25)
        addSubview(editButton)
        editButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 0, height: 25)
        addSubview(boxStackView)
        boxStackView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func configureData(habit: Habit) {
        if let title = habit.title { self.title = title; titleLabel.text = "   \(title)" }
        titleLabel.backgroundColor = FormingColors.getColor(fromValue: habit.color)
        self.color = habit.color
        self.days = habit.days
        self.statuses = habit.statuses
    }
    
    // MARK: - Functions
    
    
    // MARK: - Selectors
    
}

// MARK: - Protocols
protocol HabitCellDelegate {
    func presentNewHabitViewController(with habit: Habit)
    func presentAlertController(with alert: UIAlertController)
}
