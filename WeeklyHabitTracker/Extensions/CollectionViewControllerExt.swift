//
//  CollectionViewControllerExt.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/28/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

extension UICollectionViewController {
    func showEmptyStateView(withText text: String? = nil) {
        let emptyStateView: EmptyStateView
        if let message = text { emptyStateView = EmptyStateView(message: message) }
        else { emptyStateView = EmptyStateView() }
        emptyStateView.tag = 1000
        collectionView.addSubview(emptyStateView)
        emptyStateView.anchor(top: collectionView.safeAreaLayoutGuide.topAnchor, left: nil, bottom: collectionView.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: collectionView.frame.width, height: 0)
        navigationItem.searchController?.searchBar.isHidden = true
        collectionView.alwaysBounceVertical = false
    }

    func removeEmptyStateView() {
        if let emptyStateView = collectionView.viewWithTag(1000) {
            emptyStateView.removeFromSuperview()
            navigationItem.searchController?.searchBar.isHidden = false
            collectionView.alwaysBounceVertical = true
        }
    }
}
