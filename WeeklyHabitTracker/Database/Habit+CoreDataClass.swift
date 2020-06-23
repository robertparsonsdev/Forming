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
    
    func updateStatus(toStatus status: Status, atIndex index: Int) {
        self.statuses[index] = status
    }
    
    func updateButtonState(toState state: Bool) {
        self.buttonState = state
    }
}
