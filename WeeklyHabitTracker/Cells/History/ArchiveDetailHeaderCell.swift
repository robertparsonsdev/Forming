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
    let percentSublabel = UILabel()
    let progressView = FormingProgressView()
    let completedView = FormingStatView(title: "Completed", color: .systemGreen)
    let failedView = FormingStatView(title: "Failed", color: .systemRed)
    let incompleteView = FormingStatView(title: "Incomplete", color: .lightGray)
    let totalView = FormingStatView(title: "Total", color: .label)
    
    let statsStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
//        setGradientBackground()
        
        configurePercentLabel()
        configurePercentSublabel()
        configureSubStackViews()
        configureProgressView()
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
    
    func configurePercentSublabel() {
        percentSublabel.text = "Completion Rate"
        percentSublabel.textAlignment = .center
        percentSublabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        percentSublabel.textColor = .secondaryLabel
    }
    
    func configureProgressView() {
//        let progressViewBounds = CGRect(x: 0.0, y: 0.0, width: frame.width - 130 - 25, height: frame.height - 65 - 15 - 10)
//        progressView.set(bounds: progressViewBounds)
//        progressView.setBluredBackground()
    }
    
    func configureSubStackViews() {
        statsStackView.axis = .horizontal
        statsStackView.alignment = .fill
        statsStackView.distribution = .fillEqually
        statsStackView.addArrangedSubview(completedView)
        statsStackView.addArrangedSubview(failedView)
        statsStackView.addArrangedSubview(incompleteView)
        statsStackView.addArrangedSubview(totalView)
    }
    
    func configureConstraints() {
        addSubview(statsStackView)
        statsStackView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 65)
        addSubview(percentLabel)
        percentLabel.anchor(top: statsStackView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 130, height: 40)
        addSubview(percentSublabel)
        percentSublabel.anchor(top: percentLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 130, height: 0)
        addSubview(progressView)
        progressView.anchor(top: statsStackView.bottomAnchor, left: percentLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 15, paddingRight: 15, width: 0, height: 0)
    }
}
