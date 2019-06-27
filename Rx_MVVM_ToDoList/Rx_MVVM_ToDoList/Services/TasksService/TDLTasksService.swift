//
//  TDLTasksService.swift
//  Rx_MVVM_ToDoList
//
//  Created by Trainee on 6/27/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TDLTasksService: TasksService {
    
    
    private let database: DatabaseService
    
    init(database: DatabaseService) {
        self.database = database
    }
    
    
    func tasks(for userID: String) -> Observable<[Section]> {
        return database.tasks(for: userID)
    }
    
    func addTask(_ task: TaskModel, for userID: String) -> Observable<Bool> {
        return database.addTask(task, for: userID)
    }
    
    func editTask(_ task: TaskModel, editItems: [[String : Any]], for userID: String) -> Observable<Bool> {
        return database.editTask(task, editItems: editItems, for: userID)
    }
    
    func deleteTask(_ task: TaskModel, for userID: String) -> Observable<Bool> {
        return database.deleteTask(task, for: userID)
    }
    
    
    
    
}
