//
//  UserService.swift
//  MVVM_ToDoList_Example
//
//  Created by Trainee on 6/24/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import RxSwift
import FacebookLogin

protocol UserService {
    
    func isExistsCredentials() -> Bool
    
    func actualUserToken(_ force: Bool) -> Observable<UserToken>
    
    func authorizationWithGoogleFlow() -> Observable<(Bool, UIViewController)>
    
    func getFacebookButtonDelegate() -> LoginButtonDelegate
    
    func clearData()
    
    func sync() -> Observable<Bool>
}
