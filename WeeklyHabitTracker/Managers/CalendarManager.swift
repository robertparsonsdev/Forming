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
    
    func getTimeAsString(time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: time)
    }
    
    func getTimeAsDate(time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        if let date = formatter.date(from: time) {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            return calendar.date(bySettingHour: hour, minute: minutes, second: 0, of: date)
        } else { return nil }
    }
}
