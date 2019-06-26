//
//  Scene.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/12/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import UIKit

enum Scene {

    case navigation(NavigationViewModel)
    case splash(SplashViewModel)
    case login(LoginViewModel)
    case tasksList(TasksListViewModel)
    
//    case addTask(AddTaskViewModel)
//    case date(DateViewModel)
}


extension Scene: SceneType {
    
    public func viewController() -> UIViewController {
        switch self {
            
        case .navigation (let viewModel):
            return NavigationController(viewModel: viewModel)
            
        case .splash(let viewModel):
            return SplashViewController(viewModel: viewModel)
            
        case .login(let viewModel):
            return LoginViewController(viewModel: viewModel)

        
        case .tasksList(let viewModel):
            return TasksListViewController(viewModel: viewModel)
//            
//        case .addTask(let viewModel):
//            return AddTaskViewController(viewModel: viewModel)
//            
//        case .navigation (let viewModel):
//            return NavigationController(viewModel: viewModel)
//            
//        case .date(let viewModel):
//            return DateViewController(viewModel: viewModel)
//            
            
        }
        
    }
}
