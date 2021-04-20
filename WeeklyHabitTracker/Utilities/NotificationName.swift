//
//  NotificationName.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 7/9/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import Foundation

enum NotificationName: String {
    case newDay = "newDay"
    case habits = "habits"
    case history = "history"
    case archiveDetail = "archiveDetail"
    case archivedHabitDetail = "archivedHabitDetail"
    case finishHabitFromNotes = "finishHabitFromNotes"
}

enum Setting: String {
    case defaultReminder = "defaultReminderSetting"
    case badgeAppIcon = "badgeAppIconSetting"
    case hideHabits = "hideCompletedHabits"
}
