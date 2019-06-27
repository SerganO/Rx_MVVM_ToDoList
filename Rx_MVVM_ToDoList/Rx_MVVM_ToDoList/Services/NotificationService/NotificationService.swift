//
//  NotificationService.swift
//  Rx_MVVM_ToDoList
//
//  Created by Trainee on 6/27/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation

protocol NotificationService {
    func allowNotification()
    func addNotificationIfNeeded(for task: TaskModel)
    func removeNotification(for task: TaskModel)
    func removeAllNotification()
    func syncNotification(for tasks: [TaskModel])
}
