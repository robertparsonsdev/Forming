//
//  HistoryCollectionViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class HistoryCollectionViewController: UICollectionViewController {
    private var archives: [Archive] = []
    private let persistenceManager: PersistenceService
    private let notificationCenter: NotificationCenter
    private var dataSource: UICollectionViewDiffableDataSource<Section, Archive>!
    
    private let searchController = UISearchController()
    private var filteredArchives: [Archive] = []
    private var isSearching = false
    
    // MARK: - Initializers
    init(collectionViewLayout layout: UICollectionViewLayout, persistenceManager: PersistenceService, notifCenter: NotificationCenter) {
        self.persistenceManager = persistenceManager
        self.notificationCenter = notifCenter
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CollectionView Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        navigationController?.navigationBar.prefersLargeTitles = true
        collectionView.collectionViewLayout = UIHelper.createTwoColumnFlowLayout(in: collectionView)
        self.notificationCenter.addObserver(self, selector: #selector(reloadArchives), name: NSNotification.Name(rawValue: "reload"), object: nil)

        self.collectionView!.register(ArchiveTitleCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        configureSearchController()
        configureDataSource()
        updateArchives()
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
        self.dataSource = UICollectionViewDiffableDataSource<Section, Archive>(collectionView: self.collectionView, cellProvider: { (collectionView, indexPath, archive) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ArchiveTitleCell
            cell.setTitleLabelText(archive.title)
            cell.setBackgroundColor(FormingColors.getColor(fromValue: archive.color))
            return cell
        })
    }

    // MARK: CollectionView Functions
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return archives.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = self.isSearching ? self.filteredArchives : self.archives
        let archive = activeArray[indexPath.row]
        let archiveDetailVC = ArchiveDetailCollectionViewController(archive: archive)
        navigationController?.pushViewController(archiveDetailVC, animated: true)
    }
    
    // MARK: - Functions
    func updateData(on archives: [Archive]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Archive>()
        snapshot.appendSections([.main])
        snapshot.appendItems(archives)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func updateArchives() {
        self.archives = persistenceManager.fetch(Archive.self)
        guard !self.archives.isEmpty else {
            self.showEmptyStateView(withText: "To start recording habit history, create a new habit.")
            return
        }
        self.removeEmptyStateView()
        self.archives.sort { (archive1, archive2) -> Bool in archive1.title < archive2.title}
        updateData(on: self.archives)
    }
    
    // MARK: - Selectors
    @objc func reloadArchives() {
        updateArchives()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

// MARK: - Delegates
extension HistoryCollectionViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text else { return }
        if filter.isEmpty { updateData(on: self.archives); isSearching = false; return }
        self.isSearching = true
        
        filteredArchives = self.archives.filter { ($0.title.lowercased().contains(filter.lowercased())) }
        updateData(on: filteredArchives)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearching = false
        updateData(on: self.archives)
    }
}
