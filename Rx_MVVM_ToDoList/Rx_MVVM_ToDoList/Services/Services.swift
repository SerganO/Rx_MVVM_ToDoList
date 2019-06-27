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
    let databaseService: DatabaseService
    let tasksService: TasksService
    let notificationService: NotificationService
    
    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
        self.databaseService = FirebaseDatabaseService()
        self.googleAutheficationService = GoogleAutheficationService()
        self.facebookAutheficationService = FacebookAutheficationService()
        self.userService = TDLUserService(googleAuthenficationService: googleAutheficationService, facebookAuthenficationService: facebookAutheficationService, databaseService: databaseService)
        
        
        
        self.tasksService = TDLTasksService(database: databaseService)
        self.notificationService = TDLNotificationService()
//        tasks = SimpleTasksService(database: database)
//        date = SimpleDateService()
//        notification = SimpleNotificationService()
//        facebookAuth = FacebookAuthorizationService()
//        googleAuth = GoogleAuthorizationService()
//        user = SimpleUserService(database: database)
    }
}
