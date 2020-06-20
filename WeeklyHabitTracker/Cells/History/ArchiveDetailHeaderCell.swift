//
//  ArchiveDetailHeaderCell.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ArchiveDetailHeaderCell: UICollectionViewCell {
    let mainStackView = UIStackView()
    let percentLabel = UILabel()
    let pieChart = UILabel()
    
    let statsStackView = UIStackView()
    let completedLabel = UILabel()
    let failedLabel = UILabel()
    let incompleteLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        configurePercentLabel()
        configurePieChart()
        configureStatsLabel(label: completedLabel)
        configureStatsLabel(label: failedLabel)
        configureStatsLabel(label: incompleteLabel)
        configureStatsStackView()
        configureMainStackView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(percentage: String) {
        percentLabel.text = percentage
    }
    
    func set(completed: Int64, failed: Int64, incomplete: Int64) {
        completedLabel.text = "completed: \(completed)"
        failedLabel.text = "failed: \(failed)"
        incompleteLabel.text = "incomplete \(incomplete)"
    }
    
    func configurePercentLabel() {
        percentLabel.textAlignment = .center
        percentLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
    }
    
    func configurePieChart() {
        pieChart.textAlignment = .center
        pieChart.font = UIFont.boldSystemFont(ofSize: 20)
        pieChart.numberOfLines = 0
        pieChart.text = "Pie Chart Coming Later ☢️"
    }
    
    func configureStatsLabel(label: UILabel) {
        label.layer.cornerRadius = 10
        label.textAlignment = .center
        label.textColor = .white
        label.clipsToBounds = true
        switch label {
        case completedLabel: label.backgroundColor = .systemGreen
        case failedLabel: label.backgroundColor = .systemRed
        case incompleteLabel: label.backgroundColor = .systemGray
        default: ()
        }
    }
    
    func configureStatsStackView() {
        statsStackView.axis = .vertical
        statsStackView.alignment = .fill
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 10
        statsStackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        statsStackView.isLayoutMarginsRelativeArrangement = true
        statsStackView.addArrangedSubview(completedLabel)
        statsStackView.addArrangedSubview(failedLabel)
        statsStackView.addArrangedSubview(incompleteLabel)
    }
    
    func configureMainStackView() {
        mainStackView.axis = .horizontal
        mainStackView.alignment = .fill
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = 5
        
        mainStackView.addArrangedSubview(percentLabel)
        mainStackView.addArrangedSubview(pieChart)
        mainStackView.addArrangedSubview(statsStackView)
    }
    
    func configureConstraints() {
        addSubview(mainStackView)
        mainStackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
    }
}
