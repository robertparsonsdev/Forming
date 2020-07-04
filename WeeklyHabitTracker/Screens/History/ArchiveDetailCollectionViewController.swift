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
    private var dataSource: UICollectionViewDiffableDataSource<Section, ArchivedHabit>!
    
    // MARK: - Initializers
    init(layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout(), archive: Archive) {
        self.archive = archive
        if let array = archive.archivedHabits?.array as? [ArchivedHabit] { self.archivedHabits = array }
        super.init(collectionViewLayout: layout)
        self.title = archive.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        collectionView.alwaysBounceVertical = true

        // Register cell classes
        self.collectionView.register(ArchivedHabitCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(ArchiveDetailHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        
        configureDataSource()
        updateData(on: self.archivedHabits)
    }

    // MARK: CollectionView Functions
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 30, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.width / 3)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
    }

    // MARK: - Configuration Functions
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, ArchivedHabit>(collectionView: self.collectionView, cellProvider: { (collectionView, indexPath, archivedHabit) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ArchivedHabitCell
            cell?.set(archivedHabit: archivedHabit)
            cell?.set(delegate: self)
            return cell
        })
        
        self.dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! ArchiveDetailHeaderCell
            header.set(percentage: String(format: "%.1f%%", self.archive.successRate))
            return header
        }
    }
    
    // MARK: - Functions
    func updateData(on archivedHabits: [ArchivedHabit]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ArchivedHabit>()
        snapshot.appendSections([.main])
        snapshot.appendItems(archivedHabits)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
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
