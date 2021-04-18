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
    private func fetchArchives() {
        self.archives = self.persistenceManager.fetch(Archive.self)
        self.activeArchives = self.archives.filter { $0.active }
        self.activeArchives.sort { $0.title < $1.title }
        
        self.finishedArchives = self.archives.filter { !$0.active }
        self.finishedArchives.sort { $0.title < $1.title }
        applyInitialSnapshot()
    }
    
    private func applyInitialSnapshot() {
        for section in HistorySection.allCases {
            var snapshot = NSDiffableDataSourceSectionSnapshot<HistoryItem>()
            let headerSubtitle: String, archives: [Archive], symbol: UIImage?
            
            switch section {
            case .activeHabits:
                headerSubtitle = "\(self.activeArchives.count)"
                archives = self.activeArchives
                symbol = UIImage(named: "checkmark.circle")
            case .finishedHabits:
                headerSubtitle = "\(self.finishedArchives.count)"
                archives = self.finishedArchives
                symbol = UIImage(named: "star.circle")
            }
            
            let header = HistoryItem(type: .header, title: section.description, subtitle: headerSubtitle, symbol: nil)
            let rows = archives.map { HistoryItem(type: .row, title: $0.title,
                                                  subtitle: $0.goal == -1 ? "No Goal" : String(format: "%.0f%%", $0.successRate * 100),
                                                  symbol: symbol?.withTintColor(FormingColors.getColor(fromValue: $0.color), renderingMode: .alwaysOriginal)) }
            
            snapshot.append([header])
            snapshot.expand([header])
            snapshot.append(rows, to: header)
            self.dataSource?.apply(snapshot, to: section, animatingDifferences: false, completion: nil)
        }
    }
}

extension NewHisotryVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
