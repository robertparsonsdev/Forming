//
//  FormingAlertViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 7/31/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class FormingAlertViewController: UIViewController {
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let okayButton = UIButton()
    
    private let alertTitle: String
    private let message: String
    
    init(title: String, message: String) {
        self.alertTitle = title
        self.message = message
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        configureContainer()
        configureTitleLabel()
        configureMessageLabel()
        configureOkayButton()
        configureConstraints()
    }
    
    private func configureContainer() {
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 14
    }
    
    private func configureTitleLabel() {
        titleLabel.text = self.alertTitle
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
    }
    
    private func configureMessageLabel() {
        messageLabel.text = self.message
        messageLabel.textAlignment = .center
    }
    
    private func configureOkayButton() {
        okayButton.setTitle("Okay", for: .normal)
        okayButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        okayButton.backgroundColor = .systemGreen
        okayButton.layer.cornerRadius = 7
        okayButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
    }
    
    private func configureConstraints() {
        containerView.addSubview(titleLabel)
        titleLabel.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 30)
        containerView.addSubview(okayButton)
        okayButton.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 15, paddingRight: 15, width: 0, height: 40)
        containerView.addSubview(messageLabel)
        messageLabel.anchor(top: titleLabel.bottomAnchor, left: containerView.leftAnchor, bottom: okayButton.topAnchor, right: containerView.rightAnchor, paddingTop: 15, paddingLeft: 15, paddingBottom: 15, paddingRight: 15, width: 0, height: 0)
        
        view.addSubview(containerView)
        containerView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, y: view.centerYAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 300)
    }
    
    @objc func dismissAlert() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }

}
