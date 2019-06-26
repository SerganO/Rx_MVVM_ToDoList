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
        
        services.userService.actualUserID(false).subscribe(onNext: { [weak self] (userUUID) in
            guard let self = self else { return }
            print(userUUID)
            self.navigateToTask()
        }).disposed(by: disposeBag)
    }
    
    func navigateToTask() {
        let model = TasksListViewModel(services: services)
        let scene = Scene.tasksList(model)
        services.sceneCoordinator.transition(to: scene, type: .push, animated: true)
    }
}
