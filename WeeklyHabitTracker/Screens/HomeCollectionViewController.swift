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
private var currentSort: Sorting?

class HomeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var habits = [Habit]()
    let persistenceManager: PersistenceService
    var dataSource: UICollectionViewDiffableDataSource<Section, Habit>!
    var defaults = UserDefaults.standard
    let key = "sort"
    
    let searchController = UISearchController()
    var filteredHabits = [Habit]()
    var isSearching = false
    
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

        self.collectionView.register(HomeHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        self.collectionView.register(HabitCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        configureSearchController()
        updateHabits()
        configureDataSource()
    }
    
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, Habit>(collectionView: self.collectionView, cellProvider: { (collectionView, indexPath, habit) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HabitCell
            cell.habit = habit
            cell.delegate = self
            cell.persistenceManager = self.persistenceManager
            return cell
        })
                
        self.dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! HomeHeaderCell
            return header
        }
    }
    
    func updateData(on habits: [Habit]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Habit>()
        snapshot.appendSections([.main])
        snapshot.appendItems(habits)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Habit"
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(UIImage(named: "arrow.up.arrow.down"), for: .bookmark, state: .normal)
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    func updateHabits() {
        self.habits = persistenceManager.fetch(Habit.self)
        if habits.isEmpty {
            print("empty")
            return
        }
        // sortHabits(on: currentSort)
        updateData(on: self.habits)
    }
    
    @objc func newTapped() {
        let newHabitVC = NewHabitViewController(persistenceManager: persistenceManager)
        newHabitVC.delegate = self
        let navController = UINavigationController(rootViewController: newHabitVC)
        navController.navigationBar.tintColor = .systemGreen
        present(navController, animated: true)
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

extension HomeCollectionViewController: HabitCellDelegate, SaveHabitDelegate {
    func presentNewHabitViewController(with habit: Habit) {
        let newHabitVC = NewHabitViewController(persistenceManager: persistenceManager)
        newHabitVC.habit = habit
        newHabitVC.delegate = self
        let navController = UINavigationController(rootViewController: newHabitVC)
        navController.navigationBar.tintColor = .systemGreen
        DispatchQueue.main.async { self.present(navController, animated: true) }
    }
    
    func presentAlertController(with alert: UIAlertController) {
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func saveHabit() {
        self.updateHabits()
    }
}

extension HomeCollectionViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text else { return }//, !filter.isEmpty else { return }
        if filter.isEmpty { updateData(on: self.habits); return }
        
        filteredHabits = self.habits.filter { ($0.title?.lowercased().contains(filter.lowercased()))! }
        updateData(on: filteredHabits)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateData(on: self.habits)
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let alertController = UIAlertController(title: "Sort By:", message: "Current sort: ", preferredStyle: .actionSheet)
//        alertController.message =
        alertController.view.tintColor = .systemGreen
        alertController.addAction(UIAlertAction(title: "Alphabetically", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Due Today", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Priority", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Reminder Time", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Default", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }
    
//    func sortHabits(sender: UIAlertAction) {
//        switch sender.title {
//        case "Alphabetically":
//            self.habits.sort { (hab1, hab2) -> Bool in hab1.title! < hab2.title! }
//            self.updateData(on: self.habits)
//            currentSort = .alphabetical
//        case "Due Today":
//
//            currentSort = .dueToday
//        case "Priority":
//            self.habits.sort { (hab1, hab2) -> Bool in hab1.priority < hab2.priority }
//            self.updateData(on: self.habits)
//            currentSort = .priority
//        case "Reminder Time":
//
//            currentSort = .reminderTime
//        case "Default":
//            print(currentSort)
//            currentSort = nil
//        default: ()
//        }
//        print("sorte:", currentSort)
//        defaults.set(currentSort, forKey: key)
//        self.updateData(on: self.habits)
//    }
}
