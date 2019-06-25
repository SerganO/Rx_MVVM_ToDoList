//
//  User.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/20/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import RxCocoa


class User {
    var IDs = userIDs()
    var uuid = ""//BehaviorRelay<String>(value: "")
    var sync = false
    
}
