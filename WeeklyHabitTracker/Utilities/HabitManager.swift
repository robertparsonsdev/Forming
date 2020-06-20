//
//  Operations.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/15/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import Foundation
import CoreData

class HabitManager {
    static func performDayChange(withPersistence persistence: PersistenceService) {
        var habits = persistence.fetch(Habit.self)
        let context = persistence.context
        let currentDay = CalUtility.getCurrentDay()
        let notificationCenter = NotificationCenter.default

        switch currentDay {
        case 0:
            for (index, habit) in habits.enumerated() {
                if habit.statuses[6] == .incomplete { habit.statuses[6] = .failed; updateStats(fromStatus: .incomplete, toStatus: .failed, fromHabit: habit) }
                
                updateArchivedHabit(fromHabit: habit, notifaction: false)
                
                for (statusIndex, status) in habit.statuses.enumerated() {
                    if status != .empty { habit.statuses[statusIndex] = .incomplete }
                }
                
                habit.archive.insertIntoArchivedHabits(createArchivedHabit(withContext: context, andHabit: habit), at: 0)
                habits[index] = habit
            }
        default:
            for (index, habit) in habits.enumerated() {
                if habit.statuses[currentDay - 1] == .incomplete { habit.statuses[currentDay - 1] = .failed; updateStats(fromStatus: .incomplete, toStatus: .failed, fromHabit: habit) }
                if habit.statuses[currentDay] == .completed || habit.statuses[currentDay] == .failed { habit.buttonState = true }
                else if habit.statuses[currentDay] == .incomplete { habit.buttonState = false }
                
                updateArchivedHabit(fromHabit: habit, notifaction: false)
                
                habits[index] = habit
            }
        }
        
        persistence.save()
        notificationCenter.post(name: NSNotification.Name("newDay"), object: nil)
    }
    
    static func updateArchivedHabit(fromHabit habit: Habit, notifaction: Bool) {
        if let archivedHabit = habit.archive.archivedHabits?.lastObject as? ArchivedHabit {
            habit.archive.replaceArchivedHabits(at: 0, with: updateArchivedHabit(fromArchivedHabit: archivedHabit, andHabit: habit))
        }
        
        if notifaction {
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: NSNotification.Name("reload"), object: nil)
        }
    }
    
    private static func updateArchivedHabit(fromArchivedHabit oldArchivedHabit: ArchivedHabit, andHabit habit: Habit) -> ArchivedHabit {
        let archivedHabit = oldArchivedHabit
        archivedHabit.statuses = habit.statuses
        return archivedHabit
    }
    
    private static func createArchivedHabit(withContext context: NSManagedObjectContext, andHabit habit: Habit) -> ArchivedHabit {
        let archivedHabit = ArchivedHabit(context: context)
        archivedHabit.archive = habit.archive
        archivedHabit.statuses = habit.statuses
        archivedHabit.startDate = CalUtility.getFirstDateOfWeek()
        archivedHabit.endDate = CalUtility.getLastDateOfWeek()
        return archivedHabit
    }
    
    static func updateStats(fromStatus oldStatus: Status, toStatus newStatus: Status, fromHabit habit: Habit) {
        let notificationCenter = NotificationCenter.default

        switch oldStatus {
        case .completed:
            switch newStatus {
            case .completed: ()
            case .failed: habit.archive.completedTotal -= 1; habit.archive.failedTotal += 1
            case .incomplete: habit.archive.completedTotal -= 1; habit.archive.incompleteTotal += 1
            case .empty: habit.archive.completedTotal -= 1
            }
        case .failed:
            switch newStatus {
            case .completed: habit.archive.failedTotal -= 1; habit.archive.completedTotal += 1
            case .failed: ()
            case .incomplete: habit.archive.failedTotal -= 1; habit.archive.incompleteTotal += 1
            case .empty: habit.archive.failedTotal -= 1
            }
        case .incomplete:
            switch newStatus {
            case .completed: habit.archive.incompleteTotal -= 1; habit.archive.completedTotal += 1
            case .failed: habit.archive.incompleteTotal -= 1; habit.archive.failedTotal += 1
            case .incomplete: ()
            case .empty: habit.archive.incompleteTotal -= 1
            }
        case .empty:
            switch newStatus {
            case .completed: habit.archive.completedTotal += 1
            case .failed: habit.archive.failedTotal += 1
            case .incomplete: habit.archive.incompleteTotal += 1
            case .empty: ()
            }
        }
        
        let total = Double(habit.archive.completedTotal + habit.archive.failedTotal)
        if total != 0 { habit.archive.successRate = Double(habit.archive.completedTotal) / total * 100 }
        else { habit.archive.successRate = 100.0 }
        
        notificationCenter.post(name: NSNotification.Name("reload"), object: nil)
    }
}
