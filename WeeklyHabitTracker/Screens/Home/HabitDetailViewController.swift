//
//  NewHabitViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/15/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit
import UserNotifications

class HabitDetailViewController: UIViewController {
    private let persistenceManager: PersistenceService
    private var habitDelegate: HabitDetailDelegate
    private let haptics = UISelectionFeedbackGenerator()
    
    private var editMode = false
    private var habit: Habit!
    
    private let scrollView = UIScrollView()
    private let titleTextField = FormingTextField(placeholder: "Habit Title" , returnKeyType: .done)
    private let daysStackView = UIStackView()
    private let daySelectionLabel = FormingSecondaryLabel(text: "Select at least one day.")
    private let topColorsStackView = UIStackView()
    private let bottomColorsStackView = UIStackView()
    private let colorSelectionLabel = FormingSecondaryLabel(text: "Select a color.")
    private var formingTableView: FormingTableView?
    private let finishButton = FormingFinishButton()
    private var dateCreatedLabel: FormingSecondaryLabel!
    
    private let days = ["Su", "M", "T", "W", "Th", "F", "Sa"]
    private var dayFlags = [false, false, false, false, false, false, false]
    private var dayStatuses = [Status]()
    private let topColors = [FormingColors.getColor(fromValue: 0), FormingColors.getColor(fromValue: 1), FormingColors.getColor(fromValue: 2), FormingColors.getColor(fromValue: 3), FormingColors.getColor(fromValue: 4)]
    private let bottomColors = [FormingColors.getColor(fromValue: 5), FormingColors.getColor(fromValue: 6), FormingColors.getColor(fromValue: 7), FormingColors.getColor(fromValue: 8), FormingColors.getColor(fromValue: 9)]
    private var colorFlags = [false, false, false, false, false, false, false, false, false, false]
    private var selectedColor: Int? = nil
    private var priority: Int64 = 0
    private var flag: Bool = false
    private var reminder: Date? = CalUtility.getTimeAsDate(time: "9:00 AM")
    private var dateCreated = CalUtility.getCurrentDate()
        
    // MARK: - Initializers
    init(persistenceManager: PersistenceService, delegate: HabitDetailDelegate) {
        self.persistenceManager = persistenceManager
        self.habitDelegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = editMode ? "Habit Details" : "New Habit"
        
        configureScrollView()
        titleTextField.delegate = self
        if !editMode { titleTextField.becomeFirstResponder() }
        configureStackView(daysStackView, withArray: days)
        configureStackView(topColorsStackView, withArray: topColors)
        configureStackView(bottomColorsStackView, withArray: bottomColors)
        self.formingTableView = FormingTableView(priority: self.priority, reminder: self.reminder, flag: self.flag)
        self.formingTableView?.tableDelegate = self
        self.finishButton.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
        self.dateCreatedLabel = FormingSecondaryLabel(text: "Date Created: \(CalUtility.getDateAsString(date: self.dateCreated))")
        configureConstraints()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
    }
    
    // MARK: - Configuration Functions
    func configureScrollView() {
        self.scrollView.backgroundColor = .systemBackground
        self.scrollView.alwaysBounceVertical = true
    }
    
