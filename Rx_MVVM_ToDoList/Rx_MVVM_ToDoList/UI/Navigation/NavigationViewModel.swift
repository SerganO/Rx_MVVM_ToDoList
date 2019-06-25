//
//  NavigationViewModel.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/12/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation

class NavigationViewModel: ViewModel {
    let root: Scene
    
    init(services: Services, root: Scene) {
        self.root = root
        super.init(services: services)
    }
}
