//
//  ArchiveDetailHeaderCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ArchiveDetailHeaderCell: UICollectionViewCell {
    let stackView = UIStackView()
    let percentLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        configurePercentLabel()
        configureStackView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(percentage: String) {
        percentLabel.text = percentage
    }
    
    func configurePercentLabel() {
        percentLabel.textAlignment = .center
        percentLabel.font = UIFont.systemFont(ofSize: 30, weight: .black)
    }
    
    func configureStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        stackView.addArrangedSubview(percentLabel)
        let view = UIView()
        stackView.addArrangedSubview(view)
        let vieww = UIView()
        stackView.addArrangedSubview(vieww)
    }
    
    func configureConstraints() {
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
    }
}
