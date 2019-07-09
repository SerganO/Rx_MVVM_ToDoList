//
//  Section.swift
//  Rx_MVVM_ToDoList
//
//  Created by Serhii Ostrovetskyi on 7/9/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation

struct Section: Equatable {
    var title: String
    var items: [TaskModel]
    
    init() {
        title = ""
        items = []
    }
    
    init(title: String, items: [TaskModel]) {
        self.title = title
        self.items = items
    }
    
}
