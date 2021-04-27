//
//  OnboardingVCViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/27/21.
//  Copyright © 2021 Robert Parsons. All rights reserved.
//

import UIKit

class OnboardingVC: UIViewController {
    private let titleLabel = FormingTitleLabel(title: "Welcome to Forming!")
    private let continueButton = FormingButton(backgroundColor: .systemGreen, title: "Continue")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureTitleLabel()
        configureContinueButton()
        configureConstraints()
    }
    
    private func configureViewController() {
        self.view.backgroundColor = .systemBackground
    }
    
    private func configureTitleLabel() {
        titleLabel.set(fontSize: 40)
        titleLabel.set(wrapping: .byWordWrapping)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
    }
    
    private func configureContinueButton() {
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    private func configureConstraints() {
        self.view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, x: view.centerXAnchor, paddingTop: 100, paddingLeft: 50, paddingBottom: 0, paddingRight: 50, width: 0, height: 0)
        
        self.view.addSubview(continueButton)
        continueButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 25, paddingRight: 25, width: 0, height: 40)
    }
    
    @objc private func continueButtonTapped() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
