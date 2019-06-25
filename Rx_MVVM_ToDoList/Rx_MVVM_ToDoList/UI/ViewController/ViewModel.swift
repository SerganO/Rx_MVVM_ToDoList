//
//  ViewModel.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/12/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import RxSwift

class ViewModel {
    let services: Services
    
    init(services: Services) {
        self.services = services
    }
    
}
