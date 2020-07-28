//
//  FormingProgressView.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/23/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class FormingProgressView: UIView {
    private let progressRate: Double
    
    private let percentLabel = UILabel()
    private let descriptionLabel = FormingSecondaryLabel()
    private let infoButton = UIButton()
    private let progressContainer = UIView()
    private let infoLabelOne = FormingSecondaryLabel()
    private let infoLabelTwo = FormingSecondaryLabel()
    
    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    
    init(xPosition: CGFloat, progressRate: Double) {
        self.progressRate = progressRate
        super.init(frame: .zero)

        configurePercentLabel(withText: self.progressRate)
        configureInfoButton()
        configureProgressContainer(withX: xPosition)
        animate(from: 0.0, to: CGFloat(self.progressRate), onLayer: self.progressLayer)
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurePercentLabel(withText rate: Double) {
        if rate == 1.0 {
            percentLabel.text = String(format: "%.0f%%", rate * 100)
        } else {
            percentLabel.text = String(format: "%.1f%%", rate * 100)
        }
        percentLabel.textAlignment = .center
        percentLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
    }
    
    func set(description: String) {
        descriptionLabel.set(text: description)
    }
    
    func set(infoOne: String) {
        infoLabelOne.set(text: infoOne)
    }
    
    func set(infoTwo: String) {
        infoLabelTwo.set(text: infoTwo)
    }
    
    func configureInfoButton() {
        infoButton.setImage(UIImage(named: "info.circle"), for: .normal)
        infoButton.tintColor = .label
    }
    
    func configureProgressContainer(withX x: CGFloat) {
        let trackPath = UIBezierPath()
        trackPath.move(to: CGPoint(x: 5, y: 5))
        trackPath.addLine(to: CGPoint(x: x, y: 5))
        self.trackLayer.frame = trackPath.bounds
        self.trackLayer.path = trackPath.cgPath
        self.trackLayer.strokeColor = UIColor.tertiarySystemFill.cgColor
        self.trackLayer.lineWidth = 15
        self.trackLayer.lineCap = .round
        
        let progressPath = UIBezierPath()
        progressPath.move(to: CGPoint(x: 5, y: 5))
        progressPath.addLine(to: CGPoint(x: x, y: 5))
        self.progressLayer.frame = progressPath.bounds
        self.progressLayer.path = progressPath.cgPath
        self.progressLayer.strokeColor = UIColor.systemGreen.cgColor
        self.progressLayer.lineWidth = 15
        self.progressLayer.lineCap = .round
                
        self.progressContainer.layer.addSublayer(self.trackLayer)
        self.progressContainer.layer.addSublayer(self.progressLayer)
    }
    
    func animate(from fromValue: CGFloat, to toValue: CGFloat, onLayer layer: CAShapeLayer) {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.fromValue = fromValue
        basicAnimation.toValue = toValue
        basicAnimation.duration = CFTimeInterval((toValue / toValue) * 0.75)
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        layer.add(basicAnimation, forKey: "line")
    }
    
    func configureConstraints() {
        addSubview(percentLabel)
        percentLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//        progressContainer.backgroundColor = .systemBlue
        addSubview(progressContainer)
        progressContainer.anchor(top: percentLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        addSubview(descriptionLabel)
        descriptionLabel.anchor(top: nil, left: percentLabel.rightAnchor, bottom: progressContainer.topAnchor, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 7, paddingRight: 0, width: 0, height: 0)

        addSubview(infoButton)
        infoButton.anchor(top: nil, left: nil, bottom: progressContainer.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)

        addSubview(infoLabelOne)
        infoLabelOne.anchor(top: progressContainer.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        addSubview(infoLabelTwo)
        infoLabelTwo.anchor(top: progressContainer.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 0, height: 0)
    }
}

//        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: (3 * CGFloat.pi) / 2, clockwise: true)
//        self.progressLayer.path = progressPath.cgPath
//
//        progressLayer.strokeColor = UIColor.systemGreen.cgColor
//        progressLayer.lineWidth = 15
//        progressLayer.strokeEnd = 0
//        progressLayer.lineCap = .round
//        progressLayer.fillColor = UIColor.clear.cgColor
//
//        let trackPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: (3 * CGFloat.pi) / 2, clockwise: true)
//        self.trackLayer.path = trackPath.cgPath
//
//        trackLayer.strokeColor = UIColor.tertiarySystemFill.cgColor
//        trackLayer.lineWidth = 15
//        trackLayer.lineCap = .round
//        trackLayer.fillColor = UIColor.clear.cgColor
//
//        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
//        basicAnimation.toValue = 0.75
//        basicAnimation.duration = 0.75
//        basicAnimation.fillMode = .forwards
//        basicAnimation.isRemovedOnCompletion = false
//
//        progressLayer.add(basicAnimation, forKey: "strokeEnd")
//
//        self.layer.addSublayer(trackLayer)
//        self.layer.addSublayer(progressLayer)
