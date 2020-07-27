//
//  ArchiveDetailHeaderCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ArchiveDetailHeaderCell: UICollectionReusableView {
//    private let percentLabel = UILabel()
//    private let percentSublabel = UILabel()
    private var completionProgressView: FormingProgressView!
    private var goalProgressView: FormingProgressView!
    private let completedView = FormingStatView(title: "Completed", color: .systemGreen)
    private let failedView = FormingStatView(title: "Failed", color: .systemRed)
    private let incompleteView = FormingStatView(title: "Incomplete", color: .lightGray)
    private let totalView = FormingStatView(title: "Total", color: .label)
    private var progressY: CGFloat!
    private var progressX: CGFloat!
    private var radius: CGFloat!
    
    private let progressStackView = UIStackView()
    private let statsStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.progressY = (self.frame.height - 65) / 2
        self.progressX = self.frame.width - 30
        self.radius = self.frame.width / 4 - 25
//        configurePercentLabel()
//        configurePercentSublabel()
        configureCompletionProgressView()
        configureGoalProgressView()
        configureProgressStackView()
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
    
    func configureCompletionProgressView() {
        completionProgressView = FormingProgressView(center: CGPoint(x: self.progressX / 4, y: self.progressY),
                                                     radius: self.radius)
    }
    
    func configureGoalProgressView() {
        goalProgressView = FormingProgressView(center: CGPoint(x: self.progressX / 4, y: self.progressY),
                                               radius: self.radius)
    }
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
    
    func configureProgressStackView() {
        progressStackView.axis = .horizontal
        progressStackView.alignment = .fill
        progressStackView.distribution = .fillEqually

        progressStackView.addArrangedSubview(completionProgressView)
        progressStackView.addArrangedSubview(goalProgressView)
    }
    
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
        addSubview(statsStackView)
        statsStackView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 65)
        addSubview(progressStackView)
        progressStackView.anchor(top: statsStackView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
    }
}
