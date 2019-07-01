//
//  SceneCoordinator.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/12/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SceneCoordinator: SceneCoordinatorType {
    
    var window: UIWindow
    let disposeBag = DisposeBag()
    
    required init(window: UIWindow) {
        self.window = window
    }
    
    var currentViewController: UIViewController {
        var current = window.rootViewController
        
        if let navigationController = current as? UINavigationController {
            current = navigationController.topViewController
        }
        
        /*if let presented = current?.presentedViewController, !(presented is UISearchController) {
         current = presented
         }*/
        
        if let presented = current?.presentedViewController,
            presented is ViewController {
            current = presented
        }
        
        return current!
    }
    
    static func actualViewController(for viewController: UIViewController) -> UIViewController {
        if let navigationController = viewController as? UINavigationController {
            return navigationController.viewControllers.first!
        } else {
            return viewController
        }
    }
    
    @discardableResult
    func pop(animated: Bool) -> Completable {
        let subject = PublishSubject<Void>()
        if currentViewController.presentingViewController != nil  {
            currentViewController.dismiss(animated: animated) {
                subject.onCompleted()
            }
        } else if let navigationController = currentViewController.navigationController {
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            guard navigationController.popViewController(animated: animated) != nil else {
                return Completable.empty()
            }
        } else {
            return Completable.empty()
        }
        return subject.asObservable()
            .take(1)
            .ignoreElements()
    }
    
    @discardableResult
    func transition(to scene: SceneType, type: SceneTransitionType, animated: Bool) -> Completable {
        let subject = PublishSubject<Void>()
        
        DispatchQueue.main.async {
            self._transition(to: scene, type: type, animated: animated).asObservable().subscribe(onNext: { (_) in
                subject.onNext(())
            }, onError: { (e) in
                subject.onError(e)
            }, onCompleted: {
                subject.onCompleted()
            }).disposed(by: self.disposeBag)
        }
        
        return subject.asObservable().take(1).ignoreElements()
    }
    
    
    @discardableResult
    private func _transition(to scene: SceneType, type: SceneTransitionType, animated: Bool) -> Completable {
        let subject = PublishSubject<Void>()
        let viewController = scene.viewController()
        
        switch type {
            
        case .root:
            viewController.view.frame = UIScreen.main.bounds
            window.rootViewController = viewController
            subject.onCompleted()
        case .push:
            guard let navigationController = currentViewController.navigationController else {
                fatalError("Can't push a view controller without a current navigation controller")
            }
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            navigationController.pushViewController(viewController, animated: animated)
            
        case .modal:
            currentViewController.present(viewController, animated: animated) {
                subject.onCompleted()
            }
        }
        
        return subject.asObservable().take(1).ignoreElements()
        
    }
    
}

