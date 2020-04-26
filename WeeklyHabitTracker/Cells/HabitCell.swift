//
//  HabitCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class HabitCell: UICollectionViewCell {
    let titleLabel = UILabel()
    let boxStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 14
        backgroundColor = .tertiarySystemFill
        clipsToBounds = true
        
        configureTitleLabel()
        configureStackView()
        configureConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBoxes), name: .NSCalendarDayChanged, object: nil)
    }
    
    func configureTitleLabel() {
        titleLabel.text = "  Habit Title"
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = .white
        titleLabel.backgroundColor = .systemPurple
    }
    
    func configureStackView() {
        boxStackView.axis = .horizontal
        boxStackView.alignment = .fill
        boxStackView.distribution = .fillEqually
        
        for _ in 0...6 {
            let button = UIButton()
            let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .thin), scale: .large)
            button.setImage(UIImage(named: "square", in: nil, with: config)!, for: .normal)
            if traitCollection.userInterfaceStyle == .light { button.imageView?.tintColor = .black }
            else { button.imageView?.tintColor = .white }
            boxStackView.addArrangedSubview(button)
        }
        
        let button = boxStackView.arrangedSubviews[CalendarManager.shared.currentWeekDay()] as? UIButton
        let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .black), scale: .large)
        button?.setImage(UIImage(named: "square", in: nil, with: config), for: .normal)
        if traitCollection.userInterfaceStyle == .light { button?.imageView?.tintColor = .black }
        else { button?.imageView?.tintColor = .white }
    }
    
    func configureConstraints() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: frame.height * 3/4, paddingRight: 0, width: 0, height: 0)
        addSubview(boxStackView)
        boxStackView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func updateBoxes() {
        DispatchQueue.main.async {
            let newDate = CalendarManager.shared.currentWeekDay()
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        var tint = UIColor()
        if traitCollection.userInterfaceStyle == .light { tint = .black }
        else { tint = .white }
        
        for view in boxStackView.arrangedSubviews {
            let button = view as? UIButton
            button?.imageView?.tintColor = tint
        }
    }
}
