//
//  UIViewControllerExt.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 7/31/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentAlertController(withTitle title: String, andMessage message: String) {
        DispatchQueue.main.async {
            let alert = FormingAlertViewController(title: title, message: message)
            alert.modalPresentationStyle = .overFullScreen
            alert.modalTransitionStyle = .crossDissolve
            self.present(alert, animated: true)
        }
    }
}
