//
//  AddTaskViewModel.swift
//  Rx_MVVM_ToDoList
//
//  Created by Trainee on 6/27/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class AddTaskViewModel: ViewModel {
    
    var taskForEdit: TaskModel?
    var task: BehaviorRelay<TaskModel>
    let disposeBag = DisposeBag()
    var notificationDate = BehaviorRelay<Date>(value: Date())
    
    
    func createTask(_ text: String) -> TaskModel {
        
        var task = TaskModel()
        
        task.text = text
        
        print("Task Create")
        print(task.toDic())
        return task
    }
    
    func acceptTask(_ task: TaskModel) {
        self.task.accept(task)
    }
    
    init(services: Services, task: BehaviorRelay<TaskModel>) {
        self.task = task
        super.init(services: services)
    }
    
    init(services: Services, task: BehaviorRelay<TaskModel>, taskForEdit: TaskModel) {
        self.task = task
        super.init(services: services)
        self.taskForEdit = taskForEdit
    }
    
}
