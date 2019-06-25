//
//  SceneCoordinatorType.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/12/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import UIKit
import RxSwift

public protocol SceneCoordinatorType {
    @discardableResult
    func transition(to scene: SceneType, type: SceneTransitionType, animated: Bool) -> Completable
    
    @discardableResult
    func pop(animated: Bool) -> Completable
}

extension SceneCoordinatorType {
    @discardableResult
    func pop() -> Completable {
        return pop(animated: true)
    }
}

