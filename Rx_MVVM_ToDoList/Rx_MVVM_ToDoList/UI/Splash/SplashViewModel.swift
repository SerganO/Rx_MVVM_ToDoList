//
//  SplashViewModel.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/12/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import UIKit
import RxSwift

class SplashViewModel: ViewModel {
    
    let disposeBag = DisposeBag()
    
    func processAutorization() {
        if services.userService.isExistsCredentials() {
            services.userService.actualUserToken(true).subscribe(onNext: { (user) in
                self.navigateToTasksWithUser(user)
            }).disposed(by: disposeBag)
        } else {
            navigateToLogin()
        }
    }
    
    func navigateToLogin() {
        let model = LoginViewModel(services: services)
        let scene = Scene.login(model)
        services.sceneCoordinator.transition(to: scene, type: .push, animated: true)
    }
    
    func navigateToTasksWithUser(_ user: UserToken) {
        print("navigateToTasks")
        print(user.uuid)
        //       let loginModel = LoginViewModel(services: services)
        //       let loginController = LoginViewController(viewModel: loginModel)
        //        let taskModel = TasksListViewModel(services: services, user: user)
        //        let taskController = TasksListViewController(viewModel: taskModel)
        //        let navigation = self.services.sceneCoordinator.currentViewController.navigationController
        //
        //        var controllers = navigation?.viewControllers
        //        controllers?.append(loginController)
        //        controllers?.append(taskController)
        //        if controllers != nil {
        //            navigation?.setViewControllers(controllers!, animated: true)
        //        }
        
        //        let logModel = LoginViewModel(services: services)
        //        let logScene = Scene.login(logModel)
        //        services.sceneCoordinator.transition(to: logScene, type: .push, animated: true)
        
        
        
        
//        let model = TasksListViewModel(services: services, user: user)
//        let scene = Scene.tasksList(model)
//        services.sceneCoordinator.transition(to: scene, type: .push, animated: true)
        
        //services.sceneCoordinator.transition(to: Scene.login(LoginViewModel(services: self.services)), type: .push, animated: true)
        services.sceneCoordinator.transition(to: Scene.tasksList(TasksListViewModel(services: self.services, user: user)), type: .push, animated: true)
        
        
        //       let loginModel = LoginViewModel(services: services)
        //       let loginController = LoginViewController(viewModel: loginModel)
//        let loginModel = LoginViewModel(services: services)
//        let loginController = LoginViewController(viewModel: loginModel)
//        let navigation = self.services.sceneCoordinator.currentViewController.navigationController
//        guard navigation != nil else { return }
//        let stackCount = navigation!.viewControllers.count
//        let addIndex = stackCount - 1
//        navigation!.viewControllers.insert(loginController, at: addIndex)
    }
    
}
