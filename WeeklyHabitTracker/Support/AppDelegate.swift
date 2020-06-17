//
//  AppDelegate.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var currentDate: Date?
    var key = "date"
    let defaults = UserDefaults.standard
    let persistence = PersistenceService.shared
    let center = NotificationCenter.default
    let userCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted { print("granted") }
            else { print("not granted") }
        }
        
        if let date = defaults.object(forKey: self.key) as? Date { self.currentDate = date }
        else { self.currentDate = CalUtility.getCurrentDate(); self.defaults.set(self.currentDate, forKey: self.key) }
        // if current implementation doesn't work, try calling dayChanged in the 2 lines above
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.forming.refresh", using: nil) { (task) in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        center.addObserver(self, selector: #selector(dayChanged), name: .NSCalendarDayChanged, object: nil)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.persistence.save()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("active")
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.forming.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let content = UNMutableNotificationContent()
        content.subtitle = "Notification"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        if Calendar.current.isDateInToday(self.currentDate!) {
            queue.addOperation {
                content.title = "Background"
                self.userCenter.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger))
            }
        } else {
            queue.addOperation {
                content.title = "Day Change"
                self.userCenter.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger))
                self.currentDate = CalUtility.getCurrentDate()
                self.defaults.set(self.currentDate, forKey: self.key)
                HabitOperations.performDayChange(withPersistence: self.persistence)
            }
        }
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        let lastOperation = queue.operations.last
        lastOperation?.completionBlock = {
            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
        }
    }
    
//    func handleAppRefresh(task: BGAppRefreshTask) {
//        guard !Calendar.current.isDateInToday(self.currentDate!) else {
//            NotificationCenter.default.post(name: NSNotification.Name("green"), object: nil)
//            scheduleAppRefresh()
//            task.setTaskCompleted(success: true)
//            return
//        }
//        NotificationCenter.default.post(name: NSNotification.Name("purple"), object: nil)
//
//        scheduleAppRefresh()
//        self.currentDate = CalUtility.getCurrentDate()
//        self.defaults.set(self.currentDate, forKey: self.key)
//
//        let queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
//        queue.addOperation {
//            HabitOperations.performDayChange(withPersistence: self.persistence)
//        }
//
//        task.expirationHandler = {
//            queue.cancelAllOperations()
//        }
//
//        let lastOperation = queue.operations.last
//        lastOperation?.completionBlock = {
//            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
//        }
//    }
    
    @objc func dayChanged() {
        guard !Calendar.current.isDateInToday(self.currentDate!) else { return }
        self.currentDate = CalUtility.getCurrentDate()
        self.defaults.set(self.currentDate, forKey: self.key)
        HabitOperations.performDayChange(withPersistence: self.persistence)
    }
}
