//
//  TDLNotificationService.swift
//  Rx_MVVM_ToDoList
//
//  Created by Trainee on 6/27/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import UserNotifications

class TDLNotificationService: NotificationService {
    
    func allowNotification() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, error in
                print("Permission granted: \(granted)")
        }
    }
    
    func addNotificationIfNeeded(for task: TaskModel) {
        removeNotification(for: task)
        guard !task.completed else { return }
        if let notDate = task.notificationDate, notDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "To Do List:"
            content.body = task.text
            content.sound = UNNotificationSound.default
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month,.day,.hour,.minute], from: notDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: task.uuid.uuidString, content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request)
        }
        
    }
    
    func removeNotification(for task: TaskModel) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [task.uuid.uuidString])
    }
    
    func removeAllNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
    }
    
    func syncNotification(for tasks: [TaskModel]) {
        removeAllNotification()
        
        for task in tasks {
            addNotificationIfNeeded(for: task)
        }
    }
    
    
}
