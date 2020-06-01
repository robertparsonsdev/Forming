//
//  HomeCollectionViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

private let reuseIdentifier = "Habit Cell"
private let headerReuseIdentifier = "Header Cell"
private var currentSort: Sort?

class HomeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var habits = [Habit]()
    let persistenceManager: PersistenceService
    let defaults: UserDefaults
    let notificationCenter = NotificationCenter.default
    let userNotificationCenter = UNUserNotificationCenter.current()
    var dataSource: UICollectionViewDiffableDataSource<Section, Habit>!
    var currentDate: Date?
    let currentDateKey = "currentDate"
    var currentDay: Int?
    
    let sortAC = UIAlertController(title: "Sort By:", message: nil, preferredStyle: .actionSheet)
    var defaultSort: Sort = .dateCreated
    
    let searchController = UISearchController()
    var filteredHabits = [Habit]()
        
    // MARK: - Initializers
    init(collectionViewLayout layout: UICollectionViewLayout, persistenceManager: PersistenceService, defaults: UserDefaults) {
        self.persistenceManager = persistenceManager
        self.defaults = defaults
        if let sort = defaults.object(forKey: "sort") { self.defaultSort = Sort(rawValue: sort as! String)! }
        if let date = defaults.object(forKey: self.currentDateKey) { self.currentDate = date as? Date } else { self.currentDate = CalUtility.getCurrentDate() }
        self.currentDay = CalUtility.getCurrentDay()
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CollectionView Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newTapped))]
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout { layout.sectionHeadersPinToVisibleBounds = true }
        
        notificationCenter.addObserver(self, selector: #selector(updateCellsForDayChange), name: .NSCalendarDayChanged, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

        self.collectionView.register(HomeHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        self.collectionView.register(FinalHabitCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        configureSearchController()
        configureSortAlertController()
        
        configureDataSource()
        updateHabits()
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
    
    // MARK: - Configuration Functions
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Habit"
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(UIImage(named: "arrow.up.arrow.down"), for: .bookmark, state: .normal)
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    func configureSortAlertController() {
        sortAC.message = "Current sort: \(self.defaultSort.rawValue)"
        sortAC.view.tintColor = .systemGreen
        Sort.allCases.forEach { (sort) in
            sortAC.addAction(UIAlertAction(title: sort.rawValue, style: .default, handler: sortAlertTapped))
        }
        sortAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, Habit>(collectionView: self.collectionView, cellProvider: { (collectionView, indexPath, habit) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FinalHabitCell
            cell.set(delegate: self)
            if let currentDay = self.currentDay { cell.set(currentDay: currentDay) }
            else { cell.set(currentDay: CalUtility.getCurrentDay()) }
            cell.set(habit: habit)
            return cell
        })
                
        self.dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! HomeHeaderCell
            return header
        }
    }
    
    // MARK: - Functions
    func updateData(on habits: [Habit]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Habit>()
        snapshot.appendSections([.main])
        snapshot.appendItems(habits)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func updateHabits() {
        self.habits = persistenceManager.fetch(Habit.self)
        if habits.isEmpty {
            self.showEmptyStateView()
            return
        } else { self.removeEmptyStateView() }
        
        sortHabits()
    }
    
    func deleteHabit(_ habit: Habit) {
        persistenceManager.delete(habit)
        self.habits = persistenceManager.fetch(Habit.self)
        updateData(on: self.habits)
        
        if habits.isEmpty { self.showEmptyStateView() }
        else { sortHabits() }
    }
    
    func sortAlertTapped(sender: UIAlertAction) {
        if let sortTitle = sender.title {
            self.defaultSort = Sort(rawValue: sortTitle)!
            defaults.set(self.defaultSort.rawValue, forKey: "sort")
            sortAC.message = "Current sort: \(self.defaultSort.rawValue)"
            self.sortHabits()
        }
    }
    
    func sortHabits() {
        switch self.defaultSort {
        case .alphabetical: self.habits.sort { (hab1, hab2) -> Bool in hab1.title! < hab2.title! }
        case .dateCreated: self.habits.sort { (hab1, hab2) -> Bool in hab1.dateCreated.compare(hab2.dateCreated) == .orderedAscending }
        case .dueToday: self.habits.sort { (hab1, hab2) -> Bool in hab1.dueToday && !hab2.dueToday }
        case .priority: self.habits.sort { (hab1, hab2) -> Bool in hab1.priority > hab2.priority }
        case .reminderTime: self.habits.sort { (hab1, hab2) -> Bool in
            let reminder1 = hab1.reminder ?? CalUtility.getFutureDate()
            let reminder2 = hab2.reminder ?? CalUtility.getFutureDate()
            return reminder1.compare(reminder2) == .orderedAscending
            }
        }
        updateData(on: self.habits)
    }
    
    // MARK: - Selectors
    @objc func newTapped() {
        let newHabitVC = NewHabitViewController(persistenceManager: persistenceManager, notificationCenter: self.userNotificationCenter)
        newHabitVC.delegate = self
        let navController = UINavigationController(rootViewController: newHabitVC)
        navController.navigationBar.tintColor = .systemGreen
        present(navController, animated: true)
    }
    
    @objc func didBecomeActive() {
        if habits.count == 0 { return }
        if Calendar.current.isDateInToday(self.currentDate!) { return }
        updateCellsForDayChange(nil)
    }
    
    @objc func updateCellsForDayChange(_ calendarDayChanged: Notification?) {
        self.currentDate = CalUtility.getCurrentDate()
        self.currentDay = CalUtility.getCurrentDay()
        defaults.set(self.currentDate, forKey: self.currentDateKey)
        
        guard let currentDay = self.currentDay else { return }
        if currentDay == 0 {
            for (habitIndex, habit) in self.habits.enumerated() {
                if habit.statuses[6] == .incomplete { habit.statuses[6] = .failed }
                // save to archive persistence
                for (statusIndex, status) in habit.statuses.enumerated() {
                    if status != .empty { habit.statuses[statusIndex] = .incomplete }
                }
                self.habits[habitIndex] = habit
            }
        } else {
            for (index, habit) in self.habits.enumerated() {
                if habit.statuses[currentDay - 1] == .incomplete { habit.statuses[currentDay - 1] = .failed }
                if habit.statuses[currentDay] == .completed || habit.statuses[currentDay] == .failed { habit.buttonState = true }
                self.habits[index] = habit
            }
        }
        
        saveToPersistence(habit: self.habits[0])
        updateData(on: self.habits)
        DispatchQueue.main.async { self.collectionView.reloadData() }
    }
    
}

// MARK: - Delegates
extension HomeCollectionViewController: SaveHabitDelegate {
    func saveHabit() {
        self.updateHabits()
        collectionView.reloadData()
    }
    
    func delete(habit: Habit) {
        self.deleteHabit(habit)
    }
}

extension HomeCollectionViewController: HabitCellDelegate {
    func presentNewHabitViewController(with habit: Habit) {
        let newHabitVC = NewHabitViewController(persistenceManager: persistenceManager, notificationCenter: self.userNotificationCenter)
        newHabitVC.habit = habit
        newHabitVC.delegate = self
        let navController = UINavigationController(rootViewController: newHabitVC)
        navController.navigationBar.tintColor = .systemGreen
        DispatchQueue.main.async { self.present(navController, animated: true) }
    }
    
    func saveToPersistence(habit: Habit) {
        self.persistenceManager.save()
        habit.statuses.forEach { print($0.rawValue, terminator: " ") }
        print()
        userNotificationCenter.getPendingNotificationRequests { (results) in
            for result in results { print(result) }
        }
    }
    
    func presentAlertController(with alert: UIAlertController) {
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
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
        present(sortAC, animated: true)
    }
}
