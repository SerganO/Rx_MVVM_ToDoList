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

enum IDType {
    case google
    case facebook
    case none
}

final class TDLUserService: UserService {

    private var googleService: GoogleAutheficationService
    private var facebookService: FacebookAutheficationService
    private var currentUser: User?
    
    init(googleAuthenficationService: GoogleAutheficationService, facebookAuthenficationService: FacebookAutheficationService) {
        googleService = googleAuthenficationService
        facebookService = facebookAuthenficationService
    }
    
    func isExistsCredentials() -> Bool {
        return googleService.checkLocalGoogleAuthenfication() || facebookService.checkLocalFacebookAuthenfication()
    }
    
    func actualUserID(_ force: Bool) -> Observable<String> {
        
        if let user = currentUser {
            return Observable<String>.just(user.uuid)
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
            .do(onNext: { print( "userID: " + $0.1! + "\n" + "\($0.0 == .google ? "GGGG" : "FFFF" )" )
            })
            .map({ user in
                self.currentUser = User()
                self.currentUser?.userID = user.1!
                self.currentUser?.idType = user.0
                self.currentUser?.uuid = UUID().uuidString
                return self.currentUser!.uuid })
        
        
//        return googleService.googleAuthenfication(force: force)
//            .filter({ $0?.userID != nil })
//            .do(onNext: { print( "userID: \(($0?.userID ?? ""))" ) })
//            .map({ _ in UUID().uuidString })
    }
    
    func authorizationWithGoogleFlow() -> Observable<(Bool, UIViewController)> {
        return googleService.uiActionSubject.asObservable()
    }
    
    func getFacebookButtonDelegate() -> LoginButtonDelegate {
        return facebookService
    }
    
}
