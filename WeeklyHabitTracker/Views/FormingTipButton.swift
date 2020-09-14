//
//  FormingTipButton.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 9/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class FormingTipButton: UIButton {
    let tip: Tip
    
    private let tipLabel = UILabel()
    private let leftImageView = UIImageView()
    private let rightImageView = UIImageView()
    private let messageLabel = UILabel()
    
    init(tip: Tip, color: UIColor, title: String, leftImage: UIImage, rightImage: UIImage, message: String) {
        self.tip = tip
        
        super.init(frame: .zero)
        
        backgroundColor = color
        
        configureButton()
        configureTipLabel(withText: title)
        configureImageView(self.leftImageView, withImage: leftImage)
        configureImageView(self.rightImageView, withImage: rightImage)
        configureMessageLabel(withText: message)
        configureContraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButton() {
        self.layer.cornerRadius = 14
        self.clipsToBounds = true
    }
    
    private func configureTipLabel(withText text: String) {
        tipLabel.text = text
        tipLabel.textColor = .white
        tipLabel.font = UIFont.boldSystemFont(ofSize: 20)
        tipLabel.textAlignment = .center
    }
    
    private func configureImageView(_ imageView: UIImageView, withImage image: UIImage) {
        imageView.image = image
    }
    
    private func configureMessageLabel(withText text: String) {
        messageLabel.text = text
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }
    
    private func configureContraints() {
        let top = topAnchor, left = leftAnchor, bottom = bottomAnchor, right = rightAnchor
        
        addSubview(tipLabel)
        tipLabel.anchor(top: top, left: nil, bottom: nil, right: nil, x: centerXAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        addSubview(leftImageView)
        leftImageView.anchor(top: nil, left: left, bottom: nil, right: nil, y: centerYAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 70, height: 70)
        addSubview(rightImageView)
        rightImageView.anchor(top: nil, left: nil, bottom: nil, right: right, y: centerYAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 70, height: 70)
        
        addSubview(messageLabel)
        messageLabel.anchor(top: tipLabel.bottomAnchor, left: leftImageView.rightAnchor, bottom: bottom, right: rightImageView.leftAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 5, width: 0, height: 0)
    }
}
