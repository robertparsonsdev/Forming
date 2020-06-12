//
//  HIstoryCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 5/5/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ArchiveTitleCell: UICollectionViewCell {
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 14
        clipsToBounds = true
        
        configureTitleLabel()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTitleLabel() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
    }
    
    func configureConstraints() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0)
    }
    
    func setTitleLabelText(_ title: String) {
        titleLabel.text = title
    }
    
    func setBackgroundColor(_ color: UIColor) {
        backgroundColor = color
    }
}
