//
//  HIstoryCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 5/5/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class HistoryTitleCell: UICollectionViewCell {
    private let percentLabel = UILabel()
    private let detailLabel = FormingSecondaryLabel()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 14
        clipsToBounds = true
        
        configure(percentLabel: percentLabel)
        configureTitleLabel()
        configureSecondaryLabels()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTitleLabel() {
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byTruncatingTail
    }
    
    private func configure(percentLabel: UILabel) {
        percentLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        percentLabel.textAlignment = .left
        percentLabel.textColor = .white
        percentLabel.numberOfLines = 0
    }
    
    private func configureSecondaryLabels() {
    }
    
    private func configureConstraints() {
        addSubview(percentLabel)
        percentLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 5, width: 0, height: 45)
        detailLabel.textAlignment = .left
        addSubview(detailLabel)
        detailLabel.anchor(top: percentLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: -8, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 50)
    }
    
    func set(percent: String) {
        percentLabel.text = percent
    }
    
    func set(detail: String) {
        detailLabel.text = detail
    }
    
    func set(title: String) {
        titleLabel.text = title
    }
    
    func set(color: UIColor) {
        backgroundColor = color
    }
}
