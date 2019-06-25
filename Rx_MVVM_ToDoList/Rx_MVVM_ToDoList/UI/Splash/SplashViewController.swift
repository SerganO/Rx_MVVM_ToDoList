//
//  SplashViewController.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/12/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import UIKit
import SnapKit
import GoogleSignIn
import RxSwift

class SplashViewController: ViewController<SplashViewModel>, GIDSignInUIDelegate {
    
    let Label = UILabel()
    var googleFlowDispose: Disposable?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        Label.textAlignment = .center
        Label.text = "To Do List"
        
        view.addSubview(Label)
        Label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        let ai = UIActivityIndicatorView.init(style: .gray)
        ai.startAnimating()
        ai.center = view.center
        ai.center.y = ai.center.y + 45
        view.addSubview(ai)
        
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
        viewModel.processAutorization()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        googleFlowDispose?.dispose()
    }
    
}
