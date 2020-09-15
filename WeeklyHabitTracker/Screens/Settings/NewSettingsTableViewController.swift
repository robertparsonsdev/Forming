//
//  NewSettingsTableViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 9/13/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit
import StoreKit

class NewSettingsTableViewController: UITableViewController {
    private let cellIdentifier = "settingsCellIdentifier"
    private let headerIdentifier = "settingsHeaderIdentifier"
    
    private var products = [SKProduct]()
    private let paymentQueue = SKPaymentQueue.default()
        
    // MARK: - Initializers
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(SettingsHeaderView.self, forHeaderFooterViewReuseIdentifier: self.headerIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        
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
            let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.headerIdentifier) as! SettingsHeaderView
            headerCell.set(delegate: self)
            return headerCell
        default: return UIView()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        cell = UITableViewCell(style: .value1, reuseIdentifier: self.cellIdentifier)
        cell.imageView?.tintColor = .label
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Default Reminder Time"
            cell.imageView?.image = UIImage(named: "clock")
            cell.detailTextLabel?.text = "9:00 AM"
        case 1:
            cell.textLabel?.text = "Due Today Badge"
            cell.imageView?.image = UIImage(named: "app.badge")
            cell.accessoryView = UISwitch()
            cell.selectionStyle = .none
        case 2:
            cell.textLabel?.text = "Show Tutorial"
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = UIImage(named: "info.circle")
            
        default: ()
        }
        return cell
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
        let payment = SKPayment(product: productToPurchase)
        self.paymentQueue.add(payment)
    }
}

// MARK: - Delegates
extension NewSettingsTableViewController: SettingsHeaderDelegate {
    func tipButtonTapped(product: IAPProduct) {
        switch product {
        case .smallTip: purchase(product: .smallTip)
        case .mediumTip: purchase(product: .mediumTip)
        case .largeTip: purchase(product: .largeTip)
        }
    }
}

extension NewSettingsTableViewController: SKProductsRequestDelegate {
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

extension NewSettingsTableViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
            
            switch transaction.transactionState {
            case .purchasing: break
            default: queue.finishTransaction(transaction); print("finished")
            }
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
