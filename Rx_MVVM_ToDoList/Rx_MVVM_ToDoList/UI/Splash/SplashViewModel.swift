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
            services.userService.actualUserID(true).subscribe(onNext: navigateToTasksWithUserID(_:)).disposed(by: disposeBag)
        } else {
            navigateToLogin()
        }
    }
    
    func navigateToLogin() {
        let model = LoginViewModel(services: services)
        let scene = Scene.login(model)
        services.sceneCoordinator.transition(to: scene, type: .push, animated: true)
    }
    
    func navigateToTasksWithUserID(_ identifier: String) {
        print("navigateToTasks")
    }
    
}
