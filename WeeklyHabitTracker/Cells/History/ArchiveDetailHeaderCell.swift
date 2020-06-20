//
//  ArchiveDetailHeaderCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ArchiveDetailHeaderCell: UICollectionViewCell {
    let percentLabel = UILabel()
    let completedView = FormingStatView(title: "Completed", color: .systemGreen)
    let failedView = FormingStatView(title: "Failed", color: .systemRed)
    let incompleteView = FormingStatView(title: "Incomplete", color: .lightGray)
    let totalView = FormingStatView(title: "Total", color: .label)
    
    let topStackView = UIStackView()
    let bottomStackView = UIStackView()
    let secondaryStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        configurePercentLabel()
        configureSubStackViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(percentage: String) {
        percentLabel.text = percentage
    }
    
    func set(completed: Int64, failed: Int64, incomplete: Int64) {
        completedView.set(stat: completed)
        failedView.set(stat: failed)
        incompleteView.set(stat: incomplete)
        totalView.set(stat: completed + failed + incomplete)
    }
    
    func configurePercentLabel() {
        percentLabel.textAlignment = .center
        percentLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
    }
    
    func configureSubStackViews() {
        topStackView.axis = .horizontal
        topStackView.alignment = .fill
        topStackView.distribution = .fillEqually
        bottomStackView.axis = .horizontal
        bottomStackView.alignment = .fill
        bottomStackView.distribution = .fillEqually
        
        topStackView.addArrangedSubview(completedView)
        topStackView.addArrangedSubview(failedView)
        bottomStackView.addArrangedSubview(incompleteView)
        bottomStackView.addArrangedSubview(totalView)
        
        secondaryStackView.axis = .vertical
        secondaryStackView.alignment = .fill
        secondaryStackView.distribution = .fillEqually
        secondaryStackView.spacing = 5
        secondaryStackView.addArrangedSubview(topStackView)
        secondaryStackView.addArrangedSubview(bottomStackView)
    }
    
    func configureConstraints() {
        addSubview(percentLabel)
        percentLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 130, height: 0)
        addSubview(secondaryStackView)
        secondaryStackView.anchor(top: topAnchor, left: percentLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
    }
}
