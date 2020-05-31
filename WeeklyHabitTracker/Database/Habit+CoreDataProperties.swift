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
    @NSManaged private var statusValues: [Int64]
    @NSManaged public var priority: Int64
    @NSManaged public var reminder: Date?
    @NSManaged public var repeatability: Int64
    @NSManaged public var buttonState: Bool
    @NSManaged public var dateCreated: Date
    @NSManaged public var dueToday: Bool
    @NSManaged private var currentDayValue: Int64
    
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
    
    public var currentDay: Int {
        get { return Int(self.currentDayValue) }
        set { self.currentDayValue = Int64(newValue) }
    }
}
