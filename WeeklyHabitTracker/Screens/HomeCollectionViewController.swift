//
//  HomeCollectionViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Habit Cell"
private let headerReuseIdentifier = "Header Cell"

class HomeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var habits: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newTapped))]

        // Register cell classes
        self.collectionView.register(HomeHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        self.collectionView!.register(HabitCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        if !UserDefaults().bool(forKey: "setup") {
            UserDefaults().set(true, forKey: "setup")
            UserDefaults().set(0, forKey: "count")
        }
        guard let count = UserDefaults().value(forKey: "count") as? Int else { return }
        for index in 0..<count {
            UserDefaults().removeObject(forKey: "habitTitle_\(index)")
        }
        updateHabits()
    }
    
    func updateHabits() {
        // add to list of habits and reload the collection view
        habits.removeAll()
        guard let count = UserDefaults().value(forKey: "count") as? Int else { return }
        for index in 0..<count {
            if let habitTitle = UserDefaults().value(forKey: "habitTitle_\(index)") as? String {
                habits.append(habitTitle)
            }
        }
        collectionView.reloadData()
    }
    
    @objc func newTapped() {
        let newHabitVC = NewHabitViewController()
        newHabitVC.update = {
            DispatchQueue.main.async { self.updateHabits() }
        }
        let navController = UINavigationController(rootViewController: newHabitVC)
        navController.navigationBar.tintColor = .systemGreen
        present(navController, animated: true)
    }

    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! HomeHeaderCell
        return header
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return habits.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HabitCell
        cell.habitTitle = habits[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 30, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
    }
}
