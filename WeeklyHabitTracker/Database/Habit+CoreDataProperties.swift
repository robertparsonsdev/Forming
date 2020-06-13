//
//  Habit+CoreDataProperties.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//
//

import Foundation
import CoreData


extension Habit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Habit> {
        return NSFetchRequest<Habit>(entityName: "Habit")
    }

    @NSManaged public var buttonState: Bool
    @NSManaged public var color: Int64
    @NSManaged public var dateCreated: Date
    @NSManaged public var days: Array<Bool>
    @NSManaged public var flag: Bool
    @NSManaged public var priority: Int64
    @NSManaged public var reminder: Date?
    @NSManaged public var statusValues: Array<Int64>
    @NSManaged public var title: String?
    @NSManaged public var uniqueID: String
    @NSManaged public var oldHabits: NSOrderedSet?
    @NSManaged public var archive: Archive
    
    public var statuses: [Status] {
        get {
            var array = [Status]()
            statusValues.forEach {
                if let status = Status(rawValue: $0) { array.append(status) }
            }
            return array
        }
        set {
            var array = [Int64]()
            newValue.forEach {
                array.append($0.rawValue)
            }
            self.statusValues = array
        }
    }

}

// MARK: Generated accessors for oldHabits
extension Habit {

    @objc(insertObject:inOldHabitsAtIndex:)
    @NSManaged public func insertIntoOldHabits(_ value: ArchivedHabit, at idx: Int)

    @objc(removeObjectFromOldHabitsAtIndex:)
    @NSManaged public func removeFromOldHabits(at idx: Int)

    @objc(insertOldHabits:atIndexes:)
    @NSManaged public func insertIntoOldHabits(_ values: [ArchivedHabit], at indexes: NSIndexSet)

    @objc(removeOldHabitsAtIndexes:)
    @NSManaged public func removeFromOldHabits(at indexes: NSIndexSet)

    @objc(replaceObjectInOldHabitsAtIndex:withObject:)
    @NSManaged public func replaceOldHabits(at idx: Int, with value: ArchivedHabit)

    @objc(replaceOldHabitsAtIndexes:withOldHabits:)
    @NSManaged public func replaceOldHabits(at indexes: NSIndexSet, with values: [ArchivedHabit])

    @objc(addOldHabitsObject:)
    @NSManaged public func addToOldHabits(_ value: ArchivedHabit)

    @objc(removeOldHabitsObject:)
    @NSManaged public func removeFromOldHabits(_ value: ArchivedHabit)

    @objc(addOldHabits:)
    @NSManaged public func addToOldHabits(_ values: NSOrderedSet)

    @objc(removeOldHabits:)
    @NSManaged public func removeFromOldHabits(_ values: NSOrderedSet)

}
