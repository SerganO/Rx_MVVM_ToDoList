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
        database.goOffline()
    }
    
    override func tearDown() {
        database.purgeOutstandingWrites()
    }
    
    func test_add_check_delete() {
        let promise = expectation(description: "add")
        let deletePromise = expectation(description: "delete")
        let taskPromise = expectation(description: "tasks")
        let taskAfterDeletePromise = expectation(description: "tasks")
        let testUuid = "TEST_ADD_DELETE_USER"
        let n = 5
        var section: [Section]?
        
        promise.expectedFulfillmentCount = n
        deletePromise.expectedFulfillmentCount = n
        
        var tasksGet = false
        var count = 0
        var emptyData = [Section(model: "Uncompleted", items: []), Section(model: "Completed", items: [])]
        var mockData = [Section(model: "Uncompleted", items: []), Section(model: "Completed", items: [])]
        
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
                self.databaseService.addTask(task, for: testUuid)
                    .subscribe(onNext: { (result) in
                        if result {
                            //promise.fulfill()
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
        
        let taskAfterDeleteScheduler = TestScheduler(initialClock: 0)
        taskAfterDeleteScheduler.scheduleAt(15) {
            self.databaseService.tasks(for: testUuid).do(onNext: { (sections) in
                count = sections[0].items.count
                section = sections
                taskAfterDeletePromise.fulfill()
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
    
}
