//
//  HabitCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class HabitCell: UICollectionViewCell {
    var delegate: HabitCellDelegate?
    var habit: Habit? {
        didSet {
            if let title = habit?.title { titleLabel.text = "  \(title)" }
            if let color = habit?.color { titleLabel.backgroundColor = FormingColors.getColor(fromValue: Int(color)) }
            if let days = habit?.days {
                for view in boxStackView.arrangedSubviews { view.removeFromSuperview() }
                configureBoxes(days: days)
            }
        }
    }
    
    let titleLabel = UILabel()
    let boxStackView = UIStackView()
    let editButton = UIButton()
    let haptics = UISelectionFeedbackGenerator()
    
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
        for (index, day) in days.enumerated() {
            if day {
                let button = UIButton()
                button.setImage(UIImage(named: "square", in: nil, with: thinConfig), for: .normal)
                button.setImage(UIImage(named: "checkmark.square", in: nil, with: thinConfig), for: .selected)
                button.imageView?.tintColor = .label
                button.addTarget(self, action: #selector(boxTapped), for: .touchUpInside)
                boxStackView.insertArrangedSubview(button, at: index)
            } else {
                boxStackView.insertArrangedSubview(UIView(), at: index)
            }
        }
        
        let index = CalendarManager.shared.getCurrentDay()
        if let button = boxStackView.arrangedSubviews[index] as? UIButton {
            button.setImage(UIImage(named: "square", in: nil, with: blackConfig), for: .normal)
            button.setImage(UIImage(named: "checkmark.square.fill", in: nil, with: blackConfig), for: .selected)
            button.imageView?.tintColor = .label
        }
    }
    
    func configureEditButton() {
        let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 15, weight: .light), scale: .medium)
        let symbolAttachment = NSTextAttachment()
        symbolAttachment.image = UIImage(named: "chevron.right", in: nil, with: config)
        symbolAttachment.image = symbolAttachment.image?.withTintColor(.white)
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 15, weight: .light), .foregroundColor: UIColor.white]
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
            let newDate = CalendarManager.shared.getCurrentDay()
            
            if newDate == 0 {
                for view in self.boxStackView.arrangedSubviews {
                    if let button = view as? UIButton {
                        button.setImage(UIImage(named: "square", in: nil, with: self.thinConfig), for: .normal)
                        button.setImage(UIImage(named: "checkmark.square", in: nil, with: self.thinConfig), for: .selected)
                    }
                }
            } else {
                if let oldButton = self.boxStackView.arrangedSubviews[newDate - 1] as? UIButton {
                    oldButton.setImage(UIImage(named: "square", in: nil, with: self.thinConfig), for: .normal)
                    oldButton.setImage(UIImage(named: "checkmark.square", in: nil, with: self.thinConfig), for: .selected)
                }
            }
            
            let currentButton = self.boxStackView.arrangedSubviews[newDate] as? UIButton
            currentButton?.setImage(UIImage(named: "square", in: nil, with: self.blackConfig), for: .normal)
            currentButton?.setImage(UIImage(named: "checkmark.square.fill", in: nil, with: self.blackConfig), for: .selected)
        }
    }
    
    @objc func editButtonTapped() {
        if let habit = self.habit {
            delegate?.presentNewHabitViewController(with: habit)
        }
    }
    
    @objc func boxTapped(sender: UIButton) {
        haptics.selectionChanged()
        if sender.isSelected == true {
            sender.isSelected = false
            sender.imageView?.tintColor = .label
        } else {
            sender.isSelected = true
            sender.imageView?.tintColor = .systemGreen
        }
    }
}

protocol HabitCellDelegate {
    func presentNewHabitViewController(with habit: Habit)
}
