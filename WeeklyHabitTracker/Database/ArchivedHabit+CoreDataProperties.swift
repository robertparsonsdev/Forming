//
//  ArchivedHabit+CoreDataProperties.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/12/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//
//

import Foundation
import CoreData


extension ArchivedHabit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArchivedHabit> {
        return NSFetchRequest<ArchivedHabit>(entityName: "ArchivedHabit")
    }

    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var notes: String?
    @NSManaged public var archive: Archive?

}
