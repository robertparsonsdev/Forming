//
//  CalendarManager.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import Foundation

class CalUtility {
    static func getCurrentDay() -> Int {
        let date = Date()
        let calendar = Calendar.current
        return calendar.component(.weekday, from: date) - 1
    }
    
    static func getCurrentWeek() -> [String] {
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
    
    static func getTimeAsString(time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: time)
    }
    
    static func getDateAsString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    static func getTimeAsDate(time: String) -> Date? {
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
    
    static func getFutureDate() -> Date {
        let date = Date()
        let calendar = Calendar.current
        return calendar.date(byAdding: .year, value: 100, to: date)!
    }
    
    static func getCurrentDate() -> Date {
        let date = Date()
        let calendar = Calendar.current
        return calendar.date(byAdding: .second, value: 0, to: date)!
    }
    
    static func getReminderComps(time: Date, weekday: Int) -> DateComponents {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = calendar.component(.hour, from: time)
        components.minute = calendar.component(.minute, from: time)
        components.weekday = weekday
        return components
    }
    
    static func getLastStartDate() -> Date {
        let calendar = Calendar.current
        let date = Date()
        return calendar.date(byAdding: .day, value: -7, to: date)!
    }
    
    static func getLastEndDate() -> Date {
        let calendar = Calendar.current
        let date = Date()
        return calendar.date(byAdding: .day, value: -1, to: date)!
    }
}
