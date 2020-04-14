//
//  HabitCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class HabitCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 14
        backgroundColor = .tertiarySystemFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
