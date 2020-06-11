//
//  Status.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/18/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import Foundation

@objc public enum Status: Int64, Comparable {
//    case failed, completed, incomplete, empty
    case incomplete, completed, failed, empty
    
    public static func < (lhs: Status, rhs: Status) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
