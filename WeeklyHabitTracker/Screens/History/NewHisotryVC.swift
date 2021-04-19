//
//  NewHisotryVC.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/17/21.
//  Copyright © 2021 Robert Parsons. All rights reserved.
//

import UIKit

class NewHisotryVC: UICollectionViewController {
    // MARK: - Properties
    private var archives: [Archive] = []
    private var activeArchives: [Archive] = []
    private var finishedArchives: [Archive] = []
    
    private let persistenceManager: PersistenceService
    private let defaults: UserDefaults
    private let notificationCenter: NotificationCenter
    private let userNotificationCenter: UNUserNotificationCenter
    
    typealias DataSource = UICollectionViewDiffableDataSource<HistorySection, HistoryItem>
    private var dataSource: DataSource?
    
    private var sortButton: UIBarButtonItem!
    
    private let searchController = UISearchController()
    
    // MARK: - Inits
    init(persistenceManager: PersistenceService, defaults: UserDefaults, notifCenter: NotificationCenter, userNotifCenter: UNUserNotificationCenter) {
        self.persistenceManager = persistenceManager
        self.defaults = defaults
        self.notificationCenter = notifCenter
        self.userNotificationCenter = userNotifCenter
        
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CollectionView Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureNavigationBar()
        configureSearchController()
        configureNotifications()
        configureDataSource()
        
        fetchArchives()
        applySnapshot(on: self.activeArchives, and: self.finishedArchives)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.dataSource?.itemIdentifier(for: indexPath), let archive = item.archive else { print("selection error"); return }
        let archiveDetailVC = ArchiveDetailCollectionViewController(persistenceManager: self.persistenceManager, defaults: self.defaults, notifCenter: self.notificationCenter, archive: archive, delegate: self)
        navigationController?.pushViewController(archiveDetailVC, animated: true)
    }
    
    // MARK: - Configuration Functions
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search archives"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    private func configureNotifications() {
        self.notificationCenter.addObserver(self, selector: #selector(reloadArchives), name: NSNotification.Name(NotificationName.newDay.rawValue), object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(reloadArchives), name: NSNotification.Name(NotificationName.history.rawValue), object: nil)
    }
    
    private func configureDataSource() {
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, HistoryItem> { (cell, _, item) in
            var configuration = cell.defaultContentConfiguration()
            configuration.text = item.title
            configuration.textProperties.font = UIFont.boldSystemFont(ofSize: 17)
            cell.contentConfiguration = configuration
            
            let options = UICellAccessory.OutlineDisclosureOptions(style: .header, tintColor: .label)
            let disclosureAccessory = UICellAccessory.outlineDisclosure(options: options)
            let textAccessory = UICellAccessory.label(text: item.subtitle)
            cell.accessories = [textAccessory, disclosureAccessory]
        }
        
        let rowRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, HistoryItem> { (cell, _, item) in
            var configuration = cell.defaultContentConfiguration()
            configuration.text = item.title
            configuration.secondaryText = item.subtitle
            configuration.image = item.symbol
            configuration.imageProperties.maximumSize = CGSize(width: 40, height: 40)
            cell.contentConfiguration = configuration
            
            let options = UICellAccessory.OutlineDisclosureOptions(style: .cell, tintColor: .label)
            let disclosureAccessory = UICellAccessory.outlineDisclosure(options: options)
            cell.accessories = [disclosureAccessory]
        }
        
        self.dataSource = DataSource(collectionView: self.collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item.type {
            case .header: return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            case .row: return collectionView.dequeueConfiguredReusableCell(using: rowRegistration, for: indexPath, item: item)
            }
        })
    }
    
    // MARK: - Functions
    private func fetchArchives() {
        self.archives = self.persistenceManager.fetch(Archive.self)
        self.activeArchives = self.archives.filter { $0.active }
        self.activeArchives.sort { $0.title < $1.title }
        
        self.finishedArchives = self.archives.filter { !$0.active }
        self.finishedArchives.sort { $0.title < $1.title }
    }
    
    private func applySnapshot(on activeArchives: [Archive], and finishedArchives: [Archive]) {
        if self.archives.isEmpty {
            guard var snapshot = self.dataSource?.snapshot() else { return }
            
            snapshot.deleteAllItems()
            self.dataSource?.apply(snapshot, animatingDifferences: false)
            self.showEmptyStateView(withText: "To start recording habit history, create a new habit.")
        } else {
            self.removeEmptyStateView()
            for section in HistorySection.allCases {
                var snapshot = NSDiffableDataSourceSectionSnapshot<HistoryItem>()
                let headerSubtitle: String, archives: [Archive], symbol: UIImage?

                switch section {
                case .activeHabits:
                    headerSubtitle = "\(activeArchives.count)"
                    archives = activeArchives
                    symbol = UIImage(named: "checkmark.circle")
                case .finishedHabits:
                    headerSubtitle = "\(finishedArchives.count)"
                    archives = finishedArchives
                    symbol = UIImage(named: "star.circle")
                }

                let header = HistoryItem(archive: nil, type: .header, title: section.description, subtitle: headerSubtitle, symbol: nil)
                let rows = archives.map { HistoryItem(archive: $0, type: .row, title: $0.title,
                                                      subtitle: self.subtitle(success: $0.successRate, completed: $0.completedTotal, goal: $0.goal),
                                                      symbol: symbol?.withTintColor(FormingColors.getColor(fromValue: $0.color), renderingMode: .alwaysOriginal)) }

                snapshot.append([header])
                snapshot.expand([header])
                snapshot.append(rows, to: header)
                self.dataSource?.apply(snapshot, to: section, animatingDifferences: false, completion: nil)
            }
        }
    }
    
    private func subtitle(success rate: Double, completed: Int64, goal: Int64) -> String {
        var string = String(format: "Success: %.0f%%, ", rate * 100)
        if goal == -1 {
            string.append("No Goal")
        } else {
            string.append(String(format: "Goal: %.0f%%", (Double(completed) / Double(goal)) * 100.0))
        }
        return string
    }
    
    // MARK: - Selectors
    @objc func reloadArchives() {
        DispatchQueue.main.async {
            self.fetchArchives()
            self.applySnapshot(on: self.activeArchives, and: self.finishedArchives)
        }
    }
}

extension NewHisotryVC: ArchiveDetailDelegate {
    func delete(archive: Archive) {
        self.userNotificationCenter.deleteNotificationRequests(forDays: archive.habit.days, andUniqueID: archive.habit.uniqueID)
        self.persistenceManager.delete(archive)
        self.notificationCenter.reload(habits: true, history: true)
    }
    
    func reset(archive: Archive) {
        archive.reset()
        self.persistenceManager.save()
        self.notificationCenter.reload(habits: true, history: true, archiveDetail: true)
    }
    
    func restore(archive: Archive) {
        archive.restore()
        self.persistenceManager.save()
        self.userNotificationCenter.createNotificationRequest(forHabit: archive.habit)
        self.notificationCenter.reload(habits: true, history: true)
    }
}

extension NewHisotryVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text else { return }
        if filter.isEmpty { applySnapshot(on: self.activeArchives, and: self.finishedArchives); return }
        
        let filteredArchives = self.archives.filter { $0.title.lowercased().contains(filter.lowercased()) }
        let filteredActiveArchives = filteredArchives.filter { $0.active }
        let filteredFinishedArchives = filteredArchives.filter { !$0.active }
        applySnapshot(on: filteredActiveArchives, and: filteredFinishedArchives)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        applySnapshot(on: self.activeArchives, and: self.finishedArchives)
    }
}
