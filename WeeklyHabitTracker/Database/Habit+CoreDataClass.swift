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
    func updateStatus(fromStatus oldStatus: Status, toStatus newStatus: Status, atIndex index: Int, withState state: Bool?) {
        self.statuses[index] = newStatus
        if let buttonState = state { self.buttonState = buttonState }
        self.archive.updateCurrentArchivedHabit(toStatus: newStatus, atIndex: index)
        self.archive.updateStats(fromStatus: oldStatus, toStatus: newStatus)
    }
}
