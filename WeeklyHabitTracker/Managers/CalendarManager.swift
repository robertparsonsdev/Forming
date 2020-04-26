//
//  CalendarManager.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import Foundation

class CalendarManager {
    static let shared = CalendarManager()
    
    private init() {}
    
    func currentWeekDay() -> Int {
        let date = Date()
        let calendar = Calendar.current
        return calendar.component(.weekday, from: date) - 1
    }
}
