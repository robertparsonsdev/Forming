//
//  OnboardingCard.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/27/21.
//  Copyright © 2021 Robert Parsons. All rights reserved.
//

import UIKit

class OnboardingCard: UIView {
    private let titleLabel = FormingTitleLabel()
    private let messageLabel = UILabel()
    private let imageView = UIImageView()

    init(title: String, message: String, image: UIImage) {
        super.init(frame: .zero)

        set(title: title, message: message, image: image)
        configure()
    }
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func set(title: String, message: String, image: UIImage) {
        titleLabel.text = title
        messageLabel.text = message
        imageView.image = image
    }
    
    private func configure() {
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 0
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        
        imageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, y: centerYAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        titleLabel.anchor(top: topAnchor, left: imageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 25)
        messageLabel.anchor(top: titleLabel.bottomAnchor, left: imageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
}
