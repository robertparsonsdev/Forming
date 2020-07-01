//
//  Habit+CoreDataClass.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//
//

import Foundation
import CoreData


public class Habit: NSManagedObject {
    func checkBoxPressed(fromStatus oldStatus: Status, toStatus newStatus: Status, atIndex index: Int, withState state: Bool?) {
        updateStatus(toStatus: newStatus, atIndex: index)
        if let buttonState = state { updateButtonState(toState: buttonState) }
        self.archive.updateCurrentArchivedHabit(toStatus: newStatus, atIndex: index)
        self.archive.updateStats(fromStatus: oldStatus, toStatus: newStatus)
    }
    
    func dayChanged(toDay newDay: Int) {
        if self.statuses[newDay - 1] == .incomplete {
            updateStatus(toStatus: .failed, atIndex: newDay - 1)
            self.archive.updateCurrentArchivedHabit(toStatus: .failed, atIndex: newDay - 1)
            self.archive.updateStats(fromStatus: .incomplete, toStatus: .failed)
        }
        
        if self.statuses[newDay] == .completed || self.statuses[newDay] == .failed {
            updateButtonState(toState: true)
        } else if self.statuses[newDay] == .incomplete {
            updateButtonState(toState: false)
        }
    }
    
    func weekChanged(withNewArchivedHabit archivedHabit: ArchivedHabit) {
        if self.statuses[6] == .incomplete {
            updateStatus(toStatus: .failed, atIndex: 6)
            self.archive.updateCurrentArchivedHabit(toStatus: .failed, atIndex: 6)
            self.archive.updateStats(fromStatus: .incomplete, toStatus: .failed)
        }
        
        resetStatuses()
        
        updateButtonState(toState: false)
        
        self.archive.createNewArchivedHabit(fromArchivedHabit: archivedHabit, withStatuses: self.statuses)
    }
    
    func resetStatuses() {
        for (index, status) in self.statuses.enumerated() {
            if status != .empty {
                updateStatus(toStatus: .incomplete, atIndex: index)
                self.archive.updateStats(fromStatus: .empty, toStatus: .incomplete)
            }
        }
    }
    
    func updateStatus(toStatus status: Status, atIndex index: Int) {
        self.statuses[index] = status
    }
    
    func updateButtonState(toState state: Bool) {
        self.buttonState = state
    }
}
