//
//  HIstoryCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 5/5/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class HistoryTitleCell: UICollectionViewCell {
    let titleLabel = UILabel()
    let percentLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 14
        clipsToBounds = true
        
        configureTitleLabel()
        configurePercentLabel()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTitleLabel() {
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byTruncatingTail
    }
    
    func configurePercentLabel() {
        percentLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        percentLabel.textAlignment = .left
        percentLabel.textColor = .white
        percentLabel.numberOfLines = 0
    }
    
    func configureConstraints() {
        addSubview(percentLabel)
        percentLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 45)
        addSubview(titleLabel)
        titleLabel.anchor(top: percentLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 5, paddingRight: 10, width: 0, height: 0)
    }
    
    func setTitleLabelText(_ title: String) {
        titleLabel.text = title
    }
    
    func setPercentLabelText(_ title: String) {
        percentLabel.text = title
    }
    
    func setBackgroundColor(_ color: UIColor) {
        backgroundColor = color
    }
}
