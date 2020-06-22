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
    private let persistence: PersistenceService
    
    init(persistence: PersistenceService) {
        self.persistence = persistence
    }
    
    func performDayChange() {
        var habits = self.persistence.fetch(Habit.self)
        let currentDay = CalUtility.getCurrentDay()

        switch currentDay {
        case 0:
            for (index, habit) in habits.enumerated() {
                if habit.statuses[6] == .incomplete {
                    habit.statuses[6] = .failed
                    updateStats(fromStatus: .incomplete, toStatus: .failed, forArchive: &habit.archive)
                }
                
                if var currentArchivedHabit = habit.archive.archivedHabits?.lastObject as? ArchivedHabit {
                    updateCurrentArchivedHabit(forArchivedHabit: &currentArchivedHabit, withStatuses: habit.statuses)
                }
                
                for (statusIndex, status) in habit.statuses.enumerated() {
                    if status != .empty {
                        habit.statuses[statusIndex] = .incomplete
                        habit.archive.incompleteTotal += 1
                    }
                }
                habit.buttonState = false
                
                habit.archive.insertIntoArchivedHabits(createArchivedHabit(withHabit: habit), at: 0)
                habits[index] = habit
            }
        default:
            for (index, habit) in habits.enumerated() {
                if habit.statuses[currentDay - 1] == .incomplete {
                    habit.statuses[currentDay - 1] = .failed
                    updateStats(fromStatus: .incomplete, toStatus: .failed, forArchive: &habit.archive)
                }
                
                if habit.statuses[currentDay] == .completed || habit.statuses[currentDay] == .failed {
                    habit.buttonState = true
                } else if habit.statuses[currentDay] == .incomplete {
                    habit.buttonState = false
                }
                
                if var currentArchivedHabit = habit.archive.archivedHabits?.lastObject as? ArchivedHabit {
                    updateCurrentArchivedHabit(forArchivedHabit: &currentArchivedHabit, withStatuses: habit.statuses)
                }
                
                habits[index] = habit
            }
        }
    }
    
    func performCheckboxPressed(withArchive archive: inout Archive, andStatuses statuses: [Status], andOldStatus oldStatus: Status, toNewStatus newStatus: Status) {
        if var currentArchivedHabit = archive.archivedHabits?.lastObject as? ArchivedHabit {
            updateCurrentArchivedHabit(forArchivedHabit: &currentArchivedHabit, withStatuses: statuses)
        }
        updateStats(fromStatus: oldStatus, toStatus: newStatus, forArchive: &archive)
    }
    
    func updateCurrentArchivedHabit(forArchivedHabit archivedHabit: inout ArchivedHabit, withStatuses statuses: [Status]) {
        archivedHabit.statuses = statuses
    }
    
    private func createArchivedHabit(withHabit habit: Habit) -> ArchivedHabit {
        let archivedHabit = ArchivedHabit(context: self.persistence.context)
        archivedHabit.archive = habit.archive
        archivedHabit.statuses = habit.statuses
        archivedHabit.startDate = CalUtility.getFirstDateOfWeek()
        archivedHabit.endDate = CalUtility.getLastDateOfWeek()
        return archivedHabit
    }
    
    func updateStats(fromStatus oldStatus: Status, toStatus newStatus: Status, forArchive archive: inout Archive) {
        switch oldStatus {
        case .completed:
            switch newStatus {
            case .completed: ()
            case .failed: archive.completedTotal -= 1; archive.failedTotal += 1
            case .incomplete: archive.completedTotal -= 1; archive.incompleteTotal += 1
            case .empty: archive.completedTotal -= 1
            }
        case .failed:
            switch newStatus {
            case .completed: archive.failedTotal -= 1; archive.completedTotal += 1
            case .failed: ()
            case .incomplete: archive.failedTotal -= 1; archive.incompleteTotal += 1
            case .empty: archive.failedTotal -= 1
            }
        case .incomplete:
            switch newStatus {
            case .completed: archive.incompleteTotal -= 1; archive.completedTotal += 1
            case .failed: archive.incompleteTotal -= 1; archive.failedTotal += 1
            case .incomplete: ()
            case .empty: archive.incompleteTotal -= 1
            }
        case .empty:
            switch newStatus {
            case .completed: archive.completedTotal += 1
            case .failed: archive.failedTotal += 1
            case .incomplete: archive.incompleteTotal += 1
            case .empty: ()
            }
        }
        
        let total = Double(archive.completedTotal + archive.failedTotal)
        if total != 0 { archive.successRate = Double(archive.completedTotal) / total * 100 }
        else { archive.successRate = 100.0 }
    }
}
