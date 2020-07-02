//
//  FormingSecondaryLabel.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 7/2/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class FormingSecondaryLabel: UILabel {

    init(text: String) {
        super.init(frame: .zero)
        configureLabel(withText: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel(withText text: String) {
        self.text = text
        self.textAlignment = .center
        
        self.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        self.textColor = .secondaryLabel
    }
}
