//
//  FacebookAutheficationService.swift
//  MVVM_ToDoList_Example
//
//  Created by Trainee on 6/25/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FacebookLogin
import FacebookCore
import RxSwift

final class FacebookAutheficationService: LoginButtonDelegate {

    private var observer: AnyObserver<AccessToken>?
    
    public func checkLocalFacebookAuthenfication() -> Bool {
        return FBSDKAccessToken.currentAccessTokenIsActive()
    }
    
    public func facebookAuthenfication() -> Observable<AccessToken> {
        return Observable.create({ (observer) -> Disposable in
            if let accessToken = FBSDKAccessToken.current(), FBSDKAccessToken.currentAccessTokenIsActive() {
                let a = AccessToken(appId: accessToken.appID, authenticationToken: accessToken.tokenString, userId: accessToken.userID, refreshDate: accessToken.refreshDate, expirationDate: accessToken.expirationDate, grantedPermissions: nil, declinedPermissions: nil)
                observer.onNext(a)
            }
            self.observer = observer
            return Disposables.create()
        })
    }
    
    // MARK: - LoginButtonDelegate
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        guard let observer = observer else { return }
        switch result {
        case .success(_, _, let token):
            observer.onNext(token)
            
        case .failed(let error):
            observer.onError(error)
            
        default:
            break
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        fatalError("Not implemented")
    }
    
}
