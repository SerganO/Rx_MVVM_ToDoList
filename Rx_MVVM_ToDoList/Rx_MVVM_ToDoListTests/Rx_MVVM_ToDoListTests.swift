//
//  Rx_MVVM_ToDoListTests.swift
//  Rx_MVVM_ToDoListTests
//
//  Created by Trainee on 6/25/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import Rx_MVVM_ToDoList

class Rx_MVVM_ToDoListTests: XCTestCase {
    var databaseService: DatabaseService!
    var testScheduler = TestScheduler(initialClock: 0)
    let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        databaseService = FirebaseDatabaseService()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testAddDeleteTask() {
        
        let promise = expectation(description: "Test parsing")
        let n = 5
        let testUuid = "TEST_ADD_USER"
        promise.expectedFulfillmentCount = n
        testScheduler.scheduleAt(0) {
            var mockData = [TaskModel]()
            
            for i in 1...n {
                let mockTask = TaskModel(
                    text: "task",
                    createDate: Date(),
                    notificationDate: nil,
                    completed: false,
                    orderID: i,
                    uuid: UUID())
                mockData.append(mockTask)
            }
            
            
            for task in mockData {
                self.databaseService.addTask(task,for: testUuid ).subscribe(onNext: { (_) in
                    self.databaseService.deleteTask(task, for: testUuid).subscribe().dispose()
                    promise.fulfill()
                }).disposed(by: self.disposeBag)
            }
            
        }
        testScheduler.start()
        wait(for: [promise], timeout: 5)
        testScheduler.stop()
        
    }
    
    func test_tasks() {
        var count = 0
        let n = 6
        let testUuid = "TEST_USER"
        let taskPromise = expectation(description: "tasks")
        taskPromise.expectedFulfillmentCount = n
        
        let result = testScheduler.createObserver([Section].self)
        
        let taskScheduler = TestScheduler(initialClock: 0)
        taskScheduler.scheduleAt(5) {
            self.databaseService.tasks(for: testUuid).do(onNext: { (sections) in
                count = sections[0].items.count
                taskPromise.fulfill()
            }).subscribe(result).disposed(by: self.disposeBag)
        }
        
        taskScheduler.start()
        wait(for: [taskPromise], timeout: 5)
        taskScheduler.stop()
        XCTAssert(count == n)
    }
    
    func test_editTask() {
        let promise = expectation(description: "Test parsing")
        let testUuid = "TEST_EDIT_USER"
        var text = ""
        testScheduler.scheduleAt(0) {
            let mockData = TaskModel()
            let editTaskUuid = mockData.uuid
            var dataGeted = false
            self.databaseService.addTask(mockData, for: testUuid ).subscribe(onNext: { (_) in
                self.databaseService.editTask(mockData, editItems: [["text": "EDIT_TEST"]], for: testUuid).subscribe(onNext: { (_) in
                    self.databaseService.tasks(for: testUuid).subscribe(onNext: { (section) in
                        guard !dataGeted else { return }
                        if let editTask = section[0].items.first(where: { (task) -> Bool  in
                            return task.uuid == editTaskUuid
                        }) {
                            text = editTask.text
                            dataGeted = true
                            self.databaseService.deleteTask(editTask, for: testUuid).subscribe().dispose()
                            promise.fulfill()
                        }
                    }).disposed(by: self.disposeBag)
                }).disposed(by: self.disposeBag)
            }).disposed(by: self.disposeBag)
            
            
        }
        testScheduler.start()
        wait(for: [promise], timeout: 10)
        testScheduler.stop()
        XCTAssert(text == "EDIT_TEST")
    }
    
    
}
