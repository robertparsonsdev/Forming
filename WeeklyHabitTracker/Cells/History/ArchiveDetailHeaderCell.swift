//
//  ArchiveDetailHeaderCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ArchiveDetailHeaderCell: UICollectionReusableView {
    private var completed: Int64!
    private var failed: Int64!
    private var incomplete: Int64!
    private var total: Int64!
    private var goal: Int64!
    
    private var completionProgressView: FormingProgressView!
    private var goalProgressView: FormingProgressView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(completionRate: Double) {
        completionProgressView = FormingProgressView(xPosition: self.frame.width - 55,
                                                     progressRate: completionRate)
        completionProgressView.set(description: "Completion Rate")
        completionProgressView.set(infoOne: "\(self.completed ?? -1) Completed")
        completionProgressView.set(infoTwo: "\(self.failed ?? -1) Failed")
    }
    
    func set(goalProgress: Double) {
        goalProgressView = FormingProgressView(xPosition: self.frame.width - 55,
                                               progressRate: goalProgress)
        goalProgressView.set(description: "Goal Progress")
        goalProgressView.set(infoOne: "\(self.completed ?? -1) Completed")
        goalProgressView.set(infoTwo: "Goal: \(self.goal ?? -1)")
    }
    
    func set(completed: Int64, failed: Int64, incomplete: Int64) {
        self.completed = completed
        self.failed = failed
        self.incomplete = incomplete
        self.total = completed + failed + incomplete
    }
    
    func set(goal: Int64) {
        self.goal = goal
    }
    
    func configureViews() {
        configureConstraints()
    }
    
    private func configureConstraints() {
        addSubview(completionProgressView)
        completionProgressView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 65)
        addSubview(goalProgressView)
        goalProgressView.anchor(top: completionProgressView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 65)
    }
}
