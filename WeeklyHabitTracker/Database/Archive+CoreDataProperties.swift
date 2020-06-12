//
//  Archive+CoreDataProperties.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/11/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//
//

import Foundation
import CoreData


extension Archive {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Archive> {
        return NSFetchRequest<Archive>(entityName: "Archive")
    }

    @NSManaged public var oldHabits: NSSet?

}

// MARK: Generated accessors for oldHabits
extension Archive {

    @objc(addOldHabitsObject:)
    @NSManaged public func addToOldHabits(_ value: Habit)

    @objc(removeOldHabitsObject:)
    @NSManaged public func removeFromOldHabits(_ value: Habit)

    @objc(addOldHabits:)
    @NSManaged public func addToOldHabits(_ values: NSSet)

    @objc(removeOldHabits:)
    @NSManaged public func removeFromOldHabits(_ values: NSSet)

}
