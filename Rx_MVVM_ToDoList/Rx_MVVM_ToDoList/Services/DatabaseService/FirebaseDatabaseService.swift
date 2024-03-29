//
//  FirebaseDatabaseService.swift
//  Rx_MVVM_ToDoList
//
//  Created by Trainee on 6/27/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

class FirebaseDatabaseService: DatabaseService {
    
    internal let mainDB: Database
    internal var mainRef: DatabaseReference {
        return mainDB.reference()
    }
    
    init(launchInTestMode: Bool = false) {
        mainDB = Database.database()
        if launchInTestMode {
            mainDB.goOffline()
            mainRef.keepSynced(true)
            mainRef.observeSingleEvent(of: .value) { (_) in }
        }
    }
    
    func tasks(for userID: String) -> Observable<[Section]> {
        return Observable.create({ (observer) -> Disposable in
            
            let UserRef = self.mainRef.child("users").child(userID)
            
            UserRef.child("tasks").queryOrdered(byChild: "orderID").observe(.value) { (snapshot) in
                var newTasks = [Section(title: "Uncompleted", items: []), Section(title: "Completed", items: [])]
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                        let task = TaskModel.modelFromDictionary(snapshot.value as? [String:Any] ?? [:]) {
                        if task.completed {
                            newTasks[1].items.append(task)
                        } else {
                            newTasks[0].items.append(task)
                        }
                    }
                }
                observer.onNext(newTasks)
            }
            
            return Disposables.create()
        })
    }
    
    public func addTask(_ task: TaskModel, for userID: String) -> Observable<Bool>
    {
        return Observable.create({ (observer) -> Disposable in
            
            let que = DispatchQueue.global()
            que.async {
                let UserRef = self.mainRef.child("users").child(userID)
                let taskRef = UserRef.child("tasks").child(task.uuid.uuidString)
//                taskRef.setValue(task.toDic(), withCompletionBlock: { (error, _) in
//                    if error == nil {
//                        observer.onNext(true)
//                    } else {
//                        observer.onError(error!)
//                    }
//                })
                taskRef.setValue(task.toDic())
                observer.onNext(true)
            }
            
            return Disposables.create()
        })
    }
    
    public func editTask(_ task: TaskModel, editItems:[[String: Any]], for userID: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            
            let que = DispatchQueue.global()
            que.async {
                for editItem in editItems {
                    let UserRef = self.mainRef.child("users").child(userID)
//                    UserRef.child("tasks").child(task.uuid.uuidString).updateChildValues(editItem, withCompletionBlock: { (error, _) in
//                        if error == nil {
//                            observer.onNext(true)
//                        } else {
//                            observer.onError(error!)
//                        }
//                    })
                    UserRef.child("tasks").child(task.uuid.uuidString).updateChildValues(editItem)
                    observer.onNext(true)
                }
            }
            
            return Disposables.create()
        })
    }
    
    public func deleteTask(_ task: TaskModel, for userID: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            
            let que = DispatchQueue.global()
            que.async {
                let UserRef = self.mainRef.child("users").child(userID)
//                UserRef.child("tasks").child(task.uuid.uuidString).removeValue(completionBlock: { (error, _) in
//                    if error == nil {
//                        observer.onNext(true)
//                    } else {
//                        observer.onError(error!)
//                    }
//                })
                UserRef.child("tasks").child(task.uuid.uuidString).removeValue()
                observer.onNext(true)
            }
            
            return Disposables.create()
        })
    }
    
    func getUserUUID(userID: String, type: IDType) -> Observable<String> {
        return Observable.create({ (observer) -> Disposable in
            
            self.mainRef.child("Identifier").child(type.typeString).child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.exists() {
                    observer.onNext(snapshot.value as! String)
                }
                else {
                    let uuid = UUID().uuidString
                    self.mainRef.child("Identifier").child(type.typeString).child(userID).setValue(uuid)
                    self.mainRef.child("users").child(uuid).child("sync").setValue(false)
                    
                    observer.onNext(uuid)
                }
            })
            
            return Disposables.create()
        })
    }
    
    func syncUserID(newUserID: String, newType: IDType, with uuid: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            
            self.mainRef.child("Identifier").child(newType.typeString).child(newUserID).setValue(uuid)
            self.mainRef.child("users").child(uuid).child("sync").setValue(true)
            observer.onNext(true)
            
            return Disposables.create()
        })
    }
    
    func getSync(for uuid: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            
            self.mainRef.child("users").child(uuid).child("sync").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    observer.onNext(snapshot.value as? Bool ?? false)
                } else {
                    observer.onNext(false)
                }
            })
            
            return Disposables.create()
        })
    }
    
}
