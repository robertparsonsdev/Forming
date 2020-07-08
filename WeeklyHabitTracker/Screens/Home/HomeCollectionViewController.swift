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

class HomeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private var habits = [Habit]()
    private let persistenceManager: PersistenceService
    private let defaults: UserDefaults
    private let notificationCenter: NotificationCenter
    private let userNotificationCenter: UNUserNotificationCenter
    private var dataSource: UICollectionViewDiffableDataSource<Section, Habit>!
    
    private let sortAC = UIAlertController(title: "Sort By:", message: nil, preferredStyle: .actionSheet)
    private let sortKey = "homeSort"
    private var defaultSort: HomeSort = .dateCreated
    
    private let searchController = UISearchController()
    private var filteredHabits = [Habit]()
        
    // MARK: - Initializers
    init(collectionViewLayout layout: UICollectionViewLayout, persistenceManager: PersistenceService, defaults: UserDefaults, userNotifCenter: UNUserNotificationCenter, notifCenter: NotificationCenter) {
        self.persistenceManager = persistenceManager
        self.defaults = defaults
        self.notificationCenter = notifCenter
        self.userNotificationCenter = userNotifCenter
        
        super.init(collectionViewLayout: layout)
        
        self.notificationCenter.addObserver(self, selector: #selector(reloadHabits), name: NSNotification.Name("newDay"), object: nil)
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
        let newButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newTapped))
        let sortButton = UIBarButtonItem(image: UIImage(named: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(sortButtonTapped))
        navigationItem.rightBarButtonItems = [newButton, sortButton]
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Notifications", style: .plain, target: self, action: #selector(notifications))
        if let sort = self.defaults.object(forKey: self.sortKey) { self.defaultSort = HomeSort(rawValue: sort as! String)! }
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout { layout.sectionHeadersPinToVisibleBounds = true }
        
        self.collectionView.register(HomeHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        self.collectionView.register(HabitCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        configureSearchController()
        configureSortAlertController()
        configureDataSource()
        
        fetchHabits()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadHabits()
    }
    
    @objc func notifications() {
        self.userNotificationCenter.getPendingNotificationRequests { (requests) in
            requests.forEach { (request) in
                print(request)
            }
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 30, height: 90)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
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
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    func configureSortAlertController() {
        sortAC.message = "Current sort: \(self.defaultSort.rawValue)"
        sortAC.view.tintColor = .systemGreen
        HomeSort.allCases.forEach { (sort) in
            sortAC.addAction(UIAlertAction(title: sort.rawValue, style: .default, handler: sortAlertTapped))
        }
        sortAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, Habit>(collectionView: self.collectionView, cellProvider: { (collectionView, indexPath, habit) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HabitCell
            cell.set(delegate: self)
            cell.set(habit: habit)
            return cell
        })
                
        self.dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! HomeHeaderCell
            return header
        }
    }
    
    // MARK: - Functions
    func updateDataSource(on habits: [Habit]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Habit>()
        if !self.habits.isEmpty {
            snapshot.appendSections([.main])
            snapshot.appendItems(habits)
            DispatchQueue.main.async {
                self.dataSource.apply(snapshot, animatingDifferences: true)
                self.removeEmptyStateView()
            }
        } else {
            snapshot.deleteSections([.main])
            DispatchQueue.main.async {
                self.dataSource.apply(snapshot, animatingDifferences: false)
                self.showEmptyStateView()
            }
        }
    }
    
    func fetchHabits() {
        self.habits = persistenceManager.fetch(Habit.self)
        if !self.habits.isEmpty {
            sortHabits()
        } else {
            updateDataSource(on: self.habits)
        }
    }
    
    func sortAlertTapped(sender: UIAlertAction) {
        if let sortTitle = sender.title {
            self.defaultSort = HomeSort(rawValue: sortTitle)!
            self.defaults.set(self.defaultSort.rawValue, forKey: self.sortKey)
            self.sortAC.message = "Current sort: \(self.defaultSort.rawValue)"
            guard !self.habits.isEmpty else { return }
            sortHabits()
        }
    }
    
    func sortHabits() {
        switch self.defaultSort {
        case .alphabetical: self.habits.sort { (hab1, hab2) -> Bool in hab1.title! < hab2.title! }
        case .color: self.habits.sort { (hab1, hab2) -> Bool in hab1.color < hab2.color }
        case .dateCreated: self.habits.sort { (hab1, hab2) -> Bool in hab1.dateCreated.compare(hab2.dateCreated) == .orderedAscending }
        case .dueToday: self.habits.sort { (hab1, hab2) -> Bool in hab1.statuses[CalUtility.getCurrentDay()] < hab2.statuses[CalUtility.getCurrentDay()] }
        case .flag: self.habits.sort { (hab1, hab2) -> Bool in hab1.flag && !hab2.flag}
        case .priority: self.habits.sort { (hab1, hab2) -> Bool in hab1.priority > hab2.priority }
        case .reminderTime: self.habits.sort { (hab1, hab2) -> Bool in
            let reminder1 = hab1.reminder ?? CalUtility.getFutureDate()
            let reminder2 = hab2.reminder ?? CalUtility.getFutureDate()
            return reminder1.compare(reminder2) == .orderedAscending
            }
        }
        updateDataSource(on: self.habits)
    }
    
    // MARK: - Selectors
    @objc func newTapped() {
        let newHabitVC = HabitDetailViewController(persistenceManager: persistenceManager, delegate: self)
        let navController = UINavigationController(rootViewController: newHabitVC)
        navController.navigationBar.tintColor = .systemGreen
        present(navController, animated: true)
    }
    
    @objc func sortButtonTapped() {
        present(sortAC, animated: true)
    }
    
    @objc func reloadHabits() {
        fetchHabits()
        DispatchQueue.main.async { self.collectionView.reloadData() }
    }
    
}

// MARK: - Delegates
extension HomeCollectionViewController: HabitDetailDelegate {
    func add(habit: Habit) {
        self.userNotificationCenter.createNotificationRequest(forHabit: habit)
        self.persistenceManager.save()
        self.habits.append(habit)
        sortHabits()
    }
    
    func update(habit: Habit, deleteNotifications: (Bool, [Bool]), updateNotifications: Bool) {
        if deleteNotifications.0 { self.userNotificationCenter.deleteNotificationRequests(forDays: deleteNotifications.1, andUniqueID: habit.uniqueID) }
        if updateNotifications { self.userNotificationCenter.createNotificationRequest(forHabit: habit) }
        self.persistenceManager.save()
        var snapshot = self.dataSource.snapshot()
        DispatchQueue.main.async {
            snapshot.reloadItems([habit])
            self.dataSource.apply(snapshot, animatingDifferences: true)
            self.sortHabits()
        }
    }
    
    func delete(habit: Habit) {
        self.userNotificationCenter.deleteNotificationRequests(forDays: habit.days, andUniqueID: habit.uniqueID)
        habit.archive.updateActive(toState: false)
        self.persistenceManager.delete(habit)
        if let index = self.habits.firstIndex(of: habit) {
            self.habits.remove(at: index)
            updateDataSource(on: self.habits)
        }
    }
}

extension HomeCollectionViewController: HabitCellDelegate {
    func presentNewHabitViewController(with habit: Habit) {
        let editHabitVC = HabitDetailViewController(persistenceManager: persistenceManager, delegate: self)
        editHabitVC.set(habit: habit)
        let navController = UINavigationController(rootViewController: editHabitVC)
        navController.navigationBar.tintColor = .systemGreen
        DispatchQueue.main.async { self.present(navController, animated: true) }
    }
    
    func checkboxSelectionChanged(atIndex index: Int, forHabit habit: Habit, fromStatus oldStatus: Status, toStatus newStatus: Status, forState state: Bool?) {
        habit.checkBoxPressed(fromStatus: oldStatus, toStatus: newStatus, atIndex: index, withState: state)
        self.persistenceManager.save()
    }
    
    func presentAlertController(with alert: UIAlertController) {
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

extension HomeCollectionViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text else { return }
        if filter.isEmpty { updateDataSource(on: self.habits); return }
        
        filteredHabits = self.habits.filter { ($0.title?.lowercased().contains(filter.lowercased()))! }
        updateDataSource(on: filteredHabits)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateDataSource(on: self.habits)
    }
}
