//
//  FormingProgressView.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/23/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class FormingProgressView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
//        setGradientBackground(locationOne: 0.0, locationTwo: 1.0)
//        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 7
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setGradientBackground() {
        print("gradient")
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.systemRed.cgColor, UIColor.systemGreen.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)

        layer.addSublayer(gradientLayer)
    }
}
