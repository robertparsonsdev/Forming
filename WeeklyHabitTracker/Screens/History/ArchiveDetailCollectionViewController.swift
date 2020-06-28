//
//  ArchiveDetailCollectionViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Archived Habit Cell"
private let headerReuseIdentifier = "Archived Detail Header"

class ArchiveDetailCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let archive: Archive
    private var archivedHabits = [ArchivedHabit]()
    private let defaults: UserDefaults
    private let notificationCenter: NotificationCenter
    private var dataSource: UICollectionViewDiffableDataSource<Section, ArchivedHabit>!
    
    private let sortAC = UIAlertController(title: "Sort By:", message: nil, preferredStyle: .actionSheet)
    private let sortKey = "archivedHabitSort"
    private var defaultSort: ArchiveDetailSort = .dateDescending
    private let menuAC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    // MARK: - Initializers
    init(layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout(), archive: Archive, defaults: UserDefaults, notifCenter: NotificationCenter) {
        self.archive = archive
        self.defaults = defaults
        self.notificationCenter = notifCenter
//        if let array = archive.archivedHabits?.array as? [ArchivedHabit] { self.archivedHabits = array }
        
        super.init(collectionViewLayout: layout)
        
        self.notificationCenter.addObserver(self, selector: #selector(reloadArchivedHabits), name: NSNotification.Name("newDay"), object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(reloadArchivedHabits), name: NSNotification.Name("reload"), object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.archive.title
        collectionView.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        collectionView.alwaysBounceVertical = true
        
        let sortButton = UIBarButtonItem(image: UIImage(named:"arrow.up.arrow.down"), style: .plain, target: self, action: #selector(sortButtonPressed))
        let menuButton = UIBarButtonItem(image: UIImage(named:"ellipsis.circle"), style: .plain, target: self, action: #selector(menuButtonPressed))
        navigationItem.rightBarButtonItems = [menuButton, sortButton]
        if let sort = self.defaults.object(forKey: self.sortKey) { self.defaultSort = ArchiveDetailSort(rawValue: sort as! String)! }
        
        // Register cell classes
        self.collectionView.register(ArchivedHabitCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(ArchiveDetailHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        
        configureAlertControllers()
        configureDataSource()
        
        fetchArchivedHabits()
    }

    // MARK: CollectionView Functions
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 30, height: 90)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
    }

    // MARK: - Configuration Functions
    func configureAlertControllers() {
        sortAC.message = "Current sort: \(self.defaultSort.rawValue)"
        sortAC.view.tintColor = .systemGreen
        ArchiveDetailSort.allCases.forEach { (sort) in
            sortAC.addAction(UIAlertAction(title: sort.rawValue, style: .default, handler: sortAlertTapped))
        }
        sortAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        menuAC.view.tintColor = .systemGreen
        menuAC.addAction(UIAlertAction(title: "Delete Archive", style: .default, handler: nil))
        if !self.archive.active { menuAC.addAction(UIAlertAction(title: "Restore Habit", style: .default, handler: nil)) }
        menuAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, ArchivedHabit>(collectionView: self.collectionView, cellProvider: { (collectionView, indexPath, archivedHabit) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ArchivedHabitCell
            cell?.set(archivedHabit: archivedHabit)
            cell?.set(delegate: self)
            return cell
        })
        
        self.dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! ArchiveDetailHeaderCell
            header.set(percentage: String(format: "%.1f%%", self.archive.successRate))
            header.set(completed: self.archive.completedTotal, failed: self.archive.failedTotal, incomplete: self.archive.incompleteTotal)
            return header
        }
    }
    
    // MARK: - Functions
    func fetchArchivedHabits() {
        if let array = self.archive.archivedHabits?.array as? [ArchivedHabit] { self.archivedHabits = array }
        sortArchivedHabits()
    }
    
    func updateDataSource(on archivedHabits: [ArchivedHabit]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ArchivedHabit>()
        snapshot.appendSections([.main])
        snapshot.appendItems(archivedHabits)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func sortAlertTapped(sender: UIAlertAction) {
        if let sortTitle = sender.title {
            self.defaultSort = ArchiveDetailSort(rawValue: sortTitle)!
            self.defaults.set(self.defaultSort.rawValue, forKey: self.sortKey)
            self.sortAC.message = "Current sort: \(self.defaultSort.rawValue)"
            sortArchivedHabits()
        }
    }
    
    func sortArchivedHabits() {
        switch self.defaultSort {
        case .dateAscending: self.archivedHabits.sort { (one, two) -> Bool in one.startDate?.compare(two.startDate!) == .orderedAscending }
        case .dateDescending: self.archivedHabits.sort { (one, two) -> Bool in one.startDate?.compare(two.startDate!) == .orderedDescending }
        }
        updateDataSource(on: self.archivedHabits)
    }
    
    // MARK: - Selectors
    @objc func reloadArchivedHabits() {
        fetchArchivedHabits()
        DispatchQueue.main.async { self.title = self.archive.title; self.collectionView.reloadData() }
    }
    
    @objc func sortButtonPressed() {
        present(sortAC, animated: true)
    }
    
    @objc func menuButtonPressed() {
        present(menuAC, animated: true)
    }
}

// MARK: - Delegates
extension ArchiveDetailCollectionViewController: ArchivedHabitCellDelegate {
    func pushViewController(with archivedHabit: ArchivedHabit) {
        let vc = ArchivedHabitDetailViewController()
        vc.set(archivedHabit: archivedHabit)
        navigationController?.pushViewController(vc, animated: true)
    }
}
