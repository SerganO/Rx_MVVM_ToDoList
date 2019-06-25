//
//  ViewController.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/11/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import UIKit
import RxSwift

class ViewController<T: ViewModel>: UIViewController {
    
    var viewModel: T
    let disposeBag = DisposeBag()
    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if error == nil {
//            viewModel.services.user.user.IDs.googleID = user.userID
//            viewModel.services.googleAuth.userID = user.userID
//            viewModel.services.user.getUserUUID(userID: self.viewModel.services.user.user.IDs.googleID, type: .google, completion: {
//                (result) in
//                self.viewModel.services.user.completionHandler?(result)
//
//
//            }).bind(to: self.viewModel.services.user.user.uuid).disposed(by: self.disposeBag)
//        }
//    }
    
    init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    
    func setupRx() {
        
    }

}

