//
//  NewHabitViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/15/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class NewHabitViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    var update: (() -> Void)?
    
    let scrollView = UIScrollView()

    let titleLabel = FormingTitleLabel(title: "Title:")
    let colorLabel = FormingTitleLabel(title: "Color:")
    let daysLabel = FormingTitleLabel(title: "Days:")
    let priorityLabel = FormingTitleLabel(title: "Priority:")
    
    let titleTextField = FormingTextField(placeholder: "Example: Run 1 Mile" , returnKeyType: .done)
    
    let topColors = [UIColor.systemGreen, UIColor.systemTeal, UIColor.systemRed, UIColor.systemBlue, UIColor.systemGray]
    let bottomColors = [UIColor.systemPink, UIColor.systemIndigo, UIColor.systemOrange, UIColor.systemYellow, UIColor.systemPurple]
    let topColorsStackView = UIStackView()
    let bottomColorsStackView = UIStackView()
    var colorFlags = [false, false, false, false, false, false, false, false, false, false]
    
    let days = ["Su", "M", "T", "W", "Th", "F", "Sa"]
    var dayFlags = [false, false, false, false, false, false, false]
    let daysStackView = UIStackView()
        
    let tableView = UITableView()
    let toggle = UISwitch()
    let stepper = UIStepper()
    let haptics = UISelectionFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "New Habit"
        titleTextField.delegate = self
        
        configureScrollView()
        configureStackView(topColorsStackView, withArray: topColors)
        configureStackView(bottomColorsStackView, withArray: bottomColors)
        configureStackView(daysStackView, withArray: days)
        configureStepper()
        configureTableView()
        configureConstraints()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
    }
    
    @objc func saveButtonTapped() {
        if !dayFlags.contains(true) || !colorFlags.contains(true) {
            let alert = UIAlertController(title: "Incomplete Habit", message: "Please ensure that you have a color and at least one day selected.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            present(alert, animated: true)
            return
        }
        // save habit information to device
        if let count = UserDefaults().value(forKey: "count") as? Int {
            UserDefaults().set(titleTextField.text, forKey: "habitTitle_\(count)")
            UserDefaults().set(count + 1, forKey: "count")
        }
        update?()
        dismiss(animated: true)
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    func configureScrollView() {
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
    }
    
    func configureStackView(_ stackView : UIStackView, withArray items: [Any]) {
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        if items as? [String] == days {
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
                stackView.addArrangedSubview(button)
            }
        } else {
            var tagCounter = 0
            stackView.spacing = (view.frame.width - 80 - 200) / 4
            let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .heavy))
            for (index, item) in items.enumerated() {
                guard let color = item as? UIColor else { return }
                if stackView == bottomColorsStackView && index == 0 { tagCounter = 5 }
                let button = FormingColorButton(color: color, tag: tagCounter, width: 40)
                button.setImage(UIImage(named: "checkmark", in: nil, with: config), for: .selected)
                button.addTarget(self, action: #selector(colorButtonTapped), for: .touchUpInside)
                stackView.addArrangedSubview(button)
                tagCounter += 1
            }
        }
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func configureConstraints() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let top = scrollView.topAnchor, left = scrollView.leftAnchor, right = scrollView.rightAnchor
        let labelHeight: CGFloat = 25, viewHeight: CGFloat = 40, outterPad: CGFloat = 15, innerPad: CGFloat = 5
        let viewWidth = view.frame.width - 30
        
        scrollView.addSubview(titleLabel)
        titleLabel.anchor(top: top, left: left, bottom: nil, right: right, paddingTop: outterPad, paddingLeft: outterPad, paddingBottom: 0, paddingRight: outterPad, width: 0, height: labelHeight)
        scrollView.addSubview(titleTextField)
        titleTextField.anchor(top: titleLabel.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: innerPad, paddingLeft: outterPad, paddingBottom: 0, paddingRight: outterPad, width: viewWidth, height: viewHeight)
        
        scrollView.addSubview(daysLabel)
        daysLabel.anchor(top: titleTextField.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: outterPad, paddingLeft: outterPad, paddingBottom: 0, paddingRight: outterPad, width: 0, height: labelHeight)
        scrollView.addSubview(daysStackView)
        daysStackView.anchor(top: daysLabel.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: innerPad, paddingLeft: outterPad, paddingBottom: 0, paddingRight: outterPad, width: viewWidth, height: viewHeight)

        scrollView.addSubview(colorLabel)
        colorLabel.anchor(top: daysStackView.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: outterPad, paddingLeft: outterPad, paddingBottom: 0, paddingRight: outterPad, width: 0, height: labelHeight)
        scrollView.addSubview(topColorsStackView)
        topColorsStackView.anchor(top: colorLabel.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: innerPad, paddingLeft: outterPad + 25, paddingBottom: 0, paddingRight: outterPad + 25, width: viewWidth - 50, height: viewHeight)
        scrollView.addSubview(bottomColorsStackView)
        bottomColorsStackView.anchor(top: topColorsStackView.bottomAnchor, left: left, bottom: nil, right: right, paddingTop: innerPad + 5, paddingLeft: outterPad + 25, paddingBottom: 0, paddingRight: outterPad + 25, width: viewWidth - 50, height: viewHeight)

        scrollView.addSubview(tableView)
        tableView.anchor(top: bottomColorsStackView.bottomAnchor, left: left, bottom: nil, right: nil, paddingTop: outterPad, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: viewWidth + 30, height: 140)
    }
    
    func configureStepper() {
        stepper.minimumValue = 0
        stepper.maximumValue = 3
        stepper.addTarget(self, action: #selector(stepperTapped), for: .valueChanged)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        cell.imageView?.tintColor = .label
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Sub-habits"
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = UIImage(named: "list.bullet.indent")
        case 1:
            cell.textLabel?.text = "Priority"
            cell.detailTextLabel?.text = "0"
            cell.imageView?.image = UIImage(named: "exclamationmark.circle")
            cell.accessoryView = stepper
            cell.selectionStyle = .none
        default:
            cell.textLabel?.text = "Reminder"
            cell.imageView?.image = UIImage(named: "clock")
            cell.accessoryView = toggle
            cell.selectionStyle = .none
        }
        return cell
    }
    
    @objc func colorButtonTapped(sender: UIButton) {
        let tag = sender.tag
        if sender.isSelected == true { sender.isSelected = false }
        else {
            if colorFlags.contains(true) {
                if let index = colorFlags.firstIndex(of: true) {
                    if index < 5 {
                        let button = topColorsStackView.arrangedSubviews[index] as? UIButton
                        button?.isSelected = false
                    } else {
                        let button = bottomColorsStackView.arrangedSubviews[index - 5] as? UIButton
                        button?.isSelected = false
                    }
                    colorFlags[index] = false
                }
            }
            colorFlags[tag] = true
            haptics.selectionChanged()
            sender.isSelected = true
        }
    }
    
    @objc func dayButtonTapped(sender: UIButton) {
        haptics.selectionChanged()
        let tag = sender.tag
        if sender.isSelected == true {
            sender.isSelected = false
            dayFlags[tag] = false
        } else {
            sender.isSelected = true
            dayFlags[tag] = true
        }
    }
    
    @objc func stepperTapped(sender: UIStepper) {
        haptics.selectionChanged()
        tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.detailTextLabel?.text = String(Int(sender.value))
    }
}
