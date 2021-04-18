//
//  HistorySection.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/13/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

enum HistorySection: CaseIterable {
    case activeHabits
    case finishedHabits
    
    var description: String {
        switch self {
        case .activeHabits:
            return "Active Habits"
        default:
            return "Finished Habits"
        }
    }
}

struct HistoryItem: Hashable {
    private let id = UUID()
    let archive: Archive?
    let type: HistoryItemType
    
    let title: String
    let subtitle: String
    let symbol: UIImage?
}

enum HistoryItemType: Int {
    case header, row
}
