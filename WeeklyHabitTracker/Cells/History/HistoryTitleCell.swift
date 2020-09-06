//
//  HIstoryCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 5/5/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class HistoryTitleCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let compPercentLabel = UILabel()
    private let goalPercentLabel = UILabel()
    private let compProgressView = UIView()
    private let goalProgressView = UIView()
    
    private let compDescriptionLabel = FormingSecondaryLabel(text: "Completion")
    private let goalDescriptionLabel = FormingSecondaryLabel(text: "To Goal")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 14
        clipsToBounds = true
        
        compDescriptionLabel.textColor = .white
        goalDescriptionLabel.textColor = .white
        
        configureTitleLabel()
        configure(percentLabel: compPercentLabel)
        configure(percentLabel: goalPercentLabel)
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTitleLabel() {
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        titleLabel.lineBreakMode = .byTruncatingTail
    }
    
    private func configure(percentLabel: UILabel) {
        percentLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        percentLabel.textAlignment = .left
        percentLabel.textColor = .white
    }
    
    private func createLayerAndPath(startX: CGFloat, endX: CGFloat, color: UIColor, progressView: UIView) {
        let layer = CAShapeLayer()
        let path = UIBezierPath()
        
        path.removeAllPoints()
        path.move(to: CGPoint(x: startX, y: 5.5))
        path.addLine(to: CGPoint(x: endX, y: 5.5))
        
        layer.frame = path.bounds
        layer.path = path.cgPath
        layer.strokeColor = color.cgColor
        layer.lineWidth = 12
        layer.lineCap = .round
        
        progressView.layer.addSublayer(layer)
    }
    
    private func configureConstraints() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 28)
    }
    
    private func addCompletionConstraints() {
        addSubview(compPercentLabel)
        compPercentLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        addSubview(compDescriptionLabel)
        compDescriptionLabel.anchor(top: nil, left: compPercentLabel.rightAnchor, bottom: compPercentLabel.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        addSubview(compProgressView)
        compProgressView.anchor(top: compPercentLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: centerXAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 10, width: 0, height: 0)
    }
    
    private func addGoalConstraints() {
        addSubview(goalPercentLabel)
        goalPercentLabel.anchor(top: titleLabel.bottomAnchor, left: centerXAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 20)
        addSubview(goalDescriptionLabel)
        goalDescriptionLabel.anchor(top: nil, left: goalPercentLabel.rightAnchor, bottom: goalPercentLabel.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        addSubview(goalProgressView)
        goalProgressView.anchor(top: goalPercentLabel.bottomAnchor, left: centerXAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 10, width: 0, height: 0)
    }
    
    func set(title: String) {
        titleLabel.text = title
    }
    
    func set(color: UIColor) {
        backgroundColor = color
    }
    
    func set(completionRate: Double, compRateText: String, goalRate: CGFloat?, goalRateText: String?) {
        if let goal = goalRate, let goalText = goalRateText {
            compPercentLabel.text = compRateText
            createLayerAndPath(startX: 3.0, endX: self.frame.width / 2 - 30, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.4), progressView: compProgressView)
            if completionRate != 0.0 {
                createLayerAndPath(startX: 3.0, endX: (self.frame.width / 2 - 30) * CGFloat(completionRate), color: .white, progressView: compProgressView)
            }
            
            goalPercentLabel.text = goalText
            createLayerAndPath(startX: 3.0, endX: self.frame.width / 2 - 30, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.4), progressView: goalProgressView)
            if goal != 0.0 {
                createLayerAndPath(startX: 3.0, endX: (self.frame.width / 2 - 30) * CGFloat(completionRate), color: .white, progressView: goalProgressView)
            }
            
            addCompletionConstraints()
            addGoalConstraints()
        } else {
            compPercentLabel.text = compRateText
            createLayerAndPath(startX: 3.0, endX: self.frame.width - 30, color: UIColor.lightGray.withAlphaComponent(0.5), progressView: compProgressView)
            if completionRate != 0.0 {
                createLayerAndPath(startX: 3.0, endX: (self.frame.width - 30) * CGFloat(completionRate), color: .white, progressView: compProgressView)
            }
            
            addCompletionConstraints()
        }
    }
}
