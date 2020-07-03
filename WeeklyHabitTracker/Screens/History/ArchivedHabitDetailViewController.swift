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
    private let container = UIView()
    private let notesLabel = UILabel()
    private let notesTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Test"
        
        configureContainer()
        configureNotesLabel()
        configureNotesTextView()
        configureConstraints()
    }
    
    func set(archivedHabit: ArchivedHabit) {
        self.archivedHabit = archivedHabit
        cell.set(archivedHabit: archivedHabit)
    }
    
    func configureContainer() {
        container.layer.cornerRadius = 14
        container.backgroundColor = .tertiarySystemFill
    }
    
    func configureNotesLabel() {
        notesLabel.text = "Notes:"
        notesLabel.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    func configureNotesTextView() {
        notesTextView.backgroundColor = .clear
        notesTextView.font = UIFont.systemFont(ofSize: 17)
    }

    func configureConstraints() {
        view.addSubview(cell)
        cell.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 90)
        
        view.addSubview(container)
        container.anchor(top: cell.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 300)
        view.addSubview(notesLabel)
        notesLabel.anchor(top: container.topAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 25)
        container.addSubview(notesTextView)
        notesTextView.anchor(top: notesLabel.bottomAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, right: container.rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 5, width: 0, height: 0)
    }
}
