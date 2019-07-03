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
    var databaseService: DatabaseService!
    var testScheduler = TestScheduler(initialClock: 0)
    let disposeBag = DisposeBag()
    let database = Database.database()
    
    
    override func setUp() {
        super.setUp()
        
        databaseService = FirebaseDatabaseService()
        database.reference().keepSynced(true)
        database.goOffline()
    }
    
    override func tearDown() {
        database.purgeOutstandingWrites()
    }
    
    func test_add_check_delete() {
        let promise = expectation(description: "add")
        let deletePromise = expectation(description: "delete")
        let taskPromise = expectation(description: "tasks affter add")
        let taskAfterDeletePromise = expectation(description: "tasks after delete")
        let testUuid = "TEST_ADD_DELETE_USER"
        let n = 5
        var section: [Section]?
        
        promise.expectedFulfillmentCount = n
        deletePromise.expectedFulfillmentCount = n
        
        var tasksGet = false
        var count = 0
        var emptyData = [Section(model: "Uncompleted", items: []), Section(model: "Completed", items: [])]
        var mockData = [Section(model: "Uncompleted", items: []), Section(model: "Completed", items: [])]
        
        database.reference().child("users").child(testUuid).removeValue()
        
        for i in 1...n {
            let mockTask = TaskModel(
                text: "task",
                createDate: Date(),
                notificationDate: nil,
                completed: false,
                orderID: i,
                uuid: UUID())
            mockData[0].items.append(mockTask)
        }
        
        let addTaskScheduler = TestScheduler(initialClock: 0)
        let deleteTaskScheduler = TestScheduler(initialClock: 0)
        
        addTaskScheduler.scheduleAt(0) {
            for task in mockData[0].items {
                self.databaseService.addTask(task, for: testUuid)
                    .subscribe(onNext: { (result) in
                        if result {
                            promise.fulfill()
                        }
                    }).disposed(by: self.disposeBag)
            }
        }
        addTaskScheduler.start()
        wait(for: [promise], timeout: 5)
        addTaskScheduler.stop()
        
        let result = testScheduler.createObserver([Section].self)
        
        let taskScheduler = TestScheduler(initialClock: 0)
        taskScheduler.scheduleAt(5) {
            self.databaseService.tasks(for: testUuid).do(onNext: { (sections) in
                if !tasksGet {
                    count = sections[0].items.count
                    section = sections
                    taskPromise.fulfill()
                    tasksGet = true
                }
            }).subscribe(result).disposed(by: self.disposeBag)
        }
        
        taskScheduler.start()
        wait(for: [taskPromise], timeout: 5)
        taskScheduler.stop()
        print("count after add: \(count)")
        XCTAssert(count == n)
        guard section != nil else {
            XCTFail()
            return
        }
        XCTAssert(section![0].items == mockData[0].items)
        XCTAssert(section![1].items == mockData[1].items)
        section = nil

        deleteTaskScheduler.scheduleAt(10) {
            for task in mockData[0].items {
                self.databaseService.deleteTask(task, for: testUuid)
                    .subscribe(onNext: { (result) in
                        if result {
                            deletePromise.fulfill()
                        }
                    }).disposed(by: self.disposeBag)
            }
        }
        deleteTaskScheduler.start()
        wait(for: [deletePromise], timeout: 5)
        deleteTaskScheduler.stop()
        
        let resultAfterDelete = testScheduler.createObserver([Section].self)
        var taskAfterDeleteGet = false
        let taskAfterDeleteScheduler = TestScheduler(initialClock: 0)
        taskAfterDeleteScheduler.scheduleAt(15) {
            self.databaseService.tasks(for: testUuid).do(onNext: { (sections) in
                if !taskAfterDeleteGet {
                    count = sections[0].items.count
                    section = sections
                    taskAfterDeletePromise.fulfill()
                    taskAfterDeleteGet = true
                }
                
            }).subscribe(resultAfterDelete).disposed(by: self.disposeBag)
        }
        
        taskAfterDeleteScheduler.start()
        wait(for: [taskAfterDeletePromise], timeout: 5)
        taskAfterDeleteScheduler.stop()
        print("count after delete: \(count)")
        XCTAssert(count == 0)
        
        guard section != nil else {
            XCTFail()
            return
        }
        
        XCTAssert(section![0].items == emptyData[0].items)
        XCTAssert(section![1].items == emptyData[1].items)
    }
    
    func test_tasks() {
        var count = 0
        let n = 6
        let testUuid = "TEST_USER"
        let taskPromise = expectation(description: "tasks")
        
        let result = testScheduler.createObserver([Section].self)
        
        let taskScheduler = TestScheduler(initialClock: 0)
        taskScheduler.scheduleAt(0) {
            self.databaseService.tasks(for: testUuid).do(onNext: { (sections) in
                count = sections[0].items.count
                taskPromise.fulfill()
            }).subscribe(result).disposed(by: self.disposeBag)
        }
        
        taskScheduler.start()
        wait(for: [taskPromise], timeout: 5)
        taskScheduler.stop()
        XCTAssert(result.events.first?.value.element?.isEmpty == false)
        XCTAssert(count == n)
    }
    
    func test_editTask() {
        let promise = expectation(description: "edit")
        let testUuid = "TEST_EDIT_USER"
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
        var userUUID = ""
        
        let promise = expectation(description: "tasks")
        
        
        let uuidScheduler = TestScheduler(initialClock: 0)
        uuidScheduler.scheduleAt(0) {
            self.databaseService.getUserUUID(userID: "237562803869957", type: .facebook).subscribe(onNext: { (uuid) in
                userUUID = uuid
                promise.fulfill()
            }).disposed(by: self.disposeBag)
        }
        
        uuidScheduler.start()
        wait(for: [promise], timeout: 5)
        uuidScheduler.stop()
        
        
        XCTAssert(userUUID == "4120D5E7-6EFF-4486-9C45-457408F8A0B5")
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
        var sync: Bool?
        
        let promise = expectation(description: "tasks")
        
        
        let syncScheduler = TestScheduler(initialClock: 0)
        syncScheduler.scheduleAt(0) {
            self.databaseService.getSync(for: "4120D5E7-6EFF-4486-9C45-457408F8A0B5").subscribe(onNext: { (isSync) in
                sync = isSync
                promise.fulfill()
            }).disposed(by: self.disposeBag)
        }
        
        syncScheduler.start()
        wait(for: [promise], timeout: 5)
        syncScheduler.stop()
        
        guard sync != nil else {
            XCTFail()
            return
        }
        
        XCTAssert(sync!)
    }
    
}
