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
        if services.userService.isExistsCredentials() && Reachability.isConnectedToNetwork() {
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
        services.sceneCoordinator.transition(to: Scene.tasksList(TasksListViewModel(services: self.services, user: user)), type: .push, animated: true)
    }
    
}
