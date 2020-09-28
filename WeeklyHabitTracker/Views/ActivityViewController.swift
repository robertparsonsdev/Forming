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
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        self.containerView.backgroundColor = .black
        self.containerView.layer.cornerRadius = 14
        self.activityIndicator.color = .white
        self.activityIndicator.startAnimating()
        
        self.containerView.addSubview(self.activityIndicator)
        self.activityIndicator.anchor(top: nil, left: nil, bottom: nil, right: nil, x: self.containerView.centerXAnchor, y: self.containerView.centerYAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.view.addSubview(self.containerView)
        self.containerView.anchor(top: nil, left: nil, bottom: nil, right: nil, x: view.centerXAnchor, y: view.centerYAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: self.activityIndicator.frame.width + 20, height: self.activityIndicator.frame.height + 20)
    }
}
