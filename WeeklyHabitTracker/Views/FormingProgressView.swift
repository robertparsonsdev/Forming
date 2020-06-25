//
//  FormingProgressView.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/23/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class FormingProgressView: UIView {
    let label = UILabel()
    let greenView = UIView()
    let redView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.cornerRadius = 7
        backgroundColor = .systemTeal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(bounds: CGRect) {
        self.bounds = bounds
        
        greenView.backgroundColor = .systemGreen
        redView.backgroundColor = .systemRed
        
        configureLabel()
        configureConstraints()
    }
    
    func configureLabel() {
        label.text = "Test"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
    }
    
    func configureConstraints() {
        addSubview(redView)
        redView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: frame.width / 2, height: 0)
        addSubview(greenView)
        greenView.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: frame.width / 2, height: 0)
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        addBlurredView(belowView: label)
    }
}

extension UIView {
    func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UIColor.systemRed.cgColor, UIColor.systemGreen.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addBlurredView(belowView view: UIView) {
        let blurEffect = UIBlurEffect(style: .light)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = self.bounds
        insertSubview(blurredEffectView, belowSubview: view)
        print(subviews.count)
    }
}
