//
//  SettingsViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/20/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit
import SwiftUI
import StoreKit

class SettingsViewController: UIHostingController<SettingsSwiftUI> { }

class SettingsActions: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private var tipProducts: [Tip: SKProduct]?
    
    override init() {
        super.init()
        
        fetchProducts()
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: ["com.robertparsons4.Forming.099Tip",
                                                             "com.robertparsons4.Forming.299Tip",
                                                             "com.robertparsons4.Forming.499Tip"])
        request.delegate = self
        request.start()
    }
    
    func tipButtonTapped(tip: Tip) {
        switch tip {
        case .small: smallTip()
        case .medium: mediumTip()
        case .large: largeTip()
        }
    }
    
    private func smallTip() {
        print("small")
    }
    
    private func mediumTip() {
        print("medium")
    }
    
    private func largeTip() {
        print("large")
    }
    
    // MARK: Delegates
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        for product in response.products {
//
//        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing: ()
            case .purchased, .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            case .failed, .deferred:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            default:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            }
        }
    }
}

enum Tip: String {
    case small = "$0.99"
    case medium = "$2.99"
    case large = "$4.99"
}

struct SettingsSwiftUI: View {
    var actions = SettingsActions()
    
    var body: some View {
        NavigationView {
            List {
                Section(header:
                    VStack(spacing: 15) {
                        TipButton(action: self.actions,
                                  title: .small,
                                  message: "Thank you so much for your support!",
                                  leftMemoji: Memoji(imageName: "thumbsup-left"),
                                  rightMemoji: Memoji(imageName: "thumbsup-right"),
                                  backgroundColor: .systemBlue)
                        TipButton(action: self.actions,
                                  title: .medium,
                                  message: "You're awesome! Thank you so much!",
                                  leftMemoji: Memoji(imageName: "celebration-left"),
                                  rightMemoji: Memoji(imageName: "celebration-right"),
                                  backgroundColor: .systemPink)
                        TipButton(action: self.actions,
                                  title: .large,
                                  message: "Wow! I really appreciate it! Thank you!",
                                  leftMemoji: Memoji(imageName: "explosion-left"),
                                  rightMemoji: Memoji(imageName: "explosion-right"),
                                  backgroundColor: .systemOrange)
                    }.frame(width: UIScreen.main.bounds.width, height: (3 * 90) + (3 * 15), alignment: .top)) {
                        ListCell(image: Image("clock"), title: Text("Default Reminder Time"))
                        ListCell(image: Image("app.badge"), title: Text("Due Today Icon Badge"))
                        ListCell(image: Image(systemName: "faceid"), title: Text("Authentication"))
                }
            }.listStyle(GroupedListStyle())
                .environment(\.horizontalSizeClass, .regular)
                .navigationBarTitle(Text("Settings"))
        }
    }
}

struct TipButton: View {
    var action: SettingsActions
    
    let title: Tip
    let message: String
    let leftMemoji: Memoji
    let rightMemoji: Memoji
    let backgroundColor: UIColor
    
    var body: some View {
        Button(action: {
//            self.action.tipButtonTapped(tip: self.title)
        }) {
            HStack(spacing: 10) {
                leftMemoji
                VStack {
                    Text("\(self.title.rawValue) Tip")
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    Text(message)
                        .font(.system(size: 15, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .frame(width: 175, height: 50, alignment: .center)
                }
                rightMemoji
            }
        }.frame(width: UIScreen.main.bounds.width - 40, height: 90, alignment: .center)
            .background(Color(backgroundColor))
            .foregroundColor(Color(.label))
            .cornerRadius(14)
    }
}

struct Memoji: View {
    let imageName: String
    var body: some View {
        Image(imageName)
            .renderingMode(.original)
            .resizable()
            .frame(width: 65, height: 65, alignment: .center)
    }
}

struct ListCell: View {
    let image: Image
    let title: Text
    @State private var isOn = false
    
    var body: some View {
        HStack {
            image
            title
        }
    }
}

//struct SettingsSwiftUI_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//           SettingsSwiftUI()
//              .environment(\.colorScheme, .dark)
//
//           SettingsSwiftUI()
//              .environment(\.colorScheme, .light)
//        }
//    }
//}
