//
//  ArchivedHabit+CoreDataClass.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ArchivedHabit)
public class ArchivedHabit: NSManagedObject {
    func updateStatus(toStatus status: Status, atIndex index: Int) {
        self.statuses[index] = status
    }
}
