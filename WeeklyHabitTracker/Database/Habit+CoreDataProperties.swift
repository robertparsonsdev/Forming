//
//  Habit+CoreDataProperties.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/18/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//
//

import Foundation
import CoreData


extension Habit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Habit> {
        return NSFetchRequest<Habit>(entityName: "Habit")
    }

    @NSManaged public var title: String?
    @NSManaged public var color: Int64
    @NSManaged public var days: [Bool]
}
