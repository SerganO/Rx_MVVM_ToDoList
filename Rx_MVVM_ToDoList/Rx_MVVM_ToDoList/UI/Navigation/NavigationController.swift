//
//  NavigationController.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/12/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import UIKit
import RxSwift
class NavigationController: UINavigationController {
    
    var viewModel: NavigationViewModel!
    
    init(viewModel: NavigationViewModel) {
        self.viewModel = viewModel
        
        super.init(rootViewController: viewModel.root.viewController())
        
        self.viewModel = viewModel
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    
}
