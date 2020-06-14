//
//  PersistenceService.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/18/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import Foundation
import CoreData

final class PersistenceService {
    private init() {}
    static let shared = PersistenceService()
    
    lazy var context = persistentContainer.viewContext
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "WeeklyHabitTracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
                print("saved")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
        save()
    }
    
    func fetch<T: NSManagedObject>(_ objectType: T.Type) -> [T] {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest) as? [T]
            return fetchedObjects ?? [T]()
        } catch {
            print(error)
            return [T]()
        }
    }
    
    func updateHabitsForDayChange() -> [Habit] {
        let currentDay = CalUtility.getCurrentDay()
        var habits = self.fetch(Habit.self)
        
        switch currentDay {
        case 0:
            for (index, habit) in habits.enumerated() {
                if habit.statuses[6] == .incomplete { habit.statuses[6] = .failed }
                let archivedHabit = ArchivedHabit(context: self.context)
                archivedHabit.archive = habit.archive
                archivedHabit.statuses = habit.statuses
                archivedHabit.startDate = CalUtility.getLastStartDate()
                archivedHabit.endDate = CalUtility.getLastEndDate()
                habit.archive.insertIntoArchivedHabits(archivedHabit, at: 0)
                for (statusIndex, status) in habit.statuses.enumerated() {
                    if status != .empty { habit.statuses[statusIndex] = .incomplete }
                }
                habits[index] = habit
            }
        default:
            for (index, habit) in habits.enumerated() {
                if habit.statuses[currentDay - 1] == .incomplete { habit.statuses[currentDay - 1] = .failed }
                if habit.statuses[currentDay] == .completed || habit.statuses[currentDay] == .failed { habit.buttonState = true }
                else if habit.statuses[currentDay] == .incomplete { habit.buttonState = false }
                habits[index] = habit
            }
        }
        return habits
    }
}
