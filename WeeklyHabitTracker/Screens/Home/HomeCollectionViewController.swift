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
// test commit again

class HomeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private var habits = [Habit]()
    private let persistence: PersistenceService
    private let defaults: UserDefaults
    private let notificationCenter: NotificationCenter
    private let userNotificationCenter: UNUserNotificationCenter
    private var dataSource: UICollectionViewDiffableDataSource<Section, Habit>!
    private var currentDay: Int?
    
    private let sortAC = UIAlertController(title: "Sort By:", message: nil, preferredStyle: .actionSheet)
    private var defaultSort: Sort = .dateCreated
    
    private let searchController = UISearchController()
    private var filteredHabits = [Habit]()
        
    // MARK: - Initializers
    init(collectionViewLayout layout: UICollectionViewLayout, persistenceManager: PersistenceService, defaults: UserDefaults, userNotifCenter: UNUserNotificationCenter, notifCenter: NotificationCenter) {
        self.persistence = persistenceManager
        self.defaults = defaults
        self.notificationCenter = notifCenter
        self.userNotificationCenter = userNotifCenter
        if let sort = defaults.object(forKey: "sort") { self.defaultSort = Sort(rawValue: sort as! String)! }
        self.currentDay = CalUtility.getCurrentDay()
        
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
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout { layout.sectionHeadersPinToVisibleBounds = true }
        
        self.collectionView.register(HomeHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        self.collectionView.register(HabitCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        configureSearchController()
        configureSortAlertController()
        
        configureDataSource()
        fetchHabits()
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
        Sort.allCases.forEach { (sort) in
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
        snapshot.appendSections([.main])
        snapshot.appendItems(habits)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func fetchHabits() {
        self.habits = persistence.fetch(Habit.self)
        if habits.isEmpty {
            self.showEmptyStateView()
            return
        } else { self.removeEmptyStateView() }
        
        sortHabits()
    }
    
    func deleteHabit(_ habit: Habit) {
        persistence.delete(habit)
        self.habits = persistence.fetch(Habit.self)
        updateDataSource(on: self.habits)
        
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
        case .color: self.habits.sort { (hab1, hab2) -> Bool in hab1.color < hab2.color }
        case .dateCreated: self.habits.sort { (hab1, hab2) -> Bool in hab1.dateCreated.compare(hab2.dateCreated) == .orderedAscending }
        case .dueToday: self.habits.sort { (hab1, hab2) -> Bool in hab1.statuses[self.currentDay!] < hab2.statuses[self.currentDay!] }
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
        let newHabitVC = HabitDetailViewController(persistenceManager: persistence, notificationCenter: self.userNotificationCenter)
        newHabitVC.habitDelegate = self
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
extension HomeCollectionViewController: SaveHabitDelegate {
    func saveHabit() {
        self.fetchHabits()
        collectionView.reloadData()
        self.notificationCenter.post(name: NSNotification.Name("reload"), object: nil)
    }
    
    func delete(habit: Habit) {
        self.deleteHabit(habit)
        self.notificationCenter.post(name: NSNotification.Name("reload"), object: nil)
    }
}

extension HomeCollectionViewController: HabitCellDelegate {
    func presentNewHabitViewController(with habit: Habit) {
        let newHabitVC = HabitDetailViewController(persistenceManager: persistence, notificationCenter: self.userNotificationCenter)
        newHabitVC.habit = habit
        newHabitVC.habitDelegate = self
        let navController = UINavigationController(rootViewController: newHabitVC)
        navController.navigationBar.tintColor = .systemGreen
        DispatchQueue.main.async { self.present(navController, animated: true) }
    }
    
    func checkboxSelectionChanged(atIndex index: Int, forHabit habit: Habit, fromStatus oldStatus: Status, toStatus newStatus: Status, forState state: Bool?) {
        habit.checkBoxPressed(fromStatus: oldStatus, toStatus: newStatus, atIndex: index, withState: state)
        self.persistence.save()
        self.notificationCenter.post(name: NSNotification.Name("reload"), object: nil)
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
