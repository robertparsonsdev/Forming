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
    
    func getCurrentDay() -> Int {
        let date = Date()
        let calendar = Calendar.current
        return calendar.component(.weekday, from: date) - 1
    }
    
    func getCurrentWeek() -> [String] {
        let date = Date()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        var days = Array(repeating: "", count: 7)
        let currentDay = getCurrentDay()
        
        days[currentDay] = dateFormatter.string(from: date)

        for index in 0..<currentDay {
            if let day = calendar.date(byAdding: .day, value: index - currentDay, to: date) {
                days[index] = dateFormatter.string(from: day)
            }
        }
        
        for index in 0..<(6 - currentDay) {
            if let day = calendar.date(byAdding: .day, value: index + 1, to: date) {
                days[index + currentDay + 1] = dateFormatter.string(from: day)
            }
        }
        
        return days
    }
}
