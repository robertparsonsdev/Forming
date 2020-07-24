//
//  ArchiveDetailHeaderCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ArchiveDetailHeaderCell: UICollectionViewCell {
//    private let percentLabel = UILabel()
//    private let percentSublabel = UILabel()
//    private var leftProgressView: FormingProgressView!
//    private var rightProgressView: FormingProgressView!
    private let completedView = FormingStatView(title: "Completed", color: .systemGreen)
    private let failedView = FormingStatView(title: "Failed", color: .systemRed)
    private let incompleteView = FormingStatView(title: "Incomplete", color: .lightGray)
    private let totalView = FormingStatView(title: "Total", color: .label)
    private let placeholder = FormingSecondaryLabel(text: "Almost Done 😌")
//    private var progressY: CGFloat!
//    private var progressX: CGFloat!
    
//    private let progressStackView = UIStackView()
    private let statsStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
//        self.progressY = (self.frame.height - 10 - 65 - 15) / 2
//        self.progressX = self.frame.width - 30
//        configurePercentLabel()
//        configurePercentSublabel()
//        configureLeftProgressView()
//        configureRightProgressView()
//        configureProgressStackView()
        configureStatsStackViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(percentage: String) {
//        percentLabel.text = percentage
    }
    
    func set(completed: Int64, failed: Int64, incomplete: Int64) {
        completedView.set(stat: completed)
        failedView.set(stat: failed)
        incompleteView.set(stat: incomplete)
        totalView.set(stat: completed + failed + incomplete)
    }
    
//    func configureLeftProgressView() {
//        leftProgressView = FormingProgressView(center: CGPoint(x: self.progressX / 4, y: self.progressY))
//    }
    
//    func configureRightProgressView() {
//        rightProgressView = FormingProgressView(center: CGPoint(x: self.progressX / 4, y: self.progressY))
//    }
    
//    func configurePercentLabel() {
//        percentLabel.textAlignment = .center
//        percentLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
//    }
//
//    func configurePercentSublabel() {
//        percentSublabel.text = "Completion Rate"
//        percentSublabel.textAlignment = .center
//        percentSublabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
//        percentSublabel.textColor = .secondaryLabel
//    }
    
//    func configureProgressStackView() {
//        progressStackView.axis = .horizontal
//        progressStackView.alignment = .fill
//        progressStackView.distribution = .fillEqually
//
//        progressStackView.addArrangedSubview(leftProgressView)
//        progressStackView.addArrangedSubview(rightProgressView)
//    }
    
    func configureStatsStackViews() {
        statsStackView.axis = .horizontal
        statsStackView.alignment = .fill
        statsStackView.distribution = .fillEqually
        
        statsStackView.addArrangedSubview(completedView)
        statsStackView.addArrangedSubview(failedView)
        statsStackView.addArrangedSubview(incompleteView)
        statsStackView.addArrangedSubview(totalView)
    }
    
    func configureConstraints() {
//        addSubview(purpleView)
//        purpleView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 45, paddingBottom: 0, paddingRight: 0, width: 135, height: 135)
//        addSubview(redView)
//        redView.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 45, width: 135, height: 135)
        addSubview(statsStackView)
        statsStackView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 65)
        addSubview(placeholder)
        placeholder.anchor(top: statsStackView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
//        addSubview(progressStackView)
//        progressStackView.anchor(top: statsStackView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
        
//        addSubview(statsStackView)
//        statsStackView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 65)
//        addSubview(percentLabel)
//        percentLabel.anchor(top: statsStackView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 130, height: 40)
//        addSubview(percentSublabel)
//        percentSublabel.anchor(top: percentLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 130, height: 0)
//        addSubview(progressView)
//        progressView.anchor(top: statsStackView.bottomAnchor, left: percentLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 15, paddingRight: 15, width: 0, height: 0)
    }
}
