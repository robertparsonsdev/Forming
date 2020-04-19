//
//  Status.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/18/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import Foundation

@objc public enum Status: Int64 {
    case failed, completed, incomplete, empty
}
