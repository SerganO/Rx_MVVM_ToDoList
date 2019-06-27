//
//  IDType.swift
//  Rx_MVVM_ToDoList
//
//  Created by Trainee on 6/27/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation

enum IDType {
    case google
    case facebook
    case none
}

extension IDType {
    var typeString: String {
        switch self {
        case .facebook:
            return "FacebookID"
        case .google:
            return "GoogleID"
        default:
            return "UnknownID"
        }
    }
}
