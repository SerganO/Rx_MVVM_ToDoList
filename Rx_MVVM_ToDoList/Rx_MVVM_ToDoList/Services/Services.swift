//
//  Services.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/12/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation

class Services {
    let sceneCoordinator: SceneCoordinator
    let googleAutheficationService: GoogleAutheficationService
    let facebookAutheficationService: FacebookAutheficationService
    let userService: UserService
    
//    let database: DatabaseService
//    let tasks: TasksService
//    let date: DateService
//    let notification: NotificationService
//    var facebookAuth: AuthorizationService
//    var googleAuth: AuthorizationService
//
    
    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
        self.googleAutheficationService = GoogleAutheficationService()
        self.facebookAutheficationService = FacebookAutheficationService()
        self.userService = TDLUserService(googleAuthenficationService: googleAutheficationService, facebookAuthenficationService: facebookAutheficationService)
        
        
//        database = FirebaseDatabaseService()
//        tasks = SimpleTasksService(database: database)
//        date = SimpleDateService()
//        notification = SimpleNotificationService()
//        facebookAuth = FacebookAuthorizationService()
//        googleAuth = GoogleAuthorizationService()
//        user = SimpleUserService(database: database)
    }
}
