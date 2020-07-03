//
//  ArchivedHabitDetailViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/13/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ArchivedHabitDetailViewController: UIViewController {
    private var archivedHabit: ArchivedHabit?
    
    private let cell = ArchivedHabitCell()
    private let scrollView = UIScrollView()
    private let notes = FormingTextField(placeholder: "  Notes", textAlignment: .left, returnKeyType: .done)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Test"
    }
    
    func set(archivedHabit: ArchivedHabit) {
        self.archivedHabit = archivedHabit
        cell.set(archivedHabit: archivedHabit)
        configureConstraints()
    }

    func configureConstraints() {
        view.addSubview(cell)
        cell.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 90)
        
        view.addSubview(notes)
        notes.anchor(top: cell.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 300)
    }
}
