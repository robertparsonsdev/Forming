//
//  NewHabitDetailTableViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 7/17/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class NewHabitDetailTableViewController: UITableViewController {
    private let headerReuseIdentifier = "header"
    private let cellReuseIdentifier = "cell"
    
    private let persistenceManager: PersistenceService
    private let habitDelegate: HabitDetailDelegate
    private var editMode: Bool = false
    private var habit: Habit!
    
    // MARK: - Initializers
    init(persistenceManager: PersistenceService, delegate: HabitDetailDelegate) {
        self.persistenceManager = persistenceManager
        self.habitDelegate = delegate
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = self.editMode ? "Habit Details" : "New Habit"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        if self.editMode {
            let finButton = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .done, target: self, action: #selector(finishButtonTapped))
            navigationItem.rightBarButtonItems = [saveButton, finButton]
        } else {
            navigationItem.rightBarButtonItems = [saveButton]
        }
        
        tableView.register(HabitDetailHeader.self, forHeaderFooterViewReuseIdentifier: self.headerReuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return SectionNumber.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SectionNumber.firstSection.rawValue: return FirstSection.allCases.count
        default: return SecondSection.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case SectionNumber.firstSection.rawValue:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.headerReuseIdentifier) as! HabitDetailHeader
            if self.editMode {
                header.set(title: self.habit.title)
                header.set(days: self.habit.days)
                header.set(color: self.habit.color)
            }
            return header
        default: return UIView()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case SectionNumber.firstSection.rawValue: return 300
        default: return 20
        }
    }
    
    // MARK: - Setters
    func set(habit: Habit) {
        self.habit = habit
        self.editMode = true
    }
    
    // MARK: - Selectors
    @objc func saveButtonTapped() {
        print("save tapped")
        DispatchQueue.main.async { self.dismiss(animated: true) }
    }
    
    @objc func finishButtonTapped() {
        print("finished tapped")
        DispatchQueue.main.async { self.dismiss(animated: true) }
    }
    
    @objc func cancelButtonTapped() {
        DispatchQueue.main.async { self.dismiss(animated: true) }
    }
}

// MARK: - Protocols
protocol HabitDetailDelegate  {
    func add(habit: Habit)
    func update(habit: Habit, deleteNotifications: (Bool, [Bool]), updateNotifications: Bool)
    func finish(habit: Habit)
}

// MARK: - Enums
enum SectionNumber: Int, CaseIterable {
    case firstSection, secondSection
}

enum FirstSection: Int, CaseIterable {
    case goal, automaticTracking
}

enum SecondSection: Int, CaseIterable {
    case reminder, priority, flag
}
