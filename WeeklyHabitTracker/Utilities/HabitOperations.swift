//
//  Operations.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/15/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import Foundation
import CoreData

class HabitOperations {
    static func performDayChange(withPersistence persistence: PersistenceService) {
        var habits = persistence.fetch(Habit.self)
        let context = persistence.context
        let currentDay = CalUtility.getCurrentDay()
        let notificationCenter = NotificationCenter.default

        switch currentDay {
        case 0:
            for (index, habit) in habits.enumerated() {
                if habit.statuses[6] == .incomplete { habit.statuses[6] = .failed }
                let archivedHabit = ArchivedHabit(context: context)
                archivedHabit.archive = habit.archive
                archivedHabit.statuses = habit.statuses
                archivedHabit.startDate = CalUtility.getLastStartDate()
                archivedHabit.endDate = CalUtility.getLastEndDate()
                habit.archive.insertIntoArchivedHabits(archivedHabit, at: 0)
                for (statusIndex, status) in habit.statuses.enumerated() {
                    if status != .empty { habit.statuses[statusIndex] = .incomplete }
                }
                habits[index] = habit
            }
        default:
            for (index, habit) in habits.enumerated() {
                if habit.statuses[currentDay - 1] == .incomplete { habit.statuses[currentDay - 1] = .failed }
                if habit.statuses[currentDay] == .completed || habit.statuses[currentDay] == .failed { habit.buttonState = true }
                else if habit.statuses[currentDay] == .incomplete { habit.buttonState = false }
                habits[index] = habit
            }
        }
        
        persistence.save()
        notificationCenter.post(name: NSNotification.Name("newDay"), object: nil)
    }
}
