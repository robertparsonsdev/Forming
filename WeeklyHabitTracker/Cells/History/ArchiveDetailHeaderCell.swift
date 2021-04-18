//
//  ArchiveDetailHeaderCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ArchiveDetailHeaderCell: UICollectionReusableView {
    private var successProgressView = FormingProgressView()
    private var goalProgressView = FormingProgressView()
    private var stackView = UIStackView()
    private let startX: CGFloat = 5.0
    private var endX: CGFloat = 0.0
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.endX = self.frame.width - 55
        backgroundColor = .systemBackground
        
        configureStackView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("archive detail header deinit")
    }
    
    // MARK: - Setters
    func set(completed: Int64, failed: Int64, successRate: Double, goal: Int64) {
        successProgressView.set(compensate: true)
        successProgressView.set(trackStartX: self.startX, trackEndX: self.endX)
        successProgressView.set(progressRate: CGFloat(successRate), startX: self.startX, endX: self.endX)
        successProgressView.set(failedRate: CGFloat(1.0 - successRate), startX: self.endX, endX: self.startX)
        successProgressView.set(percentLabel: Int(successRate * 100) % 100 == 0 ? String(format: "%.0f%%", successRate * 100) : String(format: "%.2f%%", successRate * 100))
        successProgressView.set(description: "Success Rate")
        successProgressView.set(infoOne: "\(completed) Completed")
        successProgressView.set(infoTwo: "\(failed) Failed")
        
        goalProgressView.set(trackStartX: self.startX, trackEndX: self.endX)
        goalProgressView.set(description: "Goal Progress")
        goalProgressView.set(infoOne: "\(completed) Completed")
        if goal == -1 {
            goalProgressView.set(progressRate: CGFloat(goal), startX: self.startX, endX: self.endX)
            goalProgressView.set(percentLabel: "N/A")
            goalProgressView.set(infoTwo: "Goal: Off")
        } else {
            let goalRate = CGFloat(completed) / CGFloat(goal)
            goalProgressView.set(progressRate: goalRate, startX: self.startX, endX: self.endX)
            goalProgressView.set(percentLabel: Int(goalRate * 100) % 100 == 0 ? String(format: "%.0f%%", goalRate * 100) : String(format: "%.2f%%", goalRate * 100))
            goalProgressView.set(infoTwo: "Goal: \(goal)")
        }
    }
    
    func set(completed: Int64, failed: Int64, incomplete: Int64) {
        if let statViews = stackView.arrangedSubviews as? [FormingStatView] {
            for view in statViews { view.removeFromSuperview() }
        }
        
        let completedStatView = FormingStatView(title: "Completed", color: .systemFill)
        completedStatView.set(stat: completed)
        
        let failedStatView = FormingStatView(title: "Failed", color: .systemFill)
        failedStatView.set(stat: failed)
        
        let incompleteStatView = FormingStatView(title: "Incomplete", color: .systemFill)
        incompleteStatView.set(stat: incomplete)
        
        let totalStatView = FormingStatView(title: "Total", color: .systemFill)
        totalStatView.set(stat: completed + failed + incomplete)
        
        stackView.addArrangedSubview(completedStatView)
        stackView.addArrangedSubview(failedStatView)
        stackView.addArrangedSubview(incompleteStatView)
        stackView.addArrangedSubview(totalStatView)
    }
    
    func set(delegate: FormingProgressViewDelegate) {
        successProgressView.set(delegate: delegate)
        goalProgressView.set(delegate: delegate)
    }
    
    // MARK: - Configuration Functions
    private func configureStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
    }
    
    private func configureConstraints() {
        let top = topAnchor, left = leftAnchor, right = rightAnchor
        
        addSubview(stackView)
        stackView.anchor(top: top, left: left, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 65)

        addSubview(successProgressView)
        successProgressView.anchor(top: stackView.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 65)

        addSubview(goalProgressView)
        goalProgressView.anchor(top: successProgressView.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 65)
    }
}
