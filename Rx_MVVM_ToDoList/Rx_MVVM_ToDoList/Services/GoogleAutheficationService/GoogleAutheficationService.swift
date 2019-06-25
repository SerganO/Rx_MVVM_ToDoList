//
//  GoogleAutheficationService.swift
//  MVVM_ToDoList_Example
//
//  Created by Trainee on 6/24/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import GoogleSignIn
import RxSwift

final class GoogleAutheficationService: NSObject, GIDSignInDelegate, GIDSignInUIDelegate {
    
    private var observer: AnyObserver<GIDGoogleUser?>?
    public let uiActionSubject: PublishSubject<(Bool, UIViewController)>
    
    override init() {
        uiActionSubject = PublishSubject()
        super.init()
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    public func checkLocalGoogleAuthenfication() -> Bool {
        return GIDSignIn.sharedInstance()?.hasAuthInKeychain() ?? false
    }
    
    public func googleAuthenfication(force: Bool = false) -> Observable<GIDGoogleUser?> {
        return Observable.create({ (observer) -> Disposable in
            self.observer = observer
            if force {
                GIDSignIn.sharedInstance().signIn()
            }
            return Disposables.create()
        })
    }
    
    // MARK: - GIDSignInDelegate
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let observer = observer else { return }
        guard error == nil else {
            observer.onError(error)
            return
        }
        observer.onNext(user)
    }
    
    // MARK: - GIDSignInUIDelegate

    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        uiActionSubject.onNext((true, viewController))
    }

    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        uiActionSubject.onNext((false, viewController))
    }
    
}
