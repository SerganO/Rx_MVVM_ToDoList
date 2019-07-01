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

