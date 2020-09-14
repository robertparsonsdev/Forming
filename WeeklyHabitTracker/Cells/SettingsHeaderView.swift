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
        
        // tip buttons:
        let redView = UIView()
        redView.backgroundColor = .systemRed
        let indigoView = UIView()
        indigoView.backgroundColor = .systemIndigo
        let blueView = UIView()
        blueView.backgroundColor = .systemBlue
        
        stackView.addArrangedSubview(redView)
        stackView.addArrangedSubview(indigoView)
        stackView.addArrangedSubview(blueView)
    }
    
    func configureConstraints() {
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 0)
    }
    
    // MARK: - Setters
    func set(delegate: SettingsHeaderDelegate) {
        self.delegate = delegate
    }
    
}

// MARK: - Protocols
protocol SettingsHeaderDelegate: class {
    func tipButtonTapped()
}
