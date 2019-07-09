//
//  TasksListViewModel.swift
//  Rx_MVVM_ToDoList
//
//  Created by Trainee on 6/26/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

typealias Section = SectionModel<String, TaskModel>

class TasksListViewModel: ViewModel {
    
    let disposeBag = DisposeBag()
    let sections: BehaviorRelay<[Section]>
    var currentUser: UserToken
    
    init(services: Services, user: UserToken) {
        
        
        currentUser = user
        sections = BehaviorRelay<[Section]>(value: [])
        super.init(services: services)
        services.tasksService.tasks(for: user.uuid).bind(to: sections).disposed(by: disposeBag)
        services.tasksService.tasks(for: user.uuid).subscribe({ (tasks) in
            if let tasks = tasks.element {
                services.notificationService.syncNotification(for: tasks[0].items)
            }
        }).disposed(by: disposeBag)
    }
    
    static func configureTaskCell(_ task:TaskModel, cell: TaskCell) {
        cell.taskTextLabel.text = task.text
        cell.taskCompletedImageView.image = task.completed ? #imageLiteral(resourceName: "Complete") : #imageLiteral(resourceName: "Uncomplete")
    }
    
    func updateId() {
        for section in sections.value {
            var i = 0
            for task in section.items {
                services.tasksService.editTask(task, editItems: [["orderID":i ]], for: self.currentUser.uuid).subscribe(onNext: { (_) in
                }).disposed(by: disposeBag)
                i = i + 1
            }
        }
    }
    
    func selectCell(_ cell: TaskCell, indexPath: IndexPath) {
        var task = sections.value[indexPath.section].items[indexPath.row]
        task.orderID = -1
        var value = sections.value
        value[indexPath.section].items.remove(at: indexPath.row)
        let sect = indexPath.section == 0 ? 1 : 0
        value[sect].items.insert(task, at: 0)
        sections.accept(value)
        task.completed = !task.completed
        task.createDate = Date.nowWithoutMilisecondes()
        services.notificationService.addNotificationIfNeeded(for: task)
        TasksListViewModel.configureTaskCell(task, cell: cell)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.dateFormat = "dd-MM-yyyy HH-mm-ss"
        services.tasksService.editTask(task, editItems: [["completed":task.completed ? 1 : 0],["createDate":formatter.string(from: Date())]], for: self.currentUser.uuid).subscribe(onNext: { (result) in
            if result {
                self.updateId()
            }
        }).disposed(by: disposeBag)
    }
    
    
    func addTask() {
        print("ADD")
        let task = TaskModel()
        let taskRelay = BehaviorRelay<TaskModel>.init(value: task)
        
        services.sceneCoordinator.transition(to: Scene.addTask(AddTaskViewModel(services: services, task: taskRelay)), type: .push, animated: true)
        
        taskRelay.bind { (newTask) in
            guard newTask != task else { return }
            
            self.services.tasksService.addTask(newTask, for: self.currentUser.uuid).subscribe(onNext: { (result) in
                if result {
                    self.updateId()
                }
            }).disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
    }
    
    func editTask(_ taskForEdit : TaskModel) {
        print("Edit")
        let task = BehaviorRelay<TaskModel>.init(value: TaskModel())
        services.sceneCoordinator.transition(to: Scene.addTask(AddTaskViewModel(services: services,task: task, taskForEdit: taskForEdit)), type: .push, animated: true)
        task.bind { (task) in
            guard task.text != "" else { return }
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            formatter.dateFormat = "dd-MM-yyyy HH-mm-ss"
            
            
                self.services.tasksService.editTask(task, editItems: [
                    ["text": task.text],
                    ["orderID": -1],
                    ["createDate": formatter.string(from: Date())]
                    ], for: self.currentUser.uuid).subscribe(onNext: { (_) in
                    }).disposed(by: self.disposeBag)
                
                if let notDate = task.notificationDate {
                    self.services.tasksService.editTask(task, editItems: [
                        ["notificationDate": formatter.string(from: notDate)]
                        ], for:  self.currentUser.uuid).subscribe(onNext: { (_) in
                        }).disposed(by: self.disposeBag)
                } else {
                    self.services.tasksService.editTask(task, editItems: [
                        ["notificationDate": ""]
                        ], for:  self.currentUser.uuid).subscribe(onNext: { (_) in
                        }).disposed(by: self.disposeBag)
                }
            self.updateId()
            }.disposed(by: disposeBag)
    }
    
    func deleteTask(_ task: TaskModel, indexPath: IndexPath) {
        print("Delete")
        services.tasksService.deleteTask(task, for: currentUser.uuid).subscribe(onNext: { (_) in
        }).disposed(by: disposeBag)
        var value = sections.value
        value[indexPath.section].items.remove(at: indexPath.row)
        sections.accept(value)
    }
    
}

