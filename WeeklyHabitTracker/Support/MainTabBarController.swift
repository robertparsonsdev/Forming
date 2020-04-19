//
//  MainTabBarController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = .systemGreen
        setUpViewControllers()
    }

    fileprivate func setUpViewControllers() {
        let heavyConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 17, weight: .bold))
        let homeNavController = buildTabBarControllers(withTitle: "Habits", andImage: UIImage(named: "checkmark", in: nil, with: heavyConfig)!, andRootVC: HomeCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        let historyNavController = buildTabBarControllers(withTitle: "History", andImage: UIImage(named: "arrow.counterclockwise", in: nil, with: heavyConfig)!, andRootVC: HistoryCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        viewControllers = [homeNavController, historyNavController]
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
