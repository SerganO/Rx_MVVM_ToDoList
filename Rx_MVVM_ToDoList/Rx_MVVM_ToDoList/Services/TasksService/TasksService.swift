//
//  TasksService.swift
//  Rx_MVVM_ToDoList
//
//  Created by Trainee on 6/27/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import RxSwift

protocol TasksService {
    func tasks(for userID: String) -> Observable<[Section]>
    func addTask(_ task: TaskModel, for userID: String) -> Observable<Bool>
    func editTask(_ task: TaskModel, editItems:[[String: Any]], for userID: String) -> Observable<Bool>
    func deleteTask( _ task: TaskModel, for userID: String) -> Observable<Bool>
}
