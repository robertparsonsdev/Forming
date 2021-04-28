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
    private let cardOne = OnboardingCard()
    private let cardTwo = OnboardingCard()
    private let cardThree = OnboardingCard()
    private let stackView = UIStackView()
    private let continueButton = FormingButton(backgroundColor: .systemGreen, title: "Continue")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureTitleLabel()
        configureCards()
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
    
    private func configureCards() {
        cardOne.set(title: "Keep Track of Habits",
                    message: "Forming allows you to create habits and see what needs to get done on a weekly basis.",
                    image: ((UIImage(systemName: "checkmark.square")?.withTintColor(.systemGreen))?.withRenderingMode(.alwaysOriginal))!)
        cardTwo.set(title: "Taking Accountability",
                    message: "Automated tracking automatically marks incomplete habits as failed, helping to keep you accountable.",
                    image: ((UIImage(systemName: "xmark.square")?.withTintColor(.systemGreen))?.withRenderingMode(.alwaysOriginal))!)
        cardThree.set(title: "Record Keeping",
                      message: "View statistics and historical data, set goals, and take notes about any habit.",
                      image: ((UIImage(systemName: "clock")?.withTintColor(.systemGreen))?.withRenderingMode(.alwaysOriginal))!)
        
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 25
        stackView.addArrangedSubview(cardOne)
        stackView.addArrangedSubview(cardTwo)
        stackView.addArrangedSubview(cardThree)
    }
    
    private func configureContinueButton() {
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    private func configureConstraints() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(stackView)
        self.view.addSubview(continueButton)

        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, x: view.centerXAnchor, paddingTop: 75, paddingLeft: 50, paddingBottom: 0, paddingRight: 50, width: 0, height: 0)
        
        stackView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, x: view.centerXAnchor, y: view.centerYAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 0, paddingRight: 25, width: 0, height: 0)
        
        continueButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 25, paddingRight: 25, width: 0, height: 40)
    }
    
    @objc private func continueButtonTapped() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