    func configureStackView(_ stackView : UIStackView, withArray items: [Any]) {
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        if items as? [String] == self.days {
            stackView.spacing = (view.frame.width - 30 - 280) / 6
            let heavyAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .heavy)]
            let thinAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .thin)]
            for (index, item) in items.enumerated() {
                guard let day = item as? String else { return }
                let button = FormingDayButton(title: day, tag: index, width: 40)
                button.setAttributedTitle(NSAttributedString(string: day, attributes: thinAttribute), for: .normal)
                button.setAttributedTitle(NSAttributedString(string: day, attributes: heavyAttribute), for: .selected)
                button.setBackgroundColor(color: .systemFill, forState: .selected)
                button.addTarget(self, action: #selector(dayButtonTapped), for: .touchUpInside)
                if self.dayFlags[index] { button.isSelected = true }
                stackView.addArrangedSubview(button)
            }
        } else {
            var tagCounter = 0
            stackView.spacing = (view.frame.width - 30 - 200) / 4
            let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .heavy))
            for (index, item) in items.enumerated() {
                guard let color = item as? UIColor else { return }
                if stackView == self.bottomColorsStackView && index == 0 { tagCounter = 5 }
                let button = FormingColorButton(color: color, tag: tagCounter, width: 40)
                button.setImage(UIImage(named: "checkmark", in: nil, with: config), for: .selected)
                button.addTarget(self, action: #selector(colorButtonTapped), for: .touchUpInside)
                if let color = self.selectedColor { if tagCounter == color { button.isSelected = true } }
                stackView.addArrangedSubview(button)
                tagCounter += 1
            }
        }
    }
    
    func configureConstraints() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let top = scrollView.topAnchor, left = scrollView.leftAnchor, right = scrollView.rightAnchor
        let labelHeight: CGFloat = 25, viewHeight: CGFloat = 40, outterPad: CGFloat = 15, innerPad: CGFloat = 5
        let viewWidth = view.frame.width - 30
        
        scrollView.addSubview(titleTextField)
        titleTextField.anchor(top: top, left: left, bottom: nil, right: right, paddingTop: outterPad, paddingLeft: outterPad, paddingBottom: 0, paddingRight: outterPad, width: viewWidth, height: viewHeight)
        
        scrollView.addSubview(daysStackView)
        daysStackView.anchor(top: titleTextField.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: outterPad + 5, paddingLeft: outterPad, paddingBottom: 0, paddingRight: outterPad, width: viewWidth, height: viewHeight)
        scrollView.addSubview(daySelectionLabel)
        daySelectionLabel.anchor(top: daysStackView.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: 0, paddingLeft: outterPad, paddingBottom: 0, paddingRight: outterPad, width: 0, height: labelHeight)

        scrollView.addSubview(topColorsStackView)
        topColorsStackView.anchor(top: daySelectionLabel.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: outterPad + 5, paddingLeft: outterPad, paddingBottom: 0, paddingRight: outterPad, width: 0, height: viewHeight)
        scrollView.addSubview(bottomColorsStackView)
        bottomColorsStackView.anchor(top: topColorsStackView.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: innerPad + 5, paddingLeft: outterPad, paddingBottom: 0, paddingRight: outterPad, width: 0, height: viewHeight)
        scrollView.addSubview(colorSelectionLabel)
        colorSelectionLabel.anchor(top: bottomColorsStackView.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: innerPad, paddingLeft: outterPad, paddingBottom: 0, paddingRight: outterPad, width: 0, height: labelHeight)

        if let tableView = formingTableView {
            scrollView.addSubview(tableView)
            tableView.anchor(top: colorSelectionLabel.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: outterPad, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 132)
        }

        if self.editMode {
            scrollView.addSubview(finishButton)
            finishButton.anchor(top: formingTableView?.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: outterPad * 2, paddingLeft: outterPad, paddingBottom: 0, paddingRight: outterPad, width: 0, height: 40)
        }

        view.addSubview(self.dateCreatedLabel)
        dateCreatedLabel.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: labelHeight)
    }
    
    // MARK: - Functions
    func set(habit: Habit) {
        self.habit = habit
        self.editMode = true
        self.titleTextField.text = habit.title
        self.dayFlags = habit.days
        self.selectedColor = Int(habit.color)
        self.colorFlags[Int(habit.color)] = true
        self.priority = habit.priority
        self.flag = habit.flag
        self.reminder = habit.reminder
        self.dateCreated = habit.dateCreated
    }
    
    // MARK: - Selectors
    @objc func saveButtonTapped() {
        if !self.dayFlags.contains(true) || !self.colorFlags.contains(true) {
            let alert = UIAlertController(title: "Incomplete Habit", message: "Please ensure that you have a color and at least one day selected.", preferredStyle: .alert)
            alert.view.tintColor = .systemGreen
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            present(alert, animated: true)
            return
        }
        
        DispatchQueue.main.async { self.dismiss(animated: true) }
        
        if !self.editMode {
            let initialHabit = Habit(context: self.persistenceManager.context)
            initialHabit.title = self.titleTextField.text?.trimmingCharacters(in: .whitespaces)
            initialHabit.days = self.dayFlags
            if let color = self.colorFlags.firstIndex(of: true) { initialHabit.color = Int64(color) }
            self.dayFlags.forEach {
                if $0 { self.dayStatuses.append(.incomplete) }
                else { self.dayStatuses.append(.empty) }
            }
            initialHabit.statuses = self.dayStatuses
            initialHabit.priority = self.priority
            initialHabit.reminder = self.reminder
            initialHabit.flag = self.flag
            initialHabit.dateCreated = CalUtility.getCurrentDate()
            initialHabit.buttonState = false
            initialHabit.uniqueID = UUID().uuidString
            
            let initialArchive = Archive(context: self.persistenceManager.context)
            initialArchive.title = initialHabit.title ?? "Error"
            initialArchive.color = initialHabit.color
            initialArchive.habit = initialHabit
            initialArchive.flag = initialHabit.flag
            initialArchive.priority = initialHabit.priority
            initialArchive.reminder = initialHabit.reminder
            initialArchive.active = true
            initialArchive.successRate = 100.0
            initialArchive.completedTotal = 0
            initialArchive.failedTotal = 0
            initialArchive.incompleteTotal = Int64(initialHabit.days.filter({ $0 == true }).count)
            initialArchive.currentWeekNumber = 1
            
            initialArchive.createNewArchivedHabit(withStatuses: initialHabit.statuses, andDate: CalUtility.getCurrentDate(), andDay: CalUtility.getCurrentDay())
            
            initialHabit.archive = initialArchive
            
            self.habitDelegate.add(habit: initialHabit)
        } else {
            self.habit?.title = self.titleTextField.text?.trimmingCharacters(in: .whitespaces)
            if let color = self.colorFlags.firstIndex(of: true) { self.habit?.color = Int64(color) }
            if self.dayFlags[CalUtility.getCurrentDay()] != self.habit?.days[CalUtility.getCurrentDay()] {
                if self.dayFlags[CalUtility.getCurrentDay()] { self.habit?.buttonState = false }
            }
            
            var deleteNotifications: (Bool, [Bool]) = (false, [])
            var updateNotifications = false
            if self.reminder == nil {
                let days = self.habit.days
                deleteNotifications = (true, days)
            } else if (self.reminder != self.habit?.reminder) || (self.dayFlags != self.habit?.days ) {
                let days = self.habit.days
                deleteNotifications = (true, days)
                updateNotifications = true
            }
            
            if self.habit?.days != self.dayFlags {
                for (index, day) in self.dayFlags.enumerated() {
                    if day {
                        switch self.habit?.statuses[index] {
                        case .completed: self.dayStatuses.append(.completed)
                        case .failed: self.dayStatuses.append(.failed)
                        case .incomplete: self.dayStatuses.append(.incomplete)
                        case .empty: self.dayStatuses.append(.incomplete)
                        default: ()
                        }
                    } else { self.dayStatuses.append(.empty) }
                }
                
                for (oldStatus, newStatus) in zip(self.habit.statuses, self.dayStatuses) {
                    self.habit?.archive.updateStats(fromStatus: oldStatus, toStatus: newStatus)
                }
                
                self.habit?.days = self.dayFlags
                self.habit?.statuses = self.dayStatuses
                self.habit?.archive.updateCurrentArchivedHabit(withStatuses: dayStatuses)
            }
            self.habit?.priority = self.priority
            self.habit?.reminder = self.reminder
            self.habit?.flag = self.flag
            
            self.habit?.archive.title = self.habit.title ?? "Title Error"
            self.habit?.archive.color = self.habit.color
            self.habit?.archive.flag = self.habit.flag
            self.habit?.archive.priority = self.habit.priority
            self.habit?.archive.reminder = self.habit.reminder
            self.habit?.archive.habit = self.habit
            
            self.habitDelegate.update(habit: self.habit, deleteNotifications: deleteNotifications, updateNotifications: updateNotifications)
        }
    }
    
    @objc func finishButtonTapped() {
        DispatchQueue.main.async {
            let deleteVC = UIAlertController(title: "Are you sure you want to finish this habit?",
                                             message: "Finishing a habit removes it from Habits and archives it in History.",
                                             preferredStyle: .alert)
            deleteVC.view.tintColor = .systemGreen
            deleteVC.addAction(UIAlertAction(title: "Finish", style: .default) { [weak self] _ in
                guard let self = self else { return }
                if let habitToDelete = self.habit {
                    self.habitDelegate.delete(habit: habitToDelete)
                    self.dismiss(animated: true)
                }
            })
            deleteVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(deleteVC, animated: true)
        }
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc func colorButtonTapped(sender: UIButton) {
        let tag = sender.tag
        if sender.isSelected == true { sender.isSelected = false }
        else {
            if self.colorFlags.contains(true) {
                if let index = self.colorFlags.firstIndex(of: true) {
                    if index < 5 {
                        let button = self.topColorsStackView.arrangedSubviews[index] as? UIButton
                        button?.isSelected = false
                    } else {
                        let button = self.bottomColorsStackView.arrangedSubviews[index - 5] as? UIButton
                        button?.isSelected = false
                    }
                    self.colorFlags[index] = false
                }
            }
            self.colorFlags[tag] = true
            DispatchQueue.main.async { self.haptics.selectionChanged() }
            sender.isSelected = true
        }
    }
    
    @objc func dayButtonTapped(sender: UIButton) {
        DispatchQueue.main.async { self.haptics.selectionChanged() }
        let tag = sender.tag
        if sender.isSelected == true {
            sender.isSelected = false
            self.dayFlags[tag] = false
        } else {
            sender.isSelected = true
            self.dayFlags[tag] = true
        }
    }
}

// MARK: - Delegates
extension HabitDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension HabitDetailViewController: FormingTableViewDelegate, SaveReminderDelegate {
    func push(view: UIViewController) {
        navigationController?.pushViewController(view, animated: true)
    }
    
    func save(priority: Int64) {
        self.priority = priority
    }
    
    func save(flag: Bool) {
        self.flag = flag
    }
    
    func save(reminder: Date?) {
        self.reminder = reminder
    }
}

// MARK: - Protocols
protocol HabitDetailDelegate  {
    func add(habit: Habit)
    func update(habit: Habit, deleteNotifications: (Bool, [Bool]), updateNotifications: Bool)
    func delete(habit: Habit)
}
