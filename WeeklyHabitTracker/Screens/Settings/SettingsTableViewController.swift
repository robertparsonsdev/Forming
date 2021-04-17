//
//  NewSettingsTableViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 9/13/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit
import StoreKit

private let cellIdentifier = "settingsCell"
private let headerIdentifier = "settingsHeader"

class SettingsTableViewController: UITableViewController {
    private var products = [SKProduct]()
    private let paymentQueue = SKPaymentQueue.default()
    
    private let notificationCenter: NotificationCenter
    private let defaults: UserDefaults
    private let userNotificationCenter: UNUserNotificationCenter
    
    private let reminderTextField = UITextField()
    private let reminderToolBar = UIToolbar()
    private let reminderSwitch = UISwitch()
    private let reminderPicker = UIDatePicker()
    private let badgeSwitch = UISwitch()
    private var activityViewController: ActivityViewController?
        
    // MARK: - Initializers
    init(notifCenter: NotificationCenter, defaults: UserDefaults, userNotifCenter: UNUserNotificationCenter) {
        self.notificationCenter = notifCenter
        self.defaults = defaults
        self.userNotificationCenter = userNotifCenter
        
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.tableView.register(SettingsHeaderView.self, forHeaderFooterViewReuseIdentifier: headerIdentifier)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        configureReminderPicker()
        configureBadgeSwitch()
        
        fetchProducts()
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
            let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as! SettingsHeaderView
            headerCell.set(delegate: self)
            return headerCell
        default: return UIView()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        cell.imageView?.tintColor = .label
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Default Reminder Time"
            cell.imageView?.image = UIImage(named: "clock")
            cell.selectionStyle = .none
            
            cell.addSubview(self.reminderTextField)
            self.reminderTextField.anchor(top: nil, left: cell.leftAnchor, bottom: nil, right: cell.rightAnchor, y: cell.centerYAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 22, width: 0, height: cell.frame.height)
        case 1:
            cell.textLabel?.text = "Due Today Badge"
            cell.imageView?.image = UIImage(named: "app.badge")
            cell.accessoryView = self.badgeSwitch
            cell.selectionStyle = .none
        case 2:
            cell.textLabel?.text = "Show Tutorial"
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = UIImage(named: "info.circle")
            
        default: ()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: print("reminder")
        default: break
        }
    }
    
    // MARK: - Configuration Functions
    func configureReminderPicker() {
        if let defaultReminder = self.defaults.object(forKey: Setting.defaultReminder.rawValue) as? Date? {
            if let reminder = defaultReminder {
                reminderTextField.text = CalUtility.getTimeAsString(time: reminder)
                reminderPicker.date = reminder
                self.reminderSwitch.isOn = true
            } else {
                reminderTextField.text = "None"
                reminderPicker.date = CalUtility.getTimeAsDate(time: "9:00 AM")!
                reminderPicker.isEnabled = false
                reminderSwitch.isOn = false
            }
        } else {
            reminderTextField.text = "9:00 AM"
            reminderPicker.date = CalUtility.getTimeAsDate(time: "9:00 AM")!
            reminderSwitch.isOn = true
        }
        
        reminderPicker.datePickerMode = .time
        reminderPicker.preferredDatePickerStyle = .wheels
        
        reminderToolBar.sizeToFit()
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(reminderSaveButtonTapped))
        saveButton.tintColor = .systemGreen
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(reminderCancelButtonTapped))
        cancelButton.tintColor = .systemGreen
        self.reminderSwitch.addTarget(self, action: #selector(reminderSwitchTapped), for: .valueChanged)
        let reminderSwitchButton = UIBarButtonItem(customView: reminderSwitch)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 10
        reminderToolBar.setItems([cancelButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), reminderSwitchButton, fixedSpace, saveButton], animated: true)
        
        reminderTextField.tintColor = .clear
        reminderTextField.textAlignment = .right
        reminderTextField.textColor = .secondaryLabel
        
        reminderTextField.inputView = reminderPicker
        reminderTextField.inputAccessoryView = reminderToolBar
    }
    
    func configureBadgeSwitch() {
        self.userNotificationCenter.getNotificationSettings { [weak self] (settings) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .denied, .notDetermined: self.badgeSwitch.isOn = false
                default: self.badgeSwitch.isOn = self.defaults.bool(forKey: Setting.badgeAppIcon.rawValue)
                }
            }
        }
        
        badgeSwitch.addTarget(self, action: #selector(badgeSwitchTapped), for: .valueChanged)
    }
    
    // MARK: - Functions
    private func fetchProducts() {
        let products: Set = [IAPProduct.smallTip.rawValue, IAPProduct.mediumTip.rawValue, IAPProduct.largeTip.rawValue]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        
        self.paymentQueue.add(self)
    }
    
    private func purchase(product: IAPProduct) {
        guard let productToPurchase = self.products.filter({ $0.productIdentifier == product.rawValue }).first else { return }
        self.activityViewController = ActivityViewController()
        self.activityViewController?.startAnimating()
        presentActivityViewController(self.activityViewController!)
        let payment = SKPayment(product: productToPurchase)
        self.paymentQueue.add(payment)
    }
    
    // MARK: - Selectors
    @objc func reminderSaveButtonTapped() {
        let reminderString: String
        if self.reminderSwitch.isOn {
            let reminder = self.reminderPicker.date
            reminderString = CalUtility.getTimeAsString(time: reminder)
            self.defaults.set(reminder, forKey: Setting.defaultReminder.rawValue)
        } else {
            reminderString = "None"
            self.reminderPicker.date = CalUtility.getTimeAsDate(time: "9:00 AM")!
            self.defaults.set(nil, forKey: Setting.defaultReminder.rawValue)
        }
        self.reminderTextField.text = reminderString
        
        self.tableView.endEditing(true)
    }
    
    @objc func reminderCancelButtonTapped() {
        self.tableView.endEditing(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let defaultReminder = self.defaults.object(forKey: Setting.defaultReminder.rawValue) as? Date? {
                if let reminder = defaultReminder {
                    self.reminderPicker.date = reminder
                    self.reminderPicker.isEnabled = true
                    self.reminderSwitch.isOn = true
                } else {
                    self.reminderPicker.date = CalUtility.getTimeAsDate(time: "9:00 AM")!
                    self.reminderPicker.isEnabled = false
                    self.reminderSwitch.isOn = false
                }
            }
        }
    }
    
    @objc func reminderSwitchTapped(sender: UISwitch) {
        self.reminderPicker.isEnabled = sender.isOn
    }
    
    @objc func badgeSwitchTapped(sender: UISwitch) {
        self.userNotificationCenter.getNotificationSettings { [weak self, weak sender] (settings) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .denied, .notDetermined:
                    let alertController = UIAlertController(title: "Notifications Disabled", message: "Notifications for Forming are currently disabled. You need to go to the Settings app and enable them.", preferredStyle: .alert)
                    alertController.view.tintColor = .systemGreen
                    alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: nil)
                        }
                    }))
                    alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                    self.present(alertController, animated: true)
                    sender?.isOn = false
                default:
                    let settingName = Setting.badgeAppIcon.rawValue
                    self.defaults.set(sender?.isOn, forKey: settingName)
                    self.notificationCenter.post(name: NSNotification.Name(rawValue: settingName), object: nil, userInfo: nil)
                }
            }
        }
    }
}

// MARK: - Delegates
extension SettingsTableViewController: SettingsHeaderDelegate {
    func tipButtonTapped(product: IAPProduct) {
        switch product {
        case .smallTip: purchase(product: .smallTip)
        case .mediumTip: purchase(product: .mediumTip)
        case .largeTip: purchase(product: .largeTip)
        }
    }
}

extension SettingsTableViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        
        for product in response.products {
            print(product.localizedTitle)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension SettingsTableViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
            
            switch transaction.transactionState {
            case .purchasing: break
            default: queue.finishTransaction(transaction); print("finished")
            }
        }
        
        if let activityVC = self.activityViewController {
            dismissActivityViewController(activityVC)
        }
    }
}

extension SKPaymentTransactionState {
    func status() -> String {
        switch self {
        case .deferred: return "deferred"
        case .failed: return "failed"
        case .purchased: return "purchaed"
        case .purchasing: return "purchasing"
        case .restored: return "restored"
        default: return "error"
        }
    }
}
