//
//  HomeCollectionViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Habit Cell"
private let headerReuseIdentifier = "Header Cell"
private let emptyReuseIdentifier = "Empty Cell"

class HomeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HabitCellDelegate {
    var habits = [Habit]()
    let persistenceManager: PersistenceService
    let search = UISearchController()
    
    init(collectionViewLayout layout: UICollectionViewLayout, persistenceManager: PersistenceService) {
        self.persistenceManager = persistenceManager
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newTapped))]
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout { layout.sectionHeadersPinToVisibleBounds = true }

        // Register cell classes
        self.collectionView.register(HomeHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        self.collectionView.register(HabitCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(EmptyScreenCell.self, forCellWithReuseIdentifier: emptyReuseIdentifier)
        
        configureSearchController()
        updateHabits()
    }
    
    func configureSearchController() {
        search.searchBar.placeholder = "Search for Habit"
        search.searchBar.showsBookmarkButton = true
        search.searchBar.setImage(UIImage(named: "arrow.up.arrow.down"), for: .bookmark, state: .normal)
        navigationItem.searchController = search
    }
    
    func updateHabits() {
        self.habits = persistenceManager.fetch(Habit.self)
        self.collectionView.reloadData()
    }
    
    @objc func newTapped() {
        let newHabitVC = NewHabitViewController(persistenceManager: persistenceManager)
        newHabitVC.update = { DispatchQueue.main.async { self.updateHabits() } }
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
        return habits.isEmpty ? 1 : habits.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if habits.isEmpty { return collectionView.dequeueReusableCell(withReuseIdentifier: emptyReuseIdentifier, for: indexPath) as! EmptyScreenCell }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HabitCell
        cell.habit = habits[indexPath.row]
        cell.delegate = self
        cell.persistenceManager = self.persistenceManager
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
    
    func presentNewHabitViewController(with habit: Habit) {
        let newHabitVC = NewHabitViewController(persistenceManager: persistenceManager)
        newHabitVC.habit = habit
        newHabitVC.update = { DispatchQueue.main.async { self.updateHabits() } }
        let navController = UINavigationController(rootViewController: newHabitVC)
        navController.navigationBar.tintColor = .systemGreen
        present(navController, animated: true)
    }
}
