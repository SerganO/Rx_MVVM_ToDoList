//
//  userIDType.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/18/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation

enum userIDType {
    case facebook
    case google
    case none
}

extension userIDType {
    func getTypeString() -> String {
        switch self {
        case .facebook:
            return "FacebookID"
        case .google:
            return "GoogleID"
        default:
            return ""
        }
        
    }
    
   
}
