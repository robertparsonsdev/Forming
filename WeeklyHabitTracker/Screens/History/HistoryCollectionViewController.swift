//
//  HistoryCollectionViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

private let reuseIdentifier = "History Title Cell"
private let sectionReuseIdentifier = "History Section Header"

class HistoryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private var archives: [Archive] = []
    private var activeArchives: [Archive] = []
    private var finishedArchives: [Archive] = []
    private let persistenceManager: PersistenceService
    private let defaults: UserDefaults
    private let notificationCenter: NotificationCenter
    private let userNotificationCenter: UNUserNotificationCenter
    private var dataSource: UICollectionViewDiffableDataSource<HistorySection, Archive>?
    
    private let searchController = UISearchController()
    private var filteredArchives: [Archive] = []
    private var isSearching = false
    
    // MARK: - Initializers
    init(collectionViewLayout layout: UICollectionViewLayout, persistenceManager: PersistenceService, defaults: UserDefaults, notifCenter: NotificationCenter, userNotifCenter: UNUserNotificationCenter) {
        self.persistenceManager = persistenceManager
        self.defaults = defaults
        self.notificationCenter = notifCenter
        self.userNotificationCenter = userNotifCenter
        super.init(collectionViewLayout: layout)
        
        self.notificationCenter.addObserver(self, selector: #selector(reloadArchives), name: NSNotification.Name("newDay"), object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 30)
    }
    
    // MARK: - CollectionView Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        navigationController?.navigationBar.prefersLargeTitles = true
        collectionView.collectionViewLayout = UIHelper.createTwoColumnFlowLayout(in: collectionView)

        self.collectionView.register(HistoryTitleCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(HistorySectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: sectionReuseIdentifier)
        
        configureSearchController()
        configureDataSource()
        
        fetchArchives()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadArchives()
    }
    
    // MARK: - Configuration Functions
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Archived Habit"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<HistorySection, Archive>(collectionView: self.collectionView, cellProvider: { (collectionView, indexPath, archive) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? HistoryTitleCell
            cell?.setPercentLabelText(String(format: "%.1f%%", archive.successRate))
            cell?.setTitleLabelText(archive.title)
            cell?.setBackgroundColor(FormingColors.getColor(fromValue: archive.color))
            return cell
        })
        
        self.dataSource?.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sectionReuseIdentifier, for: indexPath) as? HistorySectionHeader
            switch indexPath.section {
            case 0: header?.set(title: "Active Habits")
            case 1: header?.set(title: self.finishedArchives.count > 0 ? "Finished Habits" : "")
            default: header?.set(title: "Error")
            }
            
            return header
        }
    }

    // MARK: CollectionView Functions
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let archive = self.dataSource?.itemIdentifier(for: indexPath) else { print("selection error"); return }
        let archiveDetailVC = ArchiveDetailCollectionViewController(persistenceManager: self.persistenceManager, archive: archive, delegate: self, defaults: self.defaults)
        navigationController?.pushViewController(archiveDetailVC, animated: true)
    }
    
    // MARK: - Functions
    func fetchArchives() {
        self.archives = persistenceManager.fetch(Archive.self)
        updateDataSource(on: self.archives)
    }
    
    func updateDataSource(on archives: [Archive]) {
        var snapshot = NSDiffableDataSourceSnapshot<HistorySection, Archive>()
        if !self.archives.isEmpty {
            self.activeArchives = archives.filter( { $0.active == true } )
            self.finishedArchives = archives.filter( { $0.active == false } )
            self.activeArchives.sort { (archive1, archive2) -> Bool in archive1.title < archive2.title}
            self.finishedArchives.sort { (archive1, archive2) -> Bool in archive1.title < archive2.title}
            
            snapshot.appendSections([.activeHabits, .finishedHabits])
            snapshot.appendItems(self.activeArchives, toSection: .activeHabits)
            snapshot.appendItems(self.finishedArchives, toSection: .finishedHabits)
            DispatchQueue.main.async {
                self.dataSource?.apply(snapshot, animatingDifferences: true)
                self.removeEmptyStateView()
            }
        } else {
            snapshot.deleteSections([.activeHabits, .finishedHabits])
            DispatchQueue.main.async {
                self.dataSource?.apply(snapshot, animatingDifferences: false)
                self.showEmptyStateView(withText: "To start recording habit history, create a new habit.")
            }
        }
    }
    
    // MARK: - Selectors
    @objc func reloadArchives() {
        fetchArchives()
        DispatchQueue.main.async { self.collectionView.reloadData() }
    }
}

// MARK: - Delegates
extension HistoryCollectionViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text else { return }
        if filter.isEmpty { updateDataSource(on: self.archives); isSearching = false; return }
        self.isSearching = true
        
        self.filteredArchives = self.archives.filter { ($0.title.lowercased().contains(filter.lowercased())) }
        updateDataSource(on: self.filteredArchives)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearching = false
        updateDataSource(on: self.archives)
    }
}

extension HistoryCollectionViewController: ArchiveDetailDelegate {
    func delete(archive: Archive) {
        self.userNotificationCenter.deleteNotificationRequests(forDays: archive.habit.days, andUniqueID: archive.habit.uniqueID)
        self.persistenceManager.delete(archive)
        if let index = self.archives.firstIndex(of: archive) {
            self.archives.remove(at: index)
            updateDataSource(on: self.archives)
        }
    }
}
