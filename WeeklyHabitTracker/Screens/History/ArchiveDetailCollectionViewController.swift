//
//  ArchiveDetailCollectionViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

private let reuseIdentifier = "archivedHabitCell"
private let headerReuseIdentifier = "archivedHabitHeader"

class ArchiveDetailCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private var archive: Archive!
    private var archivedHabits = [ArchivedHabit]()
    private let persistenceManager: PersistenceService
    private let defaults: UserDefaults
    private let notificationCenter: NotificationCenter
    private weak var delegate: ArchiveDetailDelegate?
    private var dataSource: UICollectionViewDiffableDataSource<CVSection, ArchivedHabit>!

    private var sortButton: UIBarButtonItem!
    private var menuButton: UIBarButtonItem!
    private var sortAlertController: UIAlertController!
    private let sortKey = "archivedHabitSort"
    private var defaultSort: ArchiveDetailSort = .dateDescending
    private let menuAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

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
    
    deinit {
        print("archive detail deinit")
    }
    
    // MARK: - CollectionView Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.archive.title
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = UIHelper.createHabitsFlowLayout(in: collectionView)

        self.collectionView.register(ArchivedHabitCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(ArchiveDetailHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        
        self.notificationCenter.addObserver(self, selector: #selector(reloadArchivedHabits), name: NSNotification.Name(NotificationName.newDay.rawValue), object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(reloadArchivedHabits), name: NSNotification.Name(NotificationName.archiveDetail.rawValue), object: nil)

        configureNavigationBar()
        configureMenuAlertController()
        configureConfirmationAlertControllers()
        configureDataSource()

        fetchArchivedHabits()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        let indexPath = IndexPath(row: 0, section: 0)
//        let headerView = self.dataSource.collectionView(self.collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
//        return headerView.systemLayoutSizeFitting(CGSize(width: self.collectionView.frame.width, height: UIView.layoutFittingCompressedSize.height),
//        withHorizontalFittingPriority: .required,
//        verticalFittingPriority: .fittingSizeLevel)
//        return CGSize(width: view.frame.width, height: collectionView.frame.width / 2 + 60)
        return CGSize(width: view.frame.width, height: 265)
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            self.notificationCenter.removeObserver(self, name: NSNotification.Name(NotificationName.newDay.rawValue), object: nil)
            self.notificationCenter.removeObserver(self, name: NSNotification.Name(NotificationName.archiveDetail.rawValue), object: nil)
        }
    }

    // MARK: - Configuration Functions
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        self.menuButton = UIBarButtonItem(image: UIImage(named:"ellipsis.circle"), style: .plain, target: self, action: #selector(menuButtonTapped))
        
        if let sort = self.defaults.object(forKey: self.sortKey) {
            self.defaultSort = ArchiveDetailSort(rawValue: sort as! String)!
        }

        if #available(iOS 14, *) {
            self.sortButton = UIBarButtonItem(image: UIImage(named: "arrow.up.arrow.down"), menu: createSortMenu())
        } else {
            self.sortAlertController = UIAlertController(title: "Sort by:", message: nil, preferredStyle: .actionSheet)
            configureSortAlertController()
            self.sortButton = UIBarButtonItem(image: UIImage(named:"arrow.up.arrow.down"), style: .plain, target: self, action: #selector(sortButtonTapped))
        }
        
        self.navigationItem.rightBarButtonItems = [self.menuButton, self.sortButton]
    }
    
    private func configureSortAlertController() {
        sortAlertController.message = "Current sort: \(self.defaultSort.rawValue)"
        sortAlertController.view.tintColor = .systemGreen
        ArchiveDetailSort.allCases.forEach { (sort) in
            sortAlertController.addAction(UIAlertAction(title: sort.rawValue, style: .default, handler: { [weak self] (alert: UIAlertAction) in
                guard let self = self else { return }
                if let sortTitle = alert.title {
                    self.sortActionTriggered(sort: ArchiveDetailSort(rawValue: sortTitle)!)
                    self.sortAlertController.message = "Current sort: \(sortTitle)"
                }
            }))
        }
        sortAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }

    private func configureMenuAlertController() {
        menuAlertController.view.tintColor = .systemGreen
        menuAlertController.addAction(UIAlertAction(title: "Delete Archive", style: .default, handler: { [weak self] (alert: UIAlertAction) in
            guard let self = self else { return }
            self.present(self.confirmDeleteAC, animated: true)
        }))
        if self.archive.active {
            menuAlertController.addAction(UIAlertAction(title: "Reset Archive", style: .default, handler: { [weak self] (alert: UIAlertAction) in
                guard let self = self else { return }
                self.present(self.confirmResetAC, animated: true)
            }))
        } else {
            menuAlertController.addAction(UIAlertAction(title: "Restore Archive", style: .default, handler: { [weak self] (alert: UIAlertAction) in
                guard let self = self else { return }
                self.present(self.confirmRestoreAC, animated: true)
            }))
        }
        menuAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }

    private func configureConfirmationAlertControllers() {
        confirmDeleteAC.view.tintColor = .systemGreen
        confirmDeleteAC.title = "Are you sure you want to delete this archive?"
        confirmDeleteAC.message = "Deleting an archive permanently deletes all habit history, statistics, and the current habit. This action can't be undone."
        confirmDeleteAC.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak self] (alert: UIAlertAction) in
            guard let self = self else { return }
            self.delegate!.delete(archive: self.archive)
            self.navigationController?.popViewController(animated: true)
        }))
        confirmDeleteAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        confirmResetAC.view.tintColor = .systemGreen
        confirmResetAC.title = "Are you sure you want to reset this archive?"
        confirmResetAC.message = "Resetting an archive clears all habit history, statistics, and resets the current habit, allowing for a fresh start."
        confirmResetAC.addAction(UIAlertAction(title: "Reset", style: .default, handler: { [weak self] (alert: UIAlertAction) in
            guard let self = self else { return }
            self.delegate!.reset(archive: self.archive)
        }))
        confirmResetAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        confirmRestoreAC.view.tintColor = .systemGreen
        confirmRestoreAC.title = "Are you sure you want to restore this archive?"
        confirmRestoreAC.message = "Restoring an archive restores habit history, statistics, and creates a new habit in Habits, allowing the habit to be tracked again."
        confirmRestoreAC.addAction(UIAlertAction(title: "Restore", style: .default, handler: { [weak self] (alert: UIAlertAction) in
            guard let self = self else { return }
            self.delegate!.restore(archive: self.archive)
            self.navigationController?.popViewController(animated: true)
        }))
        confirmRestoreAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }

    private func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<CVSection, ArchivedHabit>(collectionView: self.collectionView, cellProvider: { [weak self] (collectionView, indexPath, archivedHabit) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ArchivedHabitCell
            cell?.set(archivedHabit: archivedHabit, buttonEnabled: false)
            cell?.set(delegate: self)
            return cell
        })

        self.dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard let self = self else { return nil }
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! ArchiveDetailHeaderCell
            header.set(completed: self.archive.completedTotal, failed: self.archive.failedTotal, completionRate: self.archive.successRate, goal: self.archive.goal)
            header.set(completed: self.archive.completedTotal, failed: self.archive.failedTotal, incomplete: self.archive.incompleteTotal)
            header.set(delegate: self)
            return header
        }
    }

    // MARK: - Functions
    private func fetchArchivedHabits() {
        if let array = self.archive.archivedHabits?.array as? [ArchivedHabit] { self.archivedHabits = array }
        sortArchivedHabits()
    }

    private func updateDataSource(on archivedHabits: [ArchivedHabit]) {
        var snapshot = NSDiffableDataSourceSnapshot<CVSection, ArchivedHabit>()
        snapshot.appendSections([.main])
        snapshot.appendItems(archivedHabits)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    @available(iOS 14, *)
    private func createSortMenu() -> UIMenu {
        var children = [UIAction]()
        ArchiveDetailSort.allCases.forEach { (sort) in
            children.append(UIAction(title: sort.rawValue, state: sort.rawValue == self.defaultSort.rawValue ? .on : .off, handler: { [weak self] (action) in
                guard let self = self else { return }
                self.sortActionTriggered(sort: sort)
                self.sortButton.menu = self.createSortMenu()
            }))
        }
        return UIMenu(title: "Sort by:", children: children)
    }
    
    private func sortActionTriggered(sort: ArchiveDetailSort) {
        self.defaultSort = sort
        self.defaults.set(sort.rawValue, forKey: self.sortKey)
        sortArchivedHabits()
    }

    private func sortArchivedHabits() {
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

    @objc func sortButtonTapped() {
        DispatchQueue.main.async {
            self.present(self.sortAlertController, animated: true)
        }
    }

    @objc func menuButtonTapped() {
        DispatchQueue.main.async {
            self.present(self.menuAlertController, animated: true)
        }
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
    
    func save() { }
    func selectionChanged(atIndex index: Int, fromStatus oldStatus: Status, toStatus newStatus: Status, forState state: Bool?) { }
    func presentAlertController(with alert: UIAlertController) { }
}

extension ArchiveDetailCollectionViewController: FormingProgressViewDelegate {
    func showAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = .systemGreen
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

// MARK: - Protocols
protocol ArchiveDetailDelegate: class {
    func delete(archive: Archive)
    func reset(archive: Archive)
    func restore(archive: Archive)
}
