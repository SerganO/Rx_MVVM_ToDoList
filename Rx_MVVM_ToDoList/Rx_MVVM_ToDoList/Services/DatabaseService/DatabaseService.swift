//
//  DatabaseService.swift
//  Rx_MVVM_ToDoList
//
//  Created by Trainee on 6/27/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import RxSwift

protocol DatabaseService {
    func tasks(for userID: String) -> Observable<[Section]>
    func addTask(_ task: TaskModel, for userID: String) -> Observable<Bool>
    func editTask(_ task: TaskModel, editItems:[[String: Any]], for userID: String) -> Observable<Bool>
    func deleteTask( _ task: TaskModel, for userID: String) -> Observable<Bool>
    
    func getUserUUID(userID: String, type: IDType) -> Observable<String>
    func syncUserID(newUserID: String, newType: IDType, with uuid: String) -> Observable<Bool>
    func getSync(for uuid:String) -> Observable<Bool>
    
}
