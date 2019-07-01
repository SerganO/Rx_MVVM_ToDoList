//
//  UserToken.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/20/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import RxCocoa

struct UserToken {
    var userID = ""
    var uuid = ""
    var idType: IDType
    
    init() {
        userID = ""
        uuid = ""
        idType = .none
    }
}
