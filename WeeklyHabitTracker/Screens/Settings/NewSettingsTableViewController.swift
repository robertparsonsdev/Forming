//
//  NewSettingsTableViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 9/13/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class NewSettingsTableViewController: UITableViewController {
    private let cellIdentifier = "settingsCellIdentifier"
    private let headerIdentifier = "settingsHeaderIdentifier"
        
    // MARK: - Initializers
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(SettingsHeaderView.self, forHeaderFooterViewReuseIdentifier: self.headerIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 300
        default: return 20
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.headerIdentifier) as! SettingsHeaderView
            return headerCell
        default: return UIView()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)

        return cell
    }
}

// MARK: - Delegates
extension NewSettingsTableViewController: SettingsHeaderDelegate {
    func tipButtonTapped() {
        
    }
}
