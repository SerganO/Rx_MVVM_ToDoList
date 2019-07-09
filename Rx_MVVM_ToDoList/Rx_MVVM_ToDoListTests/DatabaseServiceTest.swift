//
//  DatabaseServiceTest.swift
//  DatabaseServiceTest
//
//  Created by Trainee on 6/25/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import Foundation
import Firebase
@testable import Rx_MVVM_ToDoList

class DatabaseServiceTest: XCTestCase {
    var databaseService: FirebaseDatabaseService!
    var testScheduler = TestScheduler(initialClock: 0)
    let disposeBag = DisposeBag()
    
    
    override func setUp() {
        super.setUp()
        databaseService = FirebaseDatabaseService(launchInTestMode: true)
    }
    
    override func tearDown() {
        databaseService.mainDB.purgeOutstandingWrites()
    }
    
    func test_add_check_delete() {
        let promise = expectation(description: "addTask")
        let deletePromise = expectation(description: "deleteTask")
        let taskPromise = expectation(description: "tasks affter add")
        let taskAfterDeletePromise = expectation(description: "tasks after delete")
        let testUuid = "TEST_ADD_DELETE_USER"
        let n = 5
        
        promise.expectedFulfillmentCount = n
        deletePromise.expectedFulfillmentCount = n
        
        var emptyData = [Section(model: "Uncompleted", items: []), Section(model: "Completed", items: [])]
        var mockData = [Section(model: "Uncompleted", items: []), Section(model: "Completed", items: [])]
        
        //database.reference().child("users").child(testUuid).removeValue()
        
     
        for i in 1...n {
            let mockTask = TaskModel(
                text: "task",
                createDate: Date.nowWithoutMilisecondes(),
                notificationDate: nil,
                completed: false,
                orderID: i,
                uuid: UUID())
            mockData[0].items.append(mockTask)
        }
        
        let scheduler = TestScheduler(initialClock: 0)
        
        scheduler.scheduleAt(0) {
            for task in mockData[0].items {
                self.databaseService.addTask(task, for: testUuid)
                    .subscribe(onNext: { (result) in
                        if result {
                            promise.fulfill()
                        }
                    }).disposed(by: self.disposeBag)
            }
        }
        
        let result = testScheduler.createObserver([Section].self)
        
        scheduler.scheduleAt(5) {
            self.databaseService.tasks(for: testUuid).take(1).do(onNext: { (_) in
                taskPromise.fulfill()
            }).subscribe(result).disposed(by: self.disposeBag)
        }
        
        guard let fetchElemets = result.events.first?.value.element else {
            XCTFail()
            return
        }
        
        let expected: [Recorded<Event<[Section]>>] = [
            Recorded.next(5, mockData),
            Recorded.completed(5)
        ]
        
        XCTAssertEqual(expected, result.events)

        scheduler.scheduleAt(10) {
            for task in fetchElemets[0].items {
                self.databaseService.deleteTask(task, for: testUuid)
                    .subscribe(onNext: { (result) in
                        if result {
                            deletePromise.fulfill()
                        }
                    }).disposed(by: self.disposeBag)
            }
        }
        
        let resultAfterDelete = testScheduler.createObserver([Section].self)
        scheduler.scheduleAt(15) {
            self.databaseService.tasks(for: testUuid).take(1).do(onNext: { (sections) in
                taskAfterDeletePromise.fulfill()
            }).subscribe(resultAfterDelete).disposed(by: self.disposeBag)
        }

        scheduler.start()
        wait(for: [promise, taskPromise, deletePromise, taskAfterDeletePromise], timeout: 5)
        scheduler.stop()
        
        
    }
    
//    func test_tasks() {
//        var count = 0
//        let n = 6
//        let testUuid = "TEST_USER"
//        let taskPromise = expectation(description: "tasks")
//
//        let result = testScheduler.createObserver([Section].self)
//
//        let taskScheduler = TestScheduler(initialClock: 0)
//        taskScheduler.scheduleAt(0) {
//            self.databaseService.tasks(for: testUuid).do(onNext: { (sections) in
//                count = sections[0].items.count
//                taskPromise.fulfill()
//            }).subscribe(result).disposed(by: self.disposeBag)
//        }
//
//        taskScheduler.start()
//        wait(for: [taskPromise], timeout: 5)
//        taskScheduler.stop()
//        XCTAssert(result.events.first?.value.element?.isEmpty == false)
//        XCTAssert(count == n)
//    }
    
