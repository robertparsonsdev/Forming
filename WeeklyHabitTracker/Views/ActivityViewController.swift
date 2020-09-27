//
//  ActivityViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 9/27/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {
    private let containerView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        containerView.backgroundColor = .black
        containerView.layer.cornerRadius = 14
        activityIndicator.color = .white
        
        containerView.addSubview(self.activityIndicator)
        activityIndicator.anchor(top: nil, left: nil, bottom: nil, right: nil, x: containerView.centerXAnchor, y: containerView.centerYAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        view.addSubview(containerView)
        containerView.anchor(top: nil, left: nil, bottom: nil, right: nil, x: view.centerXAnchor, y: view.centerYAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: activityIndicator.frame.width + 20, height: activityIndicator.frame.height + 20)
    }
    
    func startAnimating() {
        self.activityIndicator.startAnimating()
    }
}
