//
//  FormingProgressView.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/23/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class FormingProgressView: UIView {
    let progressLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    
    init(center: CGPoint) {
        super.init(frame: .zero)
        
        let progressPath = UIBezierPath(arcCenter: center, radius: 80, startAngle: -CGFloat.pi / 2, endAngle: (3 * CGFloat.pi) / 2, clockwise: true)
        self.progressLayer.path = progressPath.cgPath
        
        progressLayer.strokeColor = UIColor.systemGreen.cgColor
        progressLayer.lineWidth = 15
        progressLayer.strokeEnd = 0
        progressLayer.lineCap = .round
        progressLayer.fillColor = UIColor.clear.cgColor
        
        let trackPath = UIBezierPath(arcCenter: center, radius: 80, startAngle: -CGFloat.pi / 2, endAngle: (3 * CGFloat.pi) / 2, clockwise: true)
        self.trackLayer.path = trackPath.cgPath
        
        trackLayer.strokeColor = UIColor.tertiarySystemFill.cgColor
        trackLayer.lineWidth = 15
        trackLayer.lineCap = .round
        trackLayer.fillColor = UIColor.clear.cgColor
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 0.75
        basicAnimation.duration = 0.75
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        
        progressLayer.add(basicAnimation, forKey: "strokeEnd")
        
        self.layer.addSublayer(trackLayer)
        self.layer.addSublayer(progressLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//extension UIView {
//    func setGradientBackground() {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = self.bounds
//        gradientLayer.colors = [UIColor.systemRed.cgColor, UIColor.systemGreen.cgColor]
//        gradientLayer.locations = [0.0, 1.0]
//        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
//
//        layer.insertSublayer(gradientLayer, at: 0)
//    }
//
//    func addBlurredView(belowView view: UIView) {
//        let blurEffect = UIBlurEffect(style: .light)
//        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
//        blurredEffectView.frame = self.bounds
//        insertSubview(blurredEffectView, belowSubview: view)
//    }
//}
