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
    private let persistenceManager: PersistenceService
    private let defaults: UserDefaults
    private let notificationCenter: NotificationCenter
    private var delegate: ArchiveDetailDelegate
    private var dataSource: UICollectionViewDiffableDataSource<CVSection, ArchivedHabit>!
    
    private let sortAC = UIAlertController(title: "Sort By:", message: nil, preferredStyle: .actionSheet)
    private let sortKey = "archivedHabitSort"
    private var defaultSort: ArchiveDetailSort = .dateDescending
    private let menuAC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    private let confirmDeleteAC = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    private let confirmResetAC = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    private let confirmRestoreAC = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    
    // MARK: - Initializers
    init(layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout(), persistenceManager: PersistenceService, defaults: UserDefaults, notifCenter: NotificationCenter, archive: Archive, delegate: ArchiveDetailDelegate) {
        self.persistenceManager = persistenceManager
        self.defaults = defaults
        self.notificationCenter = notifCenter
        self.archive = archive
        self.delegate = delegate
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CollectionView Functions
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
        collectionView.collectionViewLayout = UIHelper.createSingleColumnFlowLayout(in: collectionView)
//        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout { layout.sectionHeadersPinToVisibleBounds = true }
        
        // Register cell classes
        self.collectionView.register(ArchivedHabitCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(ArchiveDetailHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        
        configureSortAlertController()
        configureMenuAlertController()
        configureConfirmationAlertControllers()
        configureDataSource()
        
        fetchArchivedHabits()
        
        // Notification oberservers
        self.notificationCenter.addObserver(self, selector: #selector(reloadArchivedHabits), name: NSNotification.Name(NotificationName.newDay.rawValue), object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(reloadArchivedHabits), name: NSNotification.Name(NotificationName.archiveDetail.rawValue), object: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        let indexPath = IndexPath(row: 0, section: 0)
//        let headerView = self.dataSource.collectionView(self.collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
//        return headerView.systemLayoutSizeFitting(CGSize(width: self.collectionView.frame.width, height: UIView.layoutFittingCompressedSize.height),
//        withHorizontalFittingPriority: .required,
//        verticalFittingPriority: .fittingSizeLevel)
//        return CGSize(width: view.frame.width, height: collectionView.frame.width / 2 + 60)
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            self.notificationCenter.removeObserver(self, name: NSNotification.Name(NotificationName.newDay.rawValue), object: nil)
            self.notificationCenter.removeObserver(self, name: NSNotification.Name(NotificationName.archiveDetail.rawValue), object: nil)
        }
    }

    // MARK: - Configuration Functions
    func configureSortAlertController() {
        sortAC.message = "Current sort: \(self.defaultSort.rawValue)"
        sortAC.view.tintColor = .systemGreen
        ArchiveDetailSort.allCases.forEach { (sort) in
            sortAC.addAction(UIAlertAction(title: sort.rawValue, style: .default, handler: sortAlertTapped))
        }
        sortAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    func configureMenuAlertController() {
        menuAC.view.tintColor = .systemGreen
        menuAC.addAction(UIAlertAction(title: "Delete Archive", style: .default, handler: showDeleteConfirmation))
        if self.archive.active { menuAC.addAction(UIAlertAction(title: "Reset Archive", style: .default, handler: showResetConfirmation)) }
        else { menuAC.addAction(UIAlertAction(title: "Restore Archive", style: .default, handler: showRestoreConfirmation)) }
        menuAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    func configureConfirmationAlertControllers() {
        confirmDeleteAC.view.tintColor = .systemGreen
        confirmDeleteAC.title = "Are you sure you want to delete this archive?"
        confirmDeleteAC.message = "Deleting an archive permanently deletes all habit history, statistics, and the current habit. This action can't be undone."
        confirmDeleteAC.addAction(UIAlertAction(title: "Delete", style: .default, handler: deleteArchive))
        confirmDeleteAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        confirmResetAC.view.tintColor = .systemGreen
        confirmResetAC.title = "Are you sure you want to reset this archive?"
        confirmResetAC.message = "Resetting an archive clears all habit history, statistics, and resets the current habit, allowing for a fresh start."
        confirmResetAC.addAction(UIAlertAction(title: "Reset", style: .default, handler: resetArchive))
        confirmResetAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        confirmRestoreAC.view.tintColor = .systemGreen
        confirmRestoreAC.title = "Are you sure you want to restore this archive?"
        confirmRestoreAC.message = "Restoring an archive restores habit history, statistics, and creates a new habit in Habits, allowing the habit to be tracked again."
        confirmRestoreAC.addAction(UIAlertAction(title: "Restore", style: .default, handler: restoreArchive))
        confirmRestoreAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<CVSection, ArchivedHabit>(collectionView: self.collectionView, cellProvider: { (collectionView, indexPath, archivedHabit) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ArchivedHabitCell
            cell?.set(archivedHabit: archivedHabit)
            cell?.set(delegate: self)
            return cell
        })
        
        self.dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! ArchiveDetailHeaderCell
            header.set(completed: self.archive.completedTotal, failed: self.archive.failedTotal, completionRate: self.archive.successRate, goal: self.archive.habit.goal)
            return header
        }
    }
    
    // MARK: - Functions
    func fetchArchivedHabits() {
        if let array = self.archive.archivedHabits?.array as? [ArchivedHabit] { self.archivedHabits = array }
        sortArchivedHabits()
    }
    
    func updateDataSource(on archivedHabits: [ArchivedHabit]) {
        var snapshot = NSDiffableDataSourceSnapshot<CVSection, ArchivedHabit>()
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
        case .dateAscending: self.archivedHabits.sort { (one, two) -> Bool in one.startDate.compare(two.startDate) == .orderedAscending }
        case .dateDescending: self.archivedHabits.sort { (one, two) -> Bool in one.startDate.compare(two.startDate) == .orderedDescending }
        }
        updateDataSource(on: self.archivedHabits)
    }
    
    // MARK: - Selectors
    @objc func reloadArchivedHabits() {
        DispatchQueue.main.async {
            self.title = self.archive.title
            self.configureDataSource()
            self.fetchArchivedHabits()
        }
    }
    
    @objc func sortButtonPressed() {
        present(sortAC, animated: true)
    }
    
    @objc func menuButtonPressed() {
        present(menuAC, animated: true)
    }
    
    @objc func showDeleteConfirmation(sender: UIAlertAction) {
        present(self.confirmDeleteAC, animated: true)
    }
    
    @objc func showResetConfirmation(sender: UIAlertAction) {
        present(self.confirmResetAC, animated: true)
    }
    
    @objc func showRestoreConfirmation(sender: UIAlertAction) {
        present(self.confirmRestoreAC, animated: true)
    }
    
    @objc func deleteArchive(sender: UIAlertAction) {
        self.delegate.delete(archive: self.archive)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func resetArchive(sender: UIAlertAction) {
        self.delegate.reset(archive: self.archive)
    }
    
    @objc func restoreArchive(sender: UIAlertAction) {
        self.delegate.restore(archive: self.archive)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Delegates
extension ArchiveDetailCollectionViewController: ArchivedHabitCellDelegate {
    func pushViewController(with archivedHabit: ArchivedHabit) {
        let vc = ArchivedHabitDetailViewController(persistenceManager: self.persistenceManager, notifCenter: self.notificationCenter)
        vc.set(archivedHabit: archivedHabit)
        vc.title = "Week \(archivedHabit.weekNumber)"
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Protocols
protocol ArchiveDetailDelegate {
    func delete(archive: Archive)
    func reset(archive: Archive)
    func restore(archive: Archive)
}
