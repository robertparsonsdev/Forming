//
//  ArchivedHabitCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ArchivedHabitCell: UICollectionViewCell {
    private var archivedHabit: ArchivedHabit?
    private var delegate: ArchivedHabitCellDelegate?
    
    private let titleButton = UIButton()
    private let statusStackView = UIStackView()
    
    private let regularConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .regular), scale: .large)
    private let boldConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .bold), scale: .small)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(archivedHabit: ArchivedHabit) {
        self.archivedHabit = archivedHabit
        configureCell()
        configureTitleButton()
        configureStatusStackView(withStatuses: archivedHabit.statuses)
        
        configureConstraints()
    }
    
    func set(delegate: ArchivedHabitCellDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Configuration Functions
    private func configureCell() {
        layer.cornerRadius = 14
        backgroundColor = .tertiarySystemFill
        clipsToBounds = true
    }
    
    private func configureTitleButton() {
        titleButton.contentHorizontalAlignment = .left
        titleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        titleButton.titleLabel?.textColor = .white
        titleButton.addTarget(self, action: #selector(titleTapped), for: .touchUpInside)
        if let color = self.archivedHabit?.archive?.color {
            titleButton.backgroundColor = FormingColors.getColor(fromValue: color)
        }
        if let startDate = archivedHabit?.startDate, let endDate = archivedHabit?.endDate {
            let symbolAttachment = NSTextAttachment()
            symbolAttachment.image = UIImage(named: "chevron.right", in: nil, with: boldConfig)
            symbolAttachment.image = symbolAttachment.image?.withTintColor(.white)
            let dateTitle = "\(CalUtility.getDateAsString(date: startDate)) - \(CalUtility.getDateAsString(date: endDate))"
            let attributedTitle = NSMutableAttributedString(string: "  \(dateTitle) ", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .bold), .foregroundColor: UIColor.white])
            attributedTitle.append(NSAttributedString(attachment: symbolAttachment))
            titleButton.setAttributedTitle(attributedTitle, for: .normal)
        }
        
    }
    
    private func configureStatusStackView(withStatuses statuses: [Status]) {
        if !statusStackView.arrangedSubviews.isEmpty { for view in statusStackView.arrangedSubviews { view.removeFromSuperview() } }
        statusStackView.axis = .horizontal
        statusStackView.alignment = .fill
        statusStackView.distribution = .fillEqually
        for status in statuses {
            let button = UIButton()
            button.isEnabled = false
            switch status {
            case .incomplete: button.setImage(UIImage(named: "square", in: nil, with: regularConfig), for: .normal); button.imageView?.tintColor = .label
            case .completed: button.setImage(UIImage(named: "checkmark.square", in: nil, with: regularConfig), for: .normal); button.imageView?.tintColor = .systemGreen
            case .failed: button.setImage(UIImage(named: "xmark.square", in: nil, with: regularConfig), for: .normal); button.imageView?.tintColor = .systemRed
            case .empty: ()
            }
            statusStackView.addArrangedSubview(button)
        }
    }
    
    private func configureConstraints() {
        addSubview(titleButton)
        titleButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 25)
        addSubview(statusStackView)
        statusStackView.anchor(top: titleButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    // MARK: - Selectors
    @objc func titleTapped() {
        guard let archivedHabit = self.archivedHabit else { return }
        delegate?.pushViewController(with: archivedHabit)
    }
}

// MARK: - Protocols
protocol ArchivedHabitCellDelegate {
    func pushViewController(with archivedHabit: ArchivedHabit)
}
