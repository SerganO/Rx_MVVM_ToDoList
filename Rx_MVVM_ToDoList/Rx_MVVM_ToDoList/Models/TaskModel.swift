//
//  TaskModel.swift
//  MVVM_ToDoList
//
//  Created by Trainee on 6/11/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import Firebase

struct TaskModel: Equatable {
    
    var text = ""
    var createDate = Date()
    var notificationDate: Date?
    var completed = false
    var orderID = -1
    var uuid = UUID()
    
    static func modelFromDictionary(_ dictionary: [String: Any]) -> TaskModel? {
        guard
            let text = dictionary["text"] as? String,
            let createDate = dictionary["createDate"] as? String,
            let notificationDate = dictionary["notificationDate"] as? String,
            let completed = dictionary["completed"] as? Bool,
            let stringUuid = dictionary["uuid"] as? String,
            let orderID = dictionary["orderID"] as? Int,
            let uuid = UUID(uuidString: stringUuid)
            else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.dateFormat = "dd-MM-yyyy HH-mm-ss"
        var model = TaskModel()
        model.text = text
        model.completed = completed
        model.notificationDate = formatter.date(from: notificationDate)
        model.createDate = formatter.date(from: createDate) ?? Date()
        model.uuid = uuid
        model.orderID = orderID
        return model
    }
    
    func toDic() -> [String: Any] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.dateFormat = "dd-MM-yyyy HH-mm-ss"
        var notDate = ""
        if let nD = notificationDate {
            notDate = formatter.string(from: nD)
        }
        return [
            "text": text,
            "createDate": formatter.string(from: createDate),
            "notificationDate": notDate,
            "completed": completed,
            "uuid": uuid.uuidString,
            "orderID": orderID
        ]
    }
    
}
