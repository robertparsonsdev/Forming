//
//  HistorySectionHeader.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/13/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class HistorySectionHeader: UICollectionViewCell {
    private let label = UILabel()
    private let collapseButton = UIButton()
    private var delegate: CollapsibleHeaderDelegate!
    private var section: HistorySection!
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLabel()
        configureCollapseButton()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setters
    func set(title: String) {
        label.text = title
    }
    
    func set(delegate: CollapsibleHeaderDelegate) {
        self.delegate = delegate
    }
    
    func set(section: HistorySection) {
        self.section = section
    }
    
    // MARK: - Configuration Functions
    func configureLabel() {
        label.textColor = .label
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    func configureCollapseButton() {
        collapseButton.setImage(UIImage(named: "chevron.down"), for: .normal)
        collapseButton.imageView?.tintColor = .label
        collapseButton.addTarget(self, action: #selector(collapseButtonTapped), for: .touchUpInside)
    }
    
    func configureConstraints() {
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        addSubview(collapseButton)
        collapseButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 40, height: 0)
    }
    
    // MARK: - Selectors
    @objc func collapseButtonTapped(sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            UIView.animate(withDuration: 0.25) {
                sender.transform = CGAffineTransform(rotationAngle: 0)
            }
            self.delegate.collapseOrExpand(action: sender.isSelected, atSection: self.section)
        } else {
            sender.isSelected = true
            UIView.animate(withDuration: 0.25) {
                sender.transform = CGAffineTransform(rotationAngle: -1.5708)
            }
            self.delegate.collapseOrExpand(action: sender.isSelected, atSection: self.section)
        }
    }
}

// MARK: - Protocols
protocol CollapsibleHeaderDelegate {
    func collapseOrExpand(action collapse: Bool, atSection section: HistorySection)
}
