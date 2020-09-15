//
//  SettingsHeaderView.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 9/13/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class SettingsHeaderView: UITableViewHeaderFooterView {
    private weak var delegate: SettingsHeaderDelegate?
    
    private let stackView = UIStackView()
    
    // MARK: - Initializers
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        configureStackView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration Functions
    func configureStackView() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        
        let smallTipButton = FormingTipButton(product: .smallTip, color: .systemTeal, title: "$0.99 Tip", leftImage: UIImage(named: "thumbsup-left")!, rightImage: UIImage(named: "thumbsup-right")!, message: "Thank you so much for your support!")
        smallTipButton.addTarget(self, action: #selector(tipButtonTapped), for: .touchUpInside)
        let mediumTipButton = FormingTipButton(product: .mediumTip, color: .systemGreen, title: "$2.99 Tip", leftImage: UIImage(named: "celebration-left")!, rightImage: UIImage(named: "celebration-right")!, message: "You're awesome! Thank you so much!")
        mediumTipButton.addTarget(self, action: #selector(tipButtonTapped), for: .touchUpInside)
        let largeTipButton = FormingTipButton(product: .largeTip, color: .systemOrange, title: "$4.99 Tip", leftImage: UIImage(named: "explosion-left")!, rightImage: UIImage(named: "explosion-right")!, message: "Wow! I really appreciate it! Thanks!")
        largeTipButton.addTarget(self, action: #selector(tipButtonTapped), for: .touchUpInside)
        
        stackView.addArrangedSubview(smallTipButton)
        stackView.addArrangedSubview(mediumTipButton)
        stackView.addArrangedSubview(largeTipButton)
    }
    
    func configureConstraints() {
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 0)
    }
    
    // MARK: - Setters
    func set(delegate: SettingsHeaderDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Selectors
    @objc func tipButtonTapped(sender: UIButton) {
        if let tipButton = sender as? FormingTipButton {
            self.delegate?.tipButtonTapped(product: tipButton.product)
        }
    }
    
}

// MARK: - Protocols
protocol SettingsHeaderDelegate: class {
    func tipButtonTapped(product: IAPProduct)
}
