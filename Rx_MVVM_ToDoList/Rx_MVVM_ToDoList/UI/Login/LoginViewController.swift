//
//  LoginViewController.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/18/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import FacebookLogin
import GoogleSignIn
import RxSwift

class LoginViewController: ViewController<LoginViewModel> {
    
    var googleFlowDispose: Disposable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.hidesBackButton = true
        
        
        configureFacebookButton()
        configureGoogleSignInButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        googleFlowDispose = viewModel.services.userService.authorizationWithGoogleFlow().subscribe(onNext: { [weak self] (arg) in
            guard let self = self else { return }
            let (isShown, vc) = arg
            if isShown {
                self.present(vc, animated: true)
            } else {
                vc.dismiss(animated: true)
            }
        })
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        googleFlowDispose?.dispose()
    }
    
    func configureFacebookButton() {
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        loginButton.loginBehavior = .web
        loginButton.center = view.center
        loginButton.center.y += 50
        view.addSubview(loginButton)
        loginButton.delegate = viewModel.services.userService.getFacebookButtonDelegate()
    }
    
    func configureGoogleSignInButton() {
        let googleSignInButton = GIDSignInButton()
        googleSignInButton.frame = CGRect(x: view.frame.width/2-100, y: view.frame.height/2-25, width: 200, height: 50)
        view.addSubview(googleSignInButton)
    }
    
    
}
