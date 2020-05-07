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
    var archives: [String] = []
    let persistenceManager: PersistenceService
    
    let searchController = UISearchController()
    
    // MARK: - Initializers
    init(collectionViewLayout layout: UICollectionViewLayout, persistenceManager: PersistenceService) {
        self.persistenceManager = persistenceManager
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
        
        if archives.count == 0 {
            self.showEmptyStateView(withText: "\n\n\n\n\nYour habit history will be displayed here when you complete your first week of habits.")
            return
        }

        self.collectionView!.register(HistoryCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        configureSearchController()
    }
    
    // MARK: - Configuration Functions
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Archived Habit"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return archives.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HistoryCell
        return cell
    }

}

// MARK: - Delegates
extension HistoryCollectionViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
//
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//
    }
}
