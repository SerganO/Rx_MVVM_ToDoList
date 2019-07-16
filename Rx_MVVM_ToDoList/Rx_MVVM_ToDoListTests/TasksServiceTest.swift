//
//  TasksServiceTest.swift
//  TasksServiceTest
//
//  Created by Trainee on 7/2/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import Foundation
import Firebase
@testable import Rx_MVVM_ToDoList

class TasksServiceTest: XCTestCase {
    var databaseService: FirebaseDatabaseService!
    var tasksService: TasksService!
    var testScheduler = TestScheduler(initialClock: 0)
    let disposeBag = DisposeBag()
    
    
    override func setUp() {
        super.setUp()
        
        databaseService = FirebaseDatabaseService(launchInTestMode: true)
        tasksService = TDLTasksService(database: databaseService)
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
        databaseService.mainRef.child("users").child(testUuid).removeValue()
        let n = 5
        
        promise.expectedFulfillmentCount = n
        deletePromise.expectedFulfillmentCount = n
        
        let emptyData = [Section(title: "Uncompleted", items: []), Section(title: "Completed", items: [])]
        var mockData = [Section(title: "Uncompleted", items: []), Section(title: "Completed", items: [])]
        
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
                self.tasksService.addTask(task, for: testUuid)
                    .subscribe(onNext: { (result) in
                        if result {
                            promise.fulfill()
                            print("---- ADD ---- \(Date().timeIntervalSinceReferenceDate)")
                        }
                    }).disposed(by: self.disposeBag)
            }
        }
        
        scheduler.start()
        wait(for: [promise], timeout: 5)
        scheduler.stop()
        
        let result = scheduler.createObserver([Section].self)
        
        scheduler.scheduleAt(100) {
            self.tasksService.tasks(for: testUuid).take(1).do(onNext: { (tasks) in
                taskPromise.fulfill()
                print("---- TASKS ADD ---- \(Date().timeIntervalSinceReferenceDate)")
                print(tasks)
                
            }).subscribe(result).disposed(by: self.disposeBag)
        }
        
        scheduler.start()
        wait(for: [taskPromise], timeout: 5)
        scheduler.stop()
        
        scheduler.scheduleAt(200) {
            for task in mockData[0].items {
                self.tasksService.deleteTask(task, for: testUuid)
                    .subscribe(onNext: { (result) in
                        if result {
                            deletePromise.fulfill()
                            print("---- DELETE ---- \(Date().timeIntervalSinceReferenceDate)")
                        }
                    }).disposed(by: self.disposeBag)
            }
        }
        
        scheduler.start()
        wait(for: [deletePromise], timeout: 5)
        scheduler.stop()
        
        let resultAfterDelete = scheduler.createObserver([Section].self)
        scheduler.scheduleAt(300) {
            self.tasksService.tasks(for: testUuid).take(1).do(onNext: { (sections) in
                print("---- TASKS DELETE ---- \(Date().timeIntervalSinceReferenceDate)")
                print(sections)
                taskAfterDeletePromise.fulfill()
            }).subscribe(resultAfterDelete).disposed(by: self.disposeBag)
        }
        
        scheduler.start()
        wait(for: [taskAfterDeletePromise], timeout: 5)
        scheduler.stop()
        
        
        let expected: [Recorded<Event<[Section]>>] = [
            Recorded.next(100, mockData),
            Recorded.completed(100)
        ]
        
        let expectedAfterDelete: [Recorded<Event<[Section]>>] = [
            Recorded.next(300, emptyData),
            Recorded.completed(300)
        ]
        
        XCTAssertEqual(expected, result.events)
        XCTAssertEqual(expectedAfterDelete, resultAfterDelete.events)
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
//            self.tasksService.tasks(for: testUuid).do(onNext: { (sections) in
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
        let testUuid = "TASK_TEST_EDIT_USER"
        var text = ""
        testScheduler.scheduleAt(0) {
            var mockData = TaskModel()
            mockData.text = "NOT_EDIT_TEXT"
            let editTaskUuid = mockData.uuid
            
            self.tasksService.addTask(mockData, for: testUuid)
                .flatMap({ (_) -> Observable<Bool> in
                    self.tasksService.editTask(mockData, editItems: [["text": "EDIT_TEXT"]], for: testUuid)
                }).flatMap({ (_) -> Observable<[Section]> in
                    self.tasksService.tasks(for: testUuid)
                }).subscribe(onNext: { (section) in
                    if let editTask = section[0].items.first(where: { (task) -> Bool  in
                        return task.uuid == editTaskUuid
                    }) {
                        text = editTask.text
                        self.tasksService.deleteTask(editTask, for: testUuid).subscribe().dispose()
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
