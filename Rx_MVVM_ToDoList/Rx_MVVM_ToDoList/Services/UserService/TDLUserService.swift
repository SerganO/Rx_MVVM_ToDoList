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
}

final class TDLUserService: UserService {

    private var googleService: GoogleAutheficationService
    private var facebookService: FacebookAutheficationService
    
    init(googleAuthenficationService: GoogleAutheficationService, facebookAuthenficationService: FacebookAutheficationService) {
        googleService = googleAuthenficationService
        facebookService = facebookAuthenficationService
    }
    
    func isExistsCredentials() -> Bool {
        return googleService.checkLocalGoogleAuthenfication() || facebookService.checkLocalFacebookAuthenfication()
    }
    
    func actualUserID(_ force: Bool) -> Observable<String> {
        
        var observable: Observable<(IDType, String?)>
        
        if googleService.checkLocalGoogleAuthenfication() {
            observable = googleService.googleAuthenfication(force: force).map({ (IDType.google, $0?.userID) })
        } else {
            observable = facebookService.facebookAuthenfication().map({ (IDType.facebook, $0.userId) })
        }
        
//        let google = googleService.googleAuthenfication(force: force).map({ (IDType.google, $0?.userID) })
//        let facebook = facebookService.facebookAuthenfication().map({ (IDType.facebook, $0.userId) })
        
        return observable
            .filter({ $0.1 != nil })
            .do(onNext: { print( "userID: " + $0.1! + "\n" + "\($0.0 == .google ? "GGGG" : "FFFF" )" ) })
            .map({ _ in UUID().uuidString })
        
        
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
