//
//  MainTabBarController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit
import UserNotifications

class MainTabBarController: UITabBarController {
    let persistenceManager = PersistenceService.shared
    let userNotificationCenter = UNUserNotificationCenter.current()
    let notificationCenter = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = .systemGreen
        setUpViewControllers()
        
//        userNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
//            if granted { print("granted") }
//            else { print("not granted") }
//        }
    }

    fileprivate func setUpViewControllers() {
        let boldConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .bold))
        let homeNavController = buildTabBarControllers(withTitle: "Habits", andImage: UIImage(named: "checkmark", in: nil, with: boldConfig)!, andRootVC: HomeCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout(), persistenceManager: self.persistenceManager, defaults: UserDefaults.standard, userNotifCenter: self.userNotificationCenter, notifCenter: self.notificationCenter))
        let historyNavController = buildTabBarControllers(withTitle: "History", andImage: UIImage(named: "arrow.counterclockwise", in: nil, with: boldConfig)!, andRootVC: HistoryCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout(), persistenceManager: self.persistenceManager, notifCenter: self.notificationCenter))
        let settingsNavController = buildTabBarControllers(withTitle: "Settings", andImage: UIImage(named: "gear", in: nil, with: boldConfig)!, andRootVC: SettingsViewController())
        viewControllers = [homeNavController, historyNavController, settingsNavController]
    }
        
    fileprivate func buildTabBarControllers(withTitle title: String, andImage image: UIImage, andRootVC vc: UIViewController = UIViewController()) -> UINavigationController {
        vc.title = title
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.navigationBar.tintColor = .systemGreen
        return navController
    }
}