    func test_editTask() {
        let promise = expectation(description: "edit")
        let testUuid = "TEST_EDIT_USER_"
        var text = ""
        testScheduler.scheduleAt(0) {
            var mockData = TaskModel()
            mockData.text = "NOT_EDIT_TEXT"
            let editTaskUuid = mockData.uuid
            
            self.databaseService.addTask(mockData, for: testUuid)
                .flatMap({ (_) -> Observable<Bool> in
                    self.databaseService.editTask(mockData, editItems: [["text": "EDIT_TEXT"]], for: testUuid)
                }).flatMap({ (_) -> Observable<[Section]> in
                    self.databaseService.tasks(for: testUuid)
                }).subscribe(onNext: { (section) in
                    if let editTask = section[0].items.first(where: { (task) -> Bool  in
                        return task.uuid == editTaskUuid
                    }) {
                        text = editTask.text
                        self.databaseService.deleteTask(editTask, for: testUuid).subscribe().dispose()
                        promise.fulfill()
                    }
                }).disposed(by: self.disposeBag)
        }
        testScheduler.start()
        wait(for: [promise], timeout: 5)
        testScheduler.stop()
        XCTAssert(text == "EDIT_TEXT")
    }
    
    
    func test_getUserID() {
        var userUUID_1 = ""
        var userUUID_2 = ""
        let userID = "TEST_USER_ID"
        let promise_1 = expectation(description: "tasks_1")
        let promise_2 = expectation(description: "tasks_2")
        
        
        let uuidScheduler = TestScheduler(initialClock: 0)
        uuidScheduler.scheduleAt(0) {
            self.databaseService.getUserUUID(userID: userID, type: .facebook).subscribe(onNext: { (uuid) in
                userUUID_1 = uuid
                promise_1.fulfill()
            }).disposed(by: self.disposeBag)
        }
        
        uuidScheduler.start()
        wait(for: [promise_1], timeout: 5)
        uuidScheduler.stop()
        
        let uuidScheduler2 = TestScheduler(initialClock: 0)
        uuidScheduler2.scheduleAt(5) {
            self.databaseService.getUserUUID(userID: userID, type: .facebook).subscribe(onNext: { (uuid) in
                userUUID_2 = uuid
                promise_2.fulfill()
            }).disposed(by: self.disposeBag)
        }
        
        uuidScheduler2.start()
        wait(for: [promise_2], timeout: 5)
        uuidScheduler2.stop()
        
        
        XCTAssert(userUUID_1 == userUUID_2)
    }
    
    func test_syncUser() {
        var userUUID = ""
        let newUuid = UUID()
        
        let promise = expectation(description: "tasks")
        
        
        let uuidScheduler = TestScheduler(initialClock: 0)
        uuidScheduler.scheduleAt(0) {
            self.databaseService.syncUserID(newUserID: "TEST_USER", newType: .google, with: newUuid.uuidString).subscribe(onNext: { (result) in
                if result {
                    promise.fulfill()
                } else {
                    XCTFail()
                }
                
            }).disposed(by: self.disposeBag)
        }
        
        uuidScheduler.start()
        wait(for: [promise], timeout: 5)
        uuidScheduler.stop()
        let getPromise = expectation(description: "tasks")
        
        
        let getUuidScheduler = TestScheduler(initialClock: 0)
        getUuidScheduler.scheduleAt(0) {
            self.databaseService.getUserUUID(userID: "TEST_USER", type: .google).subscribe(onNext: { (uuid) in
                userUUID = uuid
                getPromise.fulfill()
            }).disposed(by: self.disposeBag)
        }
        
        getUuidScheduler.start()
        wait(for: [getPromise], timeout: 5)
        getUuidScheduler.stop()
        
        XCTAssert(userUUID == newUuid.uuidString)
    }
    
    func test_getSync() {
        var userUUID = ""
        let newUuid = UUID()
        
        let syncPromise1 = expectation(description: "sync")
        let syncPromise = expectation(description: "sync")
        let promise = expectation(description: "tasks")
        var sync:Bool?
        
        let syncScheduler = TestScheduler(initialClock: 0)
        syncScheduler.scheduleAt(0) {
            self.databaseService.getSync(for: newUuid.uuidString).subscribe(onNext: { (isSync) in
                sync = isSync
                syncPromise1.fulfill()
            }).disposed(by: self.disposeBag)
        }
        
        syncScheduler.start()
        wait(for: [syncPromise1], timeout: 5)
        syncScheduler.stop()
        
        guard sync != nil else {
            XCTFail()
            return
        }
        
        XCTAssert(!sync!)
        sync = nil
        
        let uuidScheduler = TestScheduler(initialClock: 0)
        uuidScheduler.scheduleAt(0) {
            self.databaseService.syncUserID(newUserID: "TEST_USER", newType: .google, with: newUuid.uuidString).subscribe(onNext: { (result) in
                if result {
                    promise.fulfill()
                } else {
                    XCTFail()
                }
                
            }).disposed(by: self.disposeBag)
        }
        
        uuidScheduler.start()
        wait(for: [promise], timeout: 5)
        uuidScheduler.stop()
        let getPromise = expectation(description: "tasks")
        
        
        let getUuidScheduler = TestScheduler(initialClock: 0)
        getUuidScheduler.scheduleAt(0) {
            self.databaseService.getUserUUID(userID: "TEST_USER", type: .google).subscribe(onNext: { (uuid) in
                userUUID = uuid
                getPromise.fulfill()
            }).disposed(by: self.disposeBag)
        }
        
        getUuidScheduler.start()
        wait(for: [getPromise], timeout: 5)
        getUuidScheduler.stop()
        
        XCTAssert(userUUID == newUuid.uuidString)
        
        
        let syncScheduler2 = TestScheduler(initialClock: 0)
        syncScheduler2.scheduleAt(0) {
            self.databaseService.getSync(for: newUuid.uuidString).subscribe(onNext: { (isSync) in
                sync = isSync
                syncPromise.fulfill()
            }).disposed(by: self.disposeBag)
        }
        
        syncScheduler2.start()
        wait(for: [syncPromise], timeout: 5)
        syncScheduler2.stop()
        
        guard sync != nil else {
            XCTFail()
            return
        }
        
        XCTAssert(sync!)
    }
    
    
}

extension Date {
    static func nowWithoutMilisecondes() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH-mm-ss"
        return formatter.date(from: formatter.string(from: Date()))!
    }
}
