//
//  FormingColorButton.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/15/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class FormingColorButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(color: UIColor, width: CGFloat) {
        super.init(frame: .zero)
        configure(color: color, width: width)
    }
    
    func configure(color: UIColor = .white, width: CGFloat = 0) {
        backgroundColor = color
        layer.masksToBounds = true
        layer.cornerRadius = width / 2
        clipsToBounds = true
    }

}
