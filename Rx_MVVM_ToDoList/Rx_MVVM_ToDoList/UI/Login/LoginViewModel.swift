//
//  LoginViewModel.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/18/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import RxSwift

class LoginViewModel: ViewModel {
    
    let disposeBag = DisposeBag()
    
    override init(services: Services) {
        super.init(services: services)
        
        services.userService.actualUserToken(false).subscribe(onNext: { [weak self] (user) in
            guard let self = self else { return }
            print(user)
            self.navigateToTask(with: user)
        }).disposed(by: disposeBag)
    }
    
    func navigateToTask(with user: UserToken) {
        print("navigateToTask")
        print(user)
        
        let model = TasksListViewModel(services: services, user: user)
        let scene = Scene.tasksList(model)
        services.sceneCoordinator.transition(to: scene, type: .push, animated: true)
    }
    
}
