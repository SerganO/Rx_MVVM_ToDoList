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
    let uuid = "20ACAE44-7220-4DFD-8F4D-028CA874E8D9"
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
    
    func testExample() {
        
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testAddTask() {
        
        let promise = expectation(description: "Test parsing")
        let n = 5
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
                self.databaseService.addTask(task,for: "TEST_USER").subscribe(onNext: { (_) in
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
        
        let taskPromise = expectation(description: "tasks")
        taskPromise.expectedFulfillmentCount = n
        
        let result = testScheduler.createObserver([Section].self)
        
        let taskScheduler = TestScheduler(initialClock: 0)
        taskScheduler.scheduleAt(5) {
            self.databaseService.tasks(for: "TEST_USER").do(onNext: { (sections) in
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
        var text = ""
        testScheduler.scheduleAt(0) {
            let mockData = TaskModel()
            self.databaseService.addTask(mockData, for: "TEST_EDIT_USER").subscribe(onNext: { (_) in
                self.databaseService.editTask(mockData, editItems: [["text": "EDIT_TEST"]], for: "TEST_EDIT_USER").subscribe(onNext: { (_) in
                    self.databaseService.tasks(for: "TEST_EDIT_USER").subscribe(onNext: { (section) in
                        for task in section[0].items {
                            if task.uuid == mockData.uuid {
                                text = task.text
                                promise.fulfill()
                            }
                        }
                    })
                })
            })
            
            
        }
        testScheduler.start()
        wait(for: [promise], timeout: 10)
        testScheduler.stop()
        XCTAssert(text == "EDIT_TEST")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
