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
    private let goalDescriptionLabel = FormingSecondaryLabel(text: "Goal")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 14
        clipsToBounds = true
        
        configureTitleLabel()
        configure(percentLabel: compPercentLabel)
        configure(percentLabel: goalPercentLabel)
        createLayerAndPath(startX: 3.0, endX: self.frame.width / 2 - 30, color: .tertiaryLabel, progressView: compProgressView)
        createLayerAndPath(startX: 3.0, endX: self.frame.width / 2 - 30, color: .tertiaryLabel, progressView: goalProgressView)
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
        
        addSubview(compPercentLabel)
        compPercentLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        goalPercentLabel.text = "100%"
        addSubview(goalPercentLabel)
        goalPercentLabel.anchor(top: titleLabel.bottomAnchor, left: centerXAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 20)
        
        addSubview(compDescriptionLabel)
        compDescriptionLabel.anchor(top: nil, left: compPercentLabel.rightAnchor, bottom: compPercentLabel.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        addSubview(goalDescriptionLabel)
        goalDescriptionLabel.anchor(top: nil, left: goalPercentLabel.rightAnchor, bottom: goalPercentLabel.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(compProgressView)
        compProgressView.anchor(top: compPercentLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: centerXAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 10, width: 0, height: 0)
        addSubview(goalProgressView)
        goalProgressView.anchor(top: goalPercentLabel.bottomAnchor, left: centerXAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 10, width: 0, height: 0)
    }
    
    func set(title: String) {
        titleLabel.text = title
    }
    
    func set(color: UIColor) {
        backgroundColor = color
    }
    
    func set(completionRate: Double, text: String) {
        compPercentLabel.text = text
        if completionRate != 0.0 {
            createLayerAndPath(startX: 3.0, endX: (self.frame.width / 2 - 30) * CGFloat(completionRate), color: .white, progressView: compProgressView)
        }
    }
    
    func set(goalRate: CGFloat?, text: String) {
        goalPercentLabel.text = text
        if let rate = goalRate {
            if rate != 0.0 {
                createLayerAndPath(startX: 3.0, endX: (self.frame.width / 2 - 30) * rate, color: .white, progressView: goalProgressView)
            }
        }
    }
}
