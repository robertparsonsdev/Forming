//
//  AppDelegate.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 4/14/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit
import BackgroundTasks
import UserNotifications

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
        
        if !Calendar.current.isDateInToday(self.currentDate!) {
            dayChanged()
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.forming.refresh", using: nil) { (task) in
            self.scheduleLocalNotification(withTitle: "Refresh")
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        center.addObserver(self, selector: #selector(dayChanged), name: .NSCalendarDayChanged, object: nil)
        center.addObserver(self, selector: #selector(enteredBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        return true
    }
    
    func scheduleLocalNotification(withTitle title: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "Notification"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        self.userCenter.add(request)
    }
    
    @objc func enteredBackground() {
        self.scheduleAppRefresh()
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
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.forming.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)

        do {
            try BGTaskScheduler.shared.submit(request)
            print("Successfully scheduled app refresh.")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        if Calendar.current.isDateInToday(self.currentDate!) {
            queue.addOperation { print("do nothing") }
        } else {
            queue.addOperation { self.dayChanged() }
        }

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
            queue.cancelAllOperations()
        }

        let lastOperation = queue.operations.last
        lastOperation?.completionBlock = {
            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
        }
    }
    
    @objc func dayChanged() {
        self.currentDate = CalUtility.getCurrentDate()
        self.defaults.set(self.currentDate, forKey: self.key)
        HabitOperations.performDayChange(withPersistence: self.persistence)
    }
}
