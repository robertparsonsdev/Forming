//
//  FormingProgressView.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/23/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class FormingProgressView: UIView {
    private let percentLabel = UILabel()
    private let descriptionLabel = FormingSecondaryLabel()
    private let infoButton = UIButton()
    private let progressContainer = UIView()
    private let infoLabelOne = FormingSecondaryLabel()
    private let infoLabelTwo = FormingSecondaryLabel()
    
    private let trackLayer = CAShapeLayer()
    private let trackPath = UIBezierPath()
    private let progressLayer = CAShapeLayer()
    private let progressPath = UIBezierPath()
    private let failedLayer = CAShapeLayer()
    private let failedPath = UIBezierPath()
    
    private let yPosition: CGFloat = 5.0
    private var reloaded = false
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configurePercentLabel()
        configureInfoButton()
        configureProgressContainer()
        configureConstraints()
    }
    
//    init(startX: CGFloat, endX: CGFloat, progressRate: CGFloat) {
//        super.init(frame: .zero)
//
//        let trackLayer = addLayer(startX: startX, endX: endX, andColor: .tertiarySystemFill)
//        self.progressContainer.layer.addSublayer(trackLayer)
//
//        let progressLayer = addLayer(startX: startX, endX: endX, andColor: .systemGreen)
//        self.progressContainer.layer.addSublayer(progressLayer)
//        animate(from: 0.0, to: progressRate, onLayer: progressLayer)
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configuration Functions
    private func configurePercentLabel() {
        percentLabel.textAlignment = .center
        percentLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
    }
    
    private func configureInfoButton() {
        infoButton.setImage(UIImage(named: "info.circle"), for: .normal)
        infoButton.tintColor = .label
    }
    
    private func configureProgressContainer() {
        progressContainer.layer.addSublayer(self.trackLayer)
        progressContainer.layer.addSublayer(self.progressLayer)
        progressContainer.layer.addSublayer(self.failedLayer)
    }
    
    private func configureLayer(_ layer: CAShapeLayer, path: UIBezierPath, startX: CGFloat, endX: CGFloat, andColor color: UIColor) {
        path.move(to: CGPoint(x: startX, y: self.yPosition))
        path.addLine(to: CGPoint(x: endX, y: self.yPosition))
        
        layer.frame = path.bounds
        layer.path = path.cgPath
        layer.strokeColor = color.cgColor
        layer.lineWidth = 15
        layer.lineCap = .round
    }
    
    private func configureConstraints() {
        addSubview(percentLabel)
        percentLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
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
    
    // MARK: - Setters
    func set(percentLabel text: String) {
        self.percentLabel.text = text
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
    
    func set(progressRate: CGFloat, startX: CGFloat, endX: CGFloat) {
        self.progressContainer.layer.addSublayer(self.trackLayer)
        configureLayer(self.trackLayer, path: self.trackPath, startX: startX, endX: endX, andColor: .tertiarySystemFill)

        if self.reloaded {
            self.progressLayer.removeAllAnimations()
            self.progressLayer.removeFromSuperlayer()
//            self.progressContainer.layer.addSublayer(self.progressLayer)
        }
        configureLayer(self.progressLayer, path: self.progressPath, startX: startX, endX: endX * progressRate, andColor: .systemGreen)
        animate(from: 0.0, to: 1.0, onLayer: self.progressLayer)
        self.reloaded = true
    }
    
    func set(failedRate: CGFloat, startX: CGFloat, endX: CGFloat) {
        
    }
    
//    func addLayer(startX: CGFloat, endX: CGFloat, color: UIColor, rate: CGFloat) {
//        let layer = addLayer(startX: startX, endX: endX, andColor: color)
//        self.progressContainer.layer.addSublayer(layer)
//        animate(from: 0.0, to: rate, onLayer: layer)
//    }
    
    // MARK: - Functions
    private func animate(from fromValue: CGFloat, to toValue: CGFloat, onLayer layer: CAShapeLayer) {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.fromValue = fromValue
        if toValue == 1.0 {
            basicAnimation.toValue = toValue
        } else {
            basicAnimation.toValue = toValue - 0.02125
        }
        basicAnimation.duration = CFTimeInterval((toValue / toValue) * 0.75)
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        layer.add(basicAnimation, forKey: "line")
    }
}
