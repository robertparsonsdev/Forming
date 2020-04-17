//
//  Habit.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/16/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

struct Habit {
    var title: String?
    var days: [Bool]
    var color: UIColor
    var subHabits: [Habit]?
    var priority: Int?
    var reminder: Date?
}
