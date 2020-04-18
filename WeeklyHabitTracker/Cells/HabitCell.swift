//
//  HabitCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class HabitCell: UICollectionViewCell {
    var habitTitle: String? {
        didSet {
            if let title = habitTitle { titleLabel.text = "  \(title)" }
        }
    }
    var habitDays: [Bool]? {
        didSet {
            for view in boxStackView.arrangedSubviews { view.removeFromSuperview() }
            if let days = habitDays { configureBoxes(days: days) }
        }
    }
    var habitColor: Int? {
        didSet {
            if let value = habitColor { titleLabel.backgroundColor = FormingColors.getColor(fromValue: value) }
        }
    }
    
    let titleLabel = UILabel()
    let boxStackView = UIStackView()
    let editButton = UIButton()
    
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
        let thinConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .thin), scale: .large)
        for (index, day) in days.enumerated() {
            if day {
                let button = UIButton()
                button.setImage(UIImage(named: "square", in: nil, with: thinConfig), for: .normal)
                button.imageView?.tintColor = .label
                boxStackView.insertArrangedSubview(button, at: index)
            } else {
                boxStackView.insertArrangedSubview(UIView(), at: index)
            }
        }
        
        let blackConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .black), scale: .large)
        let index = CalendarManager.shared.getCurrentDay()
        if let button = boxStackView.arrangedSubviews[index] as? UIButton {
            button.setImage(UIImage(named: "square", in: nil, with: blackConfig), for: .normal)
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
            let thinConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .thin), scale: .large)
            let blackConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .black), scale: .large)
            
            if newDate == 0 {
                let button = self.boxStackView.arrangedSubviews[6] as? UIButton
                button?.setPreferredSymbolConfiguration(thinConfig, forImageIn: .normal)
            } else {
                let button = self.boxStackView.arrangedSubviews[newDate - 1] as? UIButton
                button?.setPreferredSymbolConfiguration(thinConfig, forImageIn: .normal)
            }
            
            // set the new current location
            let button = self.boxStackView.arrangedSubviews[newDate] as? UIButton
            button?.setPreferredSymbolConfiguration(blackConfig, forImageIn: .normal)
        }
    }
    
    @objc func editButtonTapped() {
        print("edit tapped")
    }
}
