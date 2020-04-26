//
//  File.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/26/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

extension UIButton {
    func shake(duration: TimeInterval = 0.5, xValue: CGFloat = 12, yValue: CGFloat = 0) {
        self.transform = CGAffineTransform(translationX: xValue, y: yValue)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}
