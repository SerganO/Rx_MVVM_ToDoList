//
//  TDLUserService.swift
//  MVVM_ToDoList_Example
//
//  Created by Trainee on 6/25/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import RxSwift
import FacebookLogin



final class TDLUserService: UserService {
    
    
    private var googleService: GoogleAutheficationService
    private var facebookService: FacebookAutheficationService
    private var databaseServise: DatabaseService
    private var currentUser: UserToken?
    private let disposeBag = DisposeBag()
    
    init(googleAuthenficationService: GoogleAutheficationService, facebookAuthenficationService: FacebookAutheficationService, databaseService: DatabaseService) {
        googleService = googleAuthenficationService
        facebookService = facebookAuthenficationService
        self.databaseServise = databaseService
    }
    
    func isExistsCredentials() -> Bool {
        return googleService.checkLocalGoogleAuthenfication() || facebookService.checkLocalFacebookAuthenfication()
    }
    
    func actualUserToken(_ force: Bool) -> Observable<UserToken> {
        
        if let user = currentUser {
            return Observable<UserToken>.just(user)
        }
        
        var observable: Observable<(IDType, String?)>
        
        if googleService.checkLocalGoogleAuthenfication() {
            observable = googleService.googleAuthenfication(force: force).map({ (IDType.google, $0?.userID) })
        } else if facebookService.checkLocalFacebookAuthenfication() {
            observable = facebookService.facebookAuthenfication().map({ (IDType.facebook, $0.userId) })
        } else {
            let google = googleService.googleAuthenfication().map({ (IDType.google, $0?.userID) })
            let facebook = facebookService.facebookAuthenfication().map({ (IDType.facebook, $0.userId) })
            observable = Observable.merge(google,facebook)
        }
        
        return observable
            .filter({ $0.1 != nil })
            .do(onNext: {
                self.currentUser = UserToken()
                self.currentUser?.idType = $0.0
                self.currentUser?.userID = $0.1!
                print( "userID: " + $0.1! + "\n" + "\($0.0 == .google ? "GGGG" : "FFFF" )" )
            }).flatMap({ user in
                return self.databaseServise.getUserUUID(userID: user.1!, type: user.0)
            }).map({ (uuid) in
                self.currentUser?.uuid = uuid
                return self.currentUser!
            })
    }
    
    func authorizationWithGoogleFlow() -> Observable<(Bool, UIViewController)> {
        return googleService.uiActionSubject.asObservable()
    }
    
    func getFacebookButtonDelegate() -> LoginButtonDelegate {
        return facebookService
    }
    
    func clearData() {
        currentUser = nil
    }
    
    func sync() -> Observable<Bool> {
        
        guard let current = currentUser else { return Observable.empty() }
        
        if googleService.checkLocalGoogleAuthenfication() {
            return facebookService.login()
                .filter({ $0.userId != nil })
                .flatMapLatest ({ [databaseServise] (userToken) -> Observable<Bool> in
                    return databaseServise.syncUserID(newUserID: userToken.userId!, newType: .facebook, with: current.uuid)
                })
        } else {
            return googleService.googleAuthenfication(force: true)
                .filter({ $0 != nil })
                .flatMapLatest ({ [databaseServise] (user) -> Observable<Bool> in
                    databaseServise.syncUserID(newUserID: user!.userID, newType: .google, with: current.uuid)
                
            })
        }
    }
}
