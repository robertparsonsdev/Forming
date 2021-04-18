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
    private var defaultSort: HistorySort = .alphabetical
    
    private let searchController = UISearchController()
    private var filteredArchives: [Archive] = []
    
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
        configureDataSource()
        
        fetchArchives()
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
        
        self.sortButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), menu: createSortMenu())
        navigationItem.rightBarButtonItem = self.sortButton
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search archives"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
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
            configuration.image = item.symbol
            configuration.imageProperties.maximumSize = CGSize(width: 25, height: 25)
            cell.contentConfiguration = configuration
            
            let options = UICellAccessory.OutlineDisclosureOptions(style: .cell, tintColor: .label)
            let disclosureAccessory = UICellAccessory.outlineDisclosure(options: options)
            let textAccessory = UICellAccessory.label(text: item.subtitle)
            cell.accessories = [textAccessory, disclosureAccessory]
        }
        
        self.dataSource = DataSource(collectionView: self.collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item.type {
            case .header: return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            case .row: return collectionView.dequeueConfiguredReusableCell(using: rowRegistration, for: indexPath, item: item)
            }
        })
    }
    
    // MARK: - Functions
    func fetchArchives() {
        self.archives = self.persistenceManager.fetch(Archive.self)
        self.activeArchives = self.archives.filter { $0.active }
        self.finishedArchives = self.archives.filter { !$0.active }
        self.finishedArchives.sort { $0.title < $1.title }
        applyInitialSnapshot()
    }
    
    func applyInitialSnapshot() {
        for section in HistorySection.allCases {
            var snapshot = NSDiffableDataSourceSectionSnapshot<HistoryItem>()
            
            let subtitle = section == .activeHabits ? "\(self.activeArchives.count)" : "\(self.finishedArchives.count)"
            let header = HistoryItem(type: .header, title: section.description, subtitle: subtitle, symbol: nil)
            snapshot.append([header])
            
            let archives = section == .activeHabits ? self.activeArchives : self.finishedArchives
            let symbol = section == .activeHabits ? UIImage(named: "star.circle") : UIImage(named: "checkmark.circle")
            let rows = archives.map { HistoryItem(type: .row, title: $0.title,
                                                  subtitle: $0.goal == -1 ? "No Goal" : "\($0.completedTotal) / \($0.goal)",
                                                  symbol: symbol?.withTintColor(FormingColors.getColor(fromValue: $0.color), renderingMode: .alwaysOriginal)) }
            snapshot.append(rows, to: header)
            
            self.dataSource?.apply(snapshot, to: section, animatingDifferences: false, completion: nil)
        }
    }
    
    func createSortMenu() -> UIMenu {
        var children = [UIAction]()
        HistorySort.allCases.forEach { (sort) in
            children.append(UIAction(title: sort.rawValue, state: sort.rawValue == self.defaultSort.rawValue ? .on : .off, handler: { [weak self] (action) in
                guard let self = self else { return }
                self.sortActionTriggered(sort: sort)
                self.sortButton.menu = self.createSortMenu()
            }))
        }
        return UIMenu(title: "Sort active habits by:", children: children)
    }
    
    private func sortActionTriggered(sort: HistorySort) {
//        self.defaultSort = sort
//        self.defaults.set(sort.rawValue, forKey: self.sortKey)
//        guard !self.activeArchives.isEmpty else { return }
//        self.updateDataSource(on: self.archives, isActiveCollapsed: self.isActiveCollapsed, isFinishedCollapsed: self.isFinishedCollapsed)
    }
}

extension NewHisotryVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
