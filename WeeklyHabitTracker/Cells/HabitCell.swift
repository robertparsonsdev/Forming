//
//  HabitCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit
import CoreHaptics

class HabitCell: UICollectionViewCell {
    var persistenceManager: PersistenceService?
    var delegate: HabitCellDelegate?
    var habit: Habit? {
        didSet {
            if let title = habit?.title { titleLabel.text = "  \(title)" }
            if let color = habit?.color { titleLabel.backgroundColor = FormingColors.getColor(fromValue: color) }
            if let days = habit?.days { configureBoxes(days: days) }
        }
    }
    let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    let titleLabel = UILabel()
    let boxStackView = UIStackView()
    let editButton = UIButton()
    
    var longGesture: UILongPressGestureRecognizer?
    let selectionGenerator = UISelectionFeedbackGenerator()
    let impactGenerator = UIImpactFeedbackGenerator()
    var engine: CHHapticEngine?
    
    let thinConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .thin), scale: .large)
    let blackConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .black), scale: .large)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 14
        backgroundColor = .tertiarySystemFill
        clipsToBounds = true

        configureTitleLabel()
        configureStackView()
        configureEditButton()
        configureConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBoxes), name: .NSCalendarDayChanged, object: nil)
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
    
    func configureBoxes(days: [Bool]) {
        for view in self.boxStackView.arrangedSubviews { view.removeFromSuperview() }
        guard let statuses = habit?.statuses else { return }
        let currentDay = CalUtility.getCurrentDay()
        
        for (index, day) in days.enumerated() {
            let button = UIButton()
            button.tag = index
            longGesture = UILongPressGestureRecognizer(target: self, action: #selector(boxLongPressed))
            longGesture?.minimumPressDuration = 0.5
            button.addGestureRecognizer(longGesture!)
            
            if day && index == currentDay {
                button.addTarget(self, action: #selector(todayBoxTapped), for: .touchUpInside)
                button.setImage(UIImage(named: "square", in: nil, with: blackConfig), for: .normal)
                if let state = habit?.buttonState { button.isSelected = state }
                switch statuses[currentDay] {
                case .completed:
                    button.setImage(UIImage(named: "checkmark.square.fill", in: nil, with: blackConfig), for: .selected)
                    button.imageView?.tintColor = .systemGreen
                case .failed:
                    button.setImage(UIImage(named: "xmark.square.fill", in: nil, with: blackConfig), for: .selected)
                    button.imageView?.tintColor = .systemRed
                case .incomplete: button.imageView?.tintColor = .label
                default: ()
                }
                boxStackView.insertArrangedSubview(button, at: index)
            } else if day {
                button.addTarget(self, action: #selector(otherBoxTapped), for: .touchUpInside)
                switch statuses[index] {
                case .incomplete:
                    button.setImage(UIImage(named: "square", in: nil, with: thinConfig), for: .normal)
                    button.imageView?.tintColor = .label
                case .completed:
                    button.setImage(UIImage(named: "checkmark.square", in: nil, with: thinConfig), for: .normal)
                    button.imageView?.tintColor = .systemGreen
                case .failed:
                    button.setImage(UIImage(named: "xmark.square", in: nil, with: thinConfig), for: .normal)
                    button.imageView?.tintColor = .systemRed
                default: ()
                }
                boxStackView.insertArrangedSubview(button, at: index)
            } else {
                boxStackView.insertArrangedSubview(UIView(), at: index)
            }
        }
    }
    
    func configureEditButton() {
        let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 15, weight: .regular), scale: .medium)
        let symbolAttachment = NSTextAttachment()
        symbolAttachment.image = UIImage(named: "chevron.right", in: nil, with: config)
        symbolAttachment.image = symbolAttachment.image?.withTintColor(.white)
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.white]
        let title = NSMutableAttributedString(string: "Edit ", attributes: attributes)
        title.append(NSAttributedString(attachment: symbolAttachment))
        
        editButton.setAttributedTitle(title, for: .normal)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    
    func configureConstraints() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 25)
        addSubview(editButton)
        editButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 0, height: 25)
        addSubview(boxStackView)
        boxStackView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func updateBoxes() {
        DispatchQueue.main.async {
            let newDate = CalUtility.getCurrentDay()
            let oldIndex: Int
            guard let days = self.habit?.days else { return }
            guard let statuses = self.habit?.statuses else { return }
            
            switch newDate {
            case 0: oldIndex = 6
            default: oldIndex = newDate - 1
            }
            
            if oldIndex != 6 && self.boxStackView.arrangedSubviews[oldIndex] is UIButton {
                if statuses[oldIndex] == .incomplete { self.changeStatus(forIndex: oldIndex, andStatus: .failed) }
                if statuses[newDate] == .completed || statuses[newDate] == .failed { self.habit?.buttonState = true }
                else { self.habit?.buttonState = false }
            } else if oldIndex == 6 {
                self.habit?.buttonState = false
                // print("update status to failed or completed for oldIndex and save week to history")
                for (index, view) in self.boxStackView.arrangedSubviews.enumerated() {
                    if view is UIButton {
                        self.changeStatus(forIndex: index, andStatus: .incomplete)
                    }
                }
            }
            
            self.configureBoxes(days: days)
        }
    }
    
    @objc func editButtonTapped() {
        if let habit = self.habit {
            delegate?.presentNewHabitViewController(with: habit)
        }
    }
    
    @objc func todayBoxTapped(sender: UIButton) {
        let tag = sender.tag
        guard let statuses = habit?.statuses else { return }
        selectionGenerator.selectionChanged()
        
        if sender.isSelected == true {
            sender.isSelected = false
            self.habit?.buttonState = sender.isSelected
            sender.imageView?.tintColor = .label
            switch statuses[tag] {
            case .completed: changeStatus(forIndex: tag, andStatus: .incomplete)
            case .failed: changeStatus(forIndex: tag, andStatus: .incomplete)
            default: ()
            }
        } else {
            sender.isSelected = true
            self.habit?.buttonState = sender.isSelected
            if sender.image(for: .selected) == UIImage(named: "xmark.square.fill", in: nil, with: blackConfig) {
                sender.setImage(UIImage(named: "xmark.square.fill", in: nil, with: blackConfig), for: .selected)
                sender.imageView?.tintColor = .systemRed
                changeStatus(forIndex: tag, andStatus: .failed)
            } else {
                sender.setImage(UIImage(named: "checkmark.square.fill", in: nil, with: blackConfig), for: .selected)
                sender.imageView?.tintColor = .systemGreen
                changeStatus(forIndex: tag, andStatus: .completed)
            }
        }
    }
    
    @objc func otherBoxTapped(sender: UIButton) {
        DispatchQueue.main.async {
            sender.shake()
        }
    }
    
    @objc func boxLongPressed(gesture: UILongPressGestureRecognizer) {
        guard let button = gesture.view as? UIButton else { return }
        let currentDay = CalUtility.getCurrentDay()
        let index = button.tag
        guard let days = self.habit?.days else { return }
        
        if gesture.state == .began {
            impactGenerator.impactOccurred()
            let alertController = UIAlertController(title: "Change \(dayNames[index])'s status?", message: "Knowing the correct status of what you've done (e.g. completing or failing a habit) helps you to form better habits.", preferredStyle: .actionSheet)
            alertController.view.tintColor = .systemGreen
            alertController.addAction(UIAlertAction(title: "Incomplete", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.changeStatus(forIndex: index, andStatus: .incomplete)
                DispatchQueue.main.async { self.configureBoxes(days: days) }
                if button.tag == currentDay {
                    button.isSelected = false
                    self.habit?.buttonState = button.isSelected
                }
            })
            alertController.addAction(UIAlertAction(title: "Complete", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.changeStatus(forIndex: index, andStatus: .completed)
                DispatchQueue.main.async { self.configureBoxes(days: days) }
                if button.tag == currentDay {
                    button.isSelected = true
                    self.habit?.buttonState = button.isSelected
                }
            })
            alertController.addAction(UIAlertAction(title: "Failed", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.changeStatus(forIndex: index, andStatus: .failed)
                DispatchQueue.main.async { self.configureBoxes(days: days) }
                if button.tag == currentDay {
                    button.isSelected = true
                    self.habit?.buttonState = button.isSelected
                }
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            delegate?.presentAlertController(with: alertController)
        }
    }
    
    func changeStatus(forIndex index: Int, andStatus status: Status) {
        if var statuses = habit?.statuses {
            statuses[index] = status
            habit?.statuses = statuses
        }
        persistenceManager?.save()
        habit?.statuses.forEach { print($0.rawValue) }
        print()
    }
}

//protocol HabitCellDelegate {
//    func presentNewHabitViewController(with habit: Habit)
//    func presentAlertController(with alert: UIAlertController)
//}
