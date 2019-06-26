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
    
    let sections: BehaviorRelay<[Section]>
    
    override init(services: Services) {
        self.sections = BehaviorRelay<[Section]>(value: [])
        super.init(services: services)
        
        
    }
    
    
}

