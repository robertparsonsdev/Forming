//
//  NewHabitViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/15/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class NewHabitViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    let scrollView = UIScrollView()

    let titleLabel = FormingTitleLabel(title: "Title:")
    let colorLabel = FormingTitleLabel(title: "Color:")
    let daysLabel = FormingTitleLabel(title: "Days:")
    let priorityLabel = FormingTitleLabel(title: "Priority:")
    
    let titleTextField = FormingTextField(placeholder: "Example: Run 1 Mile" ,returnKeyType: .done)
    
    let topColors = [UIColor.systemGreen, UIColor.systemTeal, UIColor.systemRed, UIColor.systemBlue, UIColor.systemGray]
    let bottomColors = [UIColor.systemPink, UIColor.systemIndigo, UIColor.systemOrange, UIColor.systemYellow, UIColor.systemPurple]
    let topColorsStackView = UIStackView()
    let bottomColorsStackView = UIStackView()
    
    let days = ["Su", "M", "T", "W", "Th", "F", "Sa"]
    let daysStackView = UIStackView()
    
    let priorityTextField = FormingTextField(placeholder: "Enter 1, 2, or 3", returnKeyType: .done)
    
    let tableView = UITableView()
    let toggle = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "New Habit"
        titleTextField.delegate = self
        priorityTextField.delegate = self
        
        configureScrollView()
        configureStackView(topColorsStackView, withArray: topColors)
        configureStackView(bottomColorsStackView, withArray: bottomColors)
        configureStackView(daysStackView, withArray: days)
        configureTableView()
        configureConstraints()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
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
            for item in items {
                let button = UIButton()
                guard let day = item as? String else { return }
                button.setTitle(day, for: .normal)
                button.setTitleColor(.label, for: .normal)
                stackView.addArrangedSubview(button)
            }
        } else {
            for item in items {
                guard let color = item as? UIColor else { return }
                stackView.spacing = (view.frame.width - 80 - 200) / 4
                stackView.addArrangedSubview(FormingColorButton(color: color, width: 40))
            }
        }
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    @objc func saveButtonTapped() {
        print("saved")
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    func configureConstraints() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        scrollView.addSubview(titleLabel)
        titleLabel.backgroundColor = .systemPurple
        titleLabel.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 15, paddingLeft: 15, paddingBottom: view.frame.height * 4/5, paddingRight: 15, width: 0, height: 0)
        scrollView.addSubview(titleTextField)
        titleTextField.anchor(top: titleLabel.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, paddingTop: 5, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: view.frame.width - 30, height: 40)

        scrollView.addSubview(colorLabel)
        colorLabel.anchor(top: titleLabel.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, paddingTop: 60, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 25)
        scrollView.addSubview(topColorsStackView)
        topColorsStackView.anchor(top: titleLabel.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, paddingTop: 90, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: view.frame.width - 80, height: 40)
        scrollView.addSubview(bottomColorsStackView)
        bottomColorsStackView.anchor(top: titleLabel.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, paddingTop: 140, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: view.frame.width - 80, height: 40)
        
        scrollView.addSubview(daysLabel)
        daysLabel.anchor(top: titleLabel.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, paddingTop: 195, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 25)
        scrollView.addSubview(daysStackView)
        daysStackView.anchor(top: titleLabel.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, paddingTop: 225, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: view.frame.width - 30, height: 40)
        
        scrollView.addSubview(priorityLabel)
        priorityLabel.anchor(top: titleLabel.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, paddingTop: 280, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 25)
        scrollView.addSubview(priorityTextField)
        priorityTextField.anchor(top: titleLabel.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, paddingTop: 310, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: view.frame.width - 30, height: 40)
        
        scrollView.addSubview(tableView)
        tableView.anchor(top: titleLabel.bottomAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, paddingTop: 365, paddingLeft: 15, paddingBottom: 15, paddingRight: 0, width: view.frame.width - 15, height: 100)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Sub-habits"
            cell.accessoryType = .disclosureIndicator
        default:
            cell.textLabel?.text = "Reminder"
            cell.accessoryView = toggle
            cell.selectionStyle = .none
        }
        return cell
    }
}
