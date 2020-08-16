//
//  ArchiveDetailHeaderCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ArchiveDetailHeaderCell: UICollectionReusableView {
    private var completionProgressView = FormingProgressView()
    private var goalProgressView = FormingProgressView()
    private let startX: CGFloat = 5.0
    private var endX: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.endX = self.frame.width - 55
        
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(completed: Int64, failed: Int64, completionRate: Double, goal: Int64) {
        completionProgressView.set(compensate: true)
        completionProgressView.set(trackStartX: self.startX, trackEndX: self.endX)
        completionProgressView.set(progressRate: CGFloat(completionRate), startX: self.startX, endX: self.endX)
        completionProgressView.set(failedRate: CGFloat(1.0 - completionRate), startX: self.endX, endX: self.startX)
        completionProgressView.set(percentLabel: Int(completionRate * 100) % 100 == 0 ? String(format: "%.0f%%", completionRate * 100) : String(format: "%.1f%%", completionRate * 100))
        completionProgressView.set(description: "Completion Rate")
        completionProgressView.set(infoOne: "\(completed) Completed")
        completionProgressView.set(infoTwo: "\(failed) Failed")
        
        goalProgressView.set(trackStartX: self.startX, trackEndX: self.endX)
        goalProgressView.set(description: "Goal Progress")
        goalProgressView.set(infoOne: "\(completed) Completed")
        if goal == 0 {
            goalProgressView.set(progressRate: CGFloat(goal), startX: self.startX, endX: self.endX)
            goalProgressView.set(percentLabel: "N/A")
            goalProgressView.set(infoTwo: "Goal: Off")
        } else {
            let goalRate = CGFloat(completed) / CGFloat(goal)
            goalProgressView.set(progressRate: goalRate, startX: self.startX, endX: self.endX)
            goalProgressView.set(percentLabel: Int(goalRate * 100) % 100 == 0 ? String(format: "%.0f%%", goalRate * 100) : String(format: "%.1f%%", goalRate * 100))
            goalProgressView.set(infoTwo: "Goal: \(goal)")
        }
    }
    
    private func configureConstraints() {
        addSubview(completionProgressView)
        completionProgressView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 65)
        addSubview(goalProgressView)
        goalProgressView.anchor(top: completionProgressView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 65)
    }
}
