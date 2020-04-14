//
//  HomeHeaderCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class HomeHeaderCell: UICollectionViewCell {
    let dayNames = ["M", "T", "W", "Th", "F", "Sa", "Su"]
    let dayNamesStackView = UIStackView()
    let dayNums = ["1", "2", "3", "4", "5", "6", "7"]
    let dayNumsStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        configureStackView(dayNamesStackView, withArray: dayNames)
        configureStackView(dayNumsStackView, withArray: dayNums)
        configureConstraints()
    }
    
    func configureStackView(_ stackView : UIStackView, withArray array: [String]) {
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        for item in array {
            let label = UILabel()
            label.text = item
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 20, weight: .thin)
            stackView.addArrangedSubview(label)
        }
        
        let label = stackView.arrangedSubviews[2] as? UILabel
        label?.font = UIFont.systemFont(ofSize: 20, weight: .black)
    }
    
    func configureConstraints() {
        addSubview(dayNamesStackView)
        dayNamesStackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: frame.height / 2, paddingRight: 15, width: 0, height: 0)
        
        addSubview(dayNumsStackView)
        dayNumsStackView.anchor(top: dayNamesStackView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 20, paddingRight: 15, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
