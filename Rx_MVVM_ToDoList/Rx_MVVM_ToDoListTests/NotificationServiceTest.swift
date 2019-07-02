//
//  NotificationServiceTest.swift
//  NotificationServiceTest
//
//  Created by Trainee on 7/2/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import XCTest
import RxTest
import UserNotifications
@testable import Rx_MVVM_ToDoList

class NotificationServiceTest: XCTestCase {
    var notificationService: NotificationService!
    var testScheduler = TestScheduler(initialClock: 0)
    
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        notificationService = TDLNotificationService()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_addNotificationIfNeeded() {
        let center = UNUserNotificationCenter.current()
        var countBefore = 0
        var countAfter = 0
        
        let firstPromise = expectation(description: "first get")
        let secondPromise = expectation(description: "second get")
        
        let firstScheduler = TestScheduler(initialClock: 0)
        let secondScheduler = TestScheduler(initialClock: 0)
        
        notificationService.removeAllNotification()
        
        firstScheduler.scheduleAt(0) {
            center.getPendingNotificationRequests { (notifications) in
                countBefore = notifications.count
                firstPromise.fulfill()
            }
        }
        
        firstScheduler.start()
        wait(for: [firstPromise], timeout: 5)
        firstScheduler.stop()
        
        XCTAssert(countBefore == 0)
        
        let date = Date() + 3600
        
        let noRememberTask = TaskModel(
            text: "NO Remember",
            createDate: Date(),
            notificationDate: nil,
            completed: false,
            orderID: 0,
            uuid: UUID())
        
        let rememberTask = TaskModel(
            text: "Remember",
            createDate: Date(),
            notificationDate: date,
            completed: false,
            orderID: 1,
            uuid: UUID())
        
        notificationService.addNotificationIfNeeded(for: noRememberTask)
        notificationService.addNotificationIfNeeded(for: rememberTask)
        
        secondScheduler.scheduleAt(5) {
            center.getPendingNotificationRequests { (notifications) in
                countAfter = notifications.count
                secondPromise.fulfill()
            }
        }
        
        secondScheduler.start()
        wait(for: [secondPromise], timeout: 5)
        secondScheduler.stop()
        
        XCTAssert(countAfter == countBefore + 1)
        
    }
    
    func test_removeNotification() {
        let center = UNUserNotificationCenter.current()
        var countBefore = 0
        var countAfter = 0
        
        let firstPromise = expectation(description: "first get")
        let secondPromise = expectation(description: "second get")
        
        let firstScheduler = TestScheduler(initialClock: 0)
        let secondScheduler = TestScheduler(initialClock: 0)
        
        let date = Date() + 3600
        
        let rememberTask = TaskModel(
            text: "Remember",
            createDate: Date(),
            notificationDate: date,
            completed: false,
            orderID: 1,
            uuid: UUID())
        
        notificationService.addNotificationIfNeeded(for: rememberTask)
        
        firstScheduler.scheduleAt(0) {
            center.getPendingNotificationRequests { (notifications) in
                countBefore = notifications.count
                firstPromise.fulfill()
            }
        }
        
        firstScheduler.start()
        wait(for: [firstPromise], timeout: 5)
        firstScheduler.stop()
        
        notificationService.removeNotification(for: rememberTask)
        
        secondScheduler.scheduleAt(5) {
            center.getPendingNotificationRequests { (notifications) in
                countAfter = notifications.count
                secondPromise.fulfill()
            }
        }
        
        secondScheduler.start()
        wait(for: [secondPromise], timeout: 5)
        secondScheduler.stop()
        
        XCTAssert(countAfter == countBefore - 1)
    }
    
    func test_removeAllNotification() {
        let center = UNUserNotificationCenter.current()
        var countBefore = 0
        var countAfter = 0
        let n = 5
        
        let firstPromise = expectation(description: "first get")
        let secondPromise = expectation(description: "second get")
        
        let firstScheduler = TestScheduler(initialClock: 0)
        let secondScheduler = TestScheduler(initialClock: 0)
        
        let date = Date() + 3600
        
        var tasks = [TaskModel]()
        
        for i in  1...n {
            let rememberTask = TaskModel(
                text: "Remember",
                createDate: Date(),
                notificationDate: date,
                completed: false,
                orderID: i,
                uuid: UUID())
            tasks.append(rememberTask)
        }
        
        firstScheduler.scheduleAt(0) {
            center.getPendingNotificationRequests { (notifications) in
                countBefore = notifications.count
                firstPromise.fulfill()
            }
        }
        
        firstScheduler.start()
        wait(for: [firstPromise], timeout: 5)
        firstScheduler.stop()
        
        XCTAssert(countBefore != 0)
        
        notificationService.removeAllNotification()
        
        secondScheduler.scheduleAt(5) {
            center.getPendingNotificationRequests { (notifications) in
                countAfter = notifications.count
                secondPromise.fulfill()
            }
        }
        
        secondScheduler.start()
        wait(for: [secondPromise], timeout: 5)
        secondScheduler.stop()
        
        XCTAssert(countAfter == 0)
    }
    
    func test_syncNotification() {
        let center = UNUserNotificationCenter.current()
        var countBefore = 0
        var countAfter = 0
        
        let firstPromise = expectation(description: "first get")
        let secondPromise = expectation(description: "second get")
        
        let firstScheduler = TestScheduler(initialClock: 0)
        let secondScheduler = TestScheduler(initialClock: 0)
        
        notificationService.removeAllNotification()
        
        firstScheduler.scheduleAt(0) {
            center.getPendingNotificationRequests { (notifications) in
                countBefore = notifications.count
                firstPromise.fulfill()
            }
        }
        
        firstScheduler.start()
        wait(for: [firstPromise], timeout: 5)
        firstScheduler.stop()
        
        XCTAssert(countBefore == 0)
        
        let date = Date() + 3600
        
        let noRememberTask = TaskModel(
            text: "NO Remember",
            createDate: Date(),
            notificationDate: nil,
            completed: false,
            orderID: 0,
            uuid: UUID())
        
        let rememberTask = TaskModel(
            text: "Remember",
            createDate: Date(),
            notificationDate: date,
            completed: false,
            orderID: 1,
            uuid: UUID())
        
        let deliveredTask = TaskModel(
            text: "Remember",
            createDate: Date(),
            notificationDate: Date(),
            completed: false,
            orderID: 1,
            uuid: UUID())
        
        let checkedTask = TaskModel(
            text: "Remember",
            createDate: Date(),
            notificationDate: date,
            completed: true,
            orderID: 1,
            uuid: UUID())
        
        let tasks = [noRememberTask, rememberTask, deliveredTask, checkedTask]
        
        notificationService.syncNotification(for: tasks)
        
        secondScheduler.scheduleAt(5) {
            center.getPendingNotificationRequests { (notifications) in
                countAfter = notifications.count
                secondPromise.fulfill()
            }
        }
        
        secondScheduler.start()
        wait(for: [secondPromise], timeout: 5)
        secondScheduler.stop()
        
        XCTAssert(countAfter == countBefore + 1)
        
    }

}
