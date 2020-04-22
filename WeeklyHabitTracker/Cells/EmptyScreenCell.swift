//
//  EmptyScreenCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/20/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class EmptyScreenCell: UICollectionViewCell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLabel()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel() {
        let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .semibold), scale: .medium)
        let symbolAttachment = NSTextAttachment()
        symbolAttachment.image = UIImage(named: "plus", in: nil, with: config)
        symbolAttachment.image = symbolAttachment.image?.withTintColor(.secondaryLabel)
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: .semibold), .foregroundColor: UIColor.secondaryLabel]
        let title = NSMutableAttributedString(string: "Press the ", attributes: attributes)
        title.append(NSAttributedString(attachment: symbolAttachment))
        title.append(NSAttributedString(string: " to add a new habit.", attributes: attributes))
        
        label.attributedText = title
        label.textAlignment = .center
        label.backgroundColor = .systemBackground
    }
    
    func configureConstraints() {
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
}
