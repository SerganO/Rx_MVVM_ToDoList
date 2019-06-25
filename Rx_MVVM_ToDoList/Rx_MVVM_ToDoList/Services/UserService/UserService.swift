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
    
    func actualUserID(_ force: Bool) -> Observable<String>
    
    func authorizationWithGoogleFlow() -> Observable<(Bool, UIViewController)>
    
    func getFacebookButtonDelegate() -> LoginButtonDelegate
}
