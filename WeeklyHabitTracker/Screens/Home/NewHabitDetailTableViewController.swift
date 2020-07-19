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
    
    private var habitTitle: String?
    private var habitDays: [Bool] = [false, false, false, false, false, false, false]
    private var habitColor: Int64?
    private var habitGoal: Int64? = nil
    private var habitTracking: Bool = true
    private var habitPriority: Int64 = 0
    private var habitFlag: Bool = false
    private var habitReminder: Date? = CalUtility.getTimeAsDate(time: "9:00 AM")
    private var habitDateCreated: Date = CalUtility.getCurrentDate()
    
    private let priorityStepper = UIStepper()
    private let flagSwitch = UISwitch()
    
    private let haptics = UISelectionFeedbackGenerator()
    private let regularConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 15, weight: .regular), scale: .default)
    private let largeConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17), scale: .large)
    private let exclamationAttachment = NSTextAttachment()
    
    // MARK: - Initializers
    init(persistenceManager: PersistenceService, delegate: HabitDetailDelegate, habitToEdit: Habit? = nil) {
        self.persistenceManager = persistenceManager
        self.habitDelegate = delegate
        if let editingHabit = habitToEdit {
            self.habit = editingHabit
            self.editMode = true
            self.habitTitle = editingHabit.title
            self.habitDays = editingHabit.days
            self.habitColor = editingHabit.color
//            self.habitGoal =
//            self.habitTracking =
            self.habitPriority = editingHabit.priority
            self.habitFlag = editingHabit.flag
            self.habitReminder = editingHabit.reminder
        } else {
            self.editMode = false
        }
        
        self.exclamationAttachment.image = UIImage(named: "exclamationmark", in: nil, with: regularConfig)
        self.exclamationAttachment.image = exclamationAttachment.image?.withTintColor(.secondaryLabel)
        
        super.init(style: .insetGrouped)
        
        configureStepper()
        configureFlagSwitch()
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case SectionNumber.firstSection.rawValue: return 300
        default: return 20
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case SectionNumber.firstSection.rawValue:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.headerReuseIdentifier) as! HabitDetailHeader
            header.set(delegate: self)
            if self.editMode {
                header.set(title: self.habit.title)
                header.set(days: self.habit.days)
                header.set(color: self.habit.color)
            }
            return header
        default: return UIView()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SectionNumber.firstSection.rawValue: return FirstSection.allCases.count
        default: return SecondSection.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
        cell = UITableViewCell(style: .value1, reuseIdentifier: self.cellReuseIdentifier)
        cell.imageView?.tintColor = .label
        switch indexPath.section {
        case SectionNumber.firstSection.rawValue:
            switch indexPath.row {
            case FirstSection.goal.rawValue:
                cell.textLabel?.text = "Goal"
                cell.imageView?.image = UIImage(named: "star.circle", in: nil, with: self.largeConfig)
                cell.detailTextLabel?.text = "Never-ending"
                cell.accessoryType = .disclosureIndicator
            case FirstSection.automaticTracking.rawValue:
                cell.textLabel?.text = "Automatic Tracking"
                cell.imageView?.image = UIImage(named: "xmark.circle", in: nil, with: self.largeConfig)
                cell.detailTextLabel?.text = "On"
                cell.accessoryType = .disclosureIndicator
            default: ()
            }
        case SectionNumber.secondSection.rawValue:
            switch indexPath.row {
            case SecondSection.reminder.rawValue:
                cell.textLabel?.text = "Reminder"
                if let reminder = self.habitReminder { cell.detailTextLabel?.text = CalUtility.getTimeAsString(time: reminder) }
                else { cell.detailTextLabel?.text = "None" }
                cell.imageView?.image = UIImage(named: "clock", in: nil, with: self.largeConfig)
                cell.accessoryType = .disclosureIndicator
            case SecondSection.priority.rawValue:
                cell.textLabel?.text = "Priority"
                cell.detailTextLabel?.attributedText = createExclamation(fromPriority: self.habitPriority)
                cell.imageView?.image = UIImage(named: "exclamationmark.circle", in: nil, with: self.largeConfig)
                cell.accessoryView = self.priorityStepper
                cell.selectionStyle = .none
            case SecondSection.flag.rawValue:
                cell.textLabel?.text = "Flag"
                cell.imageView?.image = UIImage(named: "flag.circle", in: nil, with: self.largeConfig)
                cell.accessoryView = self.flagSwitch
                cell.selectionStyle = .none
            default: ()
            }
        default: ()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SectionNumber.firstSection.rawValue:
            switch indexPath.row {
            case FirstSection.goal.rawValue:
                let goalView = GoalViewController(goal: 0)
//                goalView.setUpdateDelegate(delegate: self)
                if let parentView = tableView.findViewController() as? HabitDetailViewController {
                    goalView.setSaveDelegate(delegate: parentView.self)
                }
                self.navigationController?.pushViewController(goalView, animated: true)
            case FirstSection.automaticTracking.rawValue: print("tracking")
            default: ()
            }
        case SectionNumber.secondSection.rawValue:
            if indexPath.row == SecondSection.reminder.rawValue {
                let reminderView = ReminderViewController(reminder: self.habitReminder)
//                reminderView.setUpdateDelegate(delegate: self)
                if let parentView = tableView.findViewController() as? HabitDetailViewController {
                    reminderView.setSaveDelegate(delegate: parentView.self)
                }
                self.navigationController?.pushViewController(reminderView, animated: true)
            }
        default: ()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Configuration Functions
    func configureStepper() {
        priorityStepper.minimumValue = 0
        priorityStepper.maximumValue = 3
        priorityStepper.value = Double(self.habitPriority)
        priorityStepper.addTarget(self, action: #selector(stepperTapped), for: .valueChanged)
    }
    
    func configureFlagSwitch() {
        flagSwitch.isOn = self.habitFlag
        flagSwitch.addTarget(self, action: #selector(flagSwitchTapped), for: .valueChanged)
    }
    
    // MARK: - Functions
    func presentAlert() {
        let alert = UIAlertController(title: "Incomplete Habit", message: "Please ensure that you have a color and at least one day selected.", preferredStyle: .alert)
        alert.view.tintColor = .systemGreen
        alert.addAction(UIAlertAction(title: "Okay", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func createExclamation(fromPriority num: Int64) -> NSAttributedString {
        let attrString = NSMutableAttributedString()
        switch num {
        case 1:
            attrString.append(NSAttributedString(attachment: self.exclamationAttachment))
            attrString.append(NSAttributedString(string: "           "))
        case 2:
            attrString.append(NSAttributedString(attachment: self.exclamationAttachment))
            attrString.append(NSAttributedString(attachment: self.exclamationAttachment))
            attrString.append(NSAttributedString(string: "           "))
        case 3:
            attrString.append(NSAttributedString(attachment: self.exclamationAttachment))
            attrString.append(NSAttributedString(attachment: self.exclamationAttachment))
            attrString.append(NSAttributedString(attachment: self.exclamationAttachment))
            attrString.append(NSAttributedString(string: "           "))
        default:
            attrString.append(NSAttributedString(string: "None"))
        }
        return attrString
    }
    
    func saveHabitData() {
        self.habit.title = self.habitTitle
        self.habit.days = self.habitDays
        self.habit.color = self.habitColor!
        
        if self.editMode {
            
        } else {
            var statuses = [Status]()
            for day in self.habit.days {
                if day {
                    statuses.append(.incomplete)
                } else {
                    statuses.append(.empty)
                }
            }
            self.habit.statuses = statuses
        }
    }
    
    // MARK: - Selectors
    @objc func saveButtonTapped() {
        guard !self.habitDays.allSatisfy( { $0 == false } ), self.habitColor != nil else {
            self.presentAlert()
            return
        }
        
        if self.editMode {
            saveHabitData()
            self.habitDelegate.update(habit: self.habit, deleteNotifications: (false, [false]), updateNotifications: false)
        } else {
            self.habit = Habit(context: self.persistenceManager.context)
            saveHabitData()
            self.habitDelegate.add(habit: self.habit)
        }
        
        DispatchQueue.main.async { self.dismiss(animated: true) }
    }
    
    @objc func finishButtonTapped() {
        DispatchQueue.main.async { self.dismiss(animated: true) }
    }
    
    @objc func cancelButtonTapped() {
        DispatchQueue.main.async { self.dismiss(animated: true) }
    }
    
    @objc func stepperTapped(sender: UIStepper) {
        self.haptics.selectionChanged()
        tableView.cellForRow(at: IndexPath(row: SecondSection.priority.rawValue, section: SectionNumber.secondSection.rawValue))?.detailTextLabel?.attributedText = createExclamation(fromPriority: Int64(sender.value))
        self.habitPriority = Int64(sender.value)
    }
    
    @objc func flagSwitchTapped(sender: UISwitch) {
        self.haptics.selectionChanged()
        self.habitFlag = sender.isOn
    }
}

// MARK: - Delegates
extension NewHabitDetailTableViewController: HabitDetailHeaderDelegate {
    func send(title: String?) {
        self.habitTitle = title
    }
    
    func send(day: Int, andFlag flag: Bool) {
        self.habitDays[day] = flag
    }
    
    func send(color: Int64?) {
        self.habitColor = color
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
