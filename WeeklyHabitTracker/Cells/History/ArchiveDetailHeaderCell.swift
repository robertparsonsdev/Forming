//
//  ArchiveDetailHeaderCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ArchiveDetailHeaderCell: UICollectionReusableView {
    private var completionProgressView: FormingProgressView!
    private var goalProgressView: FormingProgressView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(completed: Int64, failed: Int64, completionRate: Double, goal: Int64) {
        if completionProgressView != nil { completionProgressView.removeFromSuperview() }
        completionProgressView = FormingProgressView(startX: 5.0, endX: self.frame.width - 55, progressRate: CGFloat(completionRate))
        completionProgressView.set(description: "Completion Rate")
        completionProgressView.set(infoOne: "\(completed) Completed")
        completionProgressView.set(infoTwo: "\(failed) Failed")
        completionProgressView.addLayer(startX: self.frame.width - 55, endX: 5.0, color: .systemRed, rate: CGFloat(1.0 - completionRate))
        
        if goalProgressView != nil { goalProgressView.removeFromSuperview() }
        if goal == 0 {
            goalProgressView = FormingProgressView(startX: 5.0, endX: self.frame.width - 55, progressRate: 0)
            goalProgressView.set(percentLabel: "N/A")
            goalProgressView.set(description: "Goal Progress")
            goalProgressView.set(infoOne: "\(completed) Completed")
            goalProgressView.set(infoTwo: "Goal: Never-ending")
        } else {
            goalProgressView = FormingProgressView(startX: 5.0, endX: self.frame.width - 55, progressRate: CGFloat(completed) / CGFloat(goal))
            goalProgressView.set(description: "Goal Progress")
            goalProgressView.set(infoOne: "\(completed) Completed")
            goalProgressView.set(infoTwo: "Goal: \(goal)")
        }
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        addSubview(completionProgressView)
        completionProgressView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 65)
        addSubview(goalProgressView)
        goalProgressView.anchor(top: completionProgressView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 65)
    }
}
