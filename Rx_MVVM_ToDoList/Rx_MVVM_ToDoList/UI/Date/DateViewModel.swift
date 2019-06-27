//
//  DateViewModel.swift
//  Rx_MVVM_ToDoList
//
//  Created by Trainee on 6/27/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class DateViewModel: ViewModel {
   
    var notDate: BehaviorRelay<Date>
    
    init(services: Services, notificationDate: BehaviorRelay<Date>) {
        notDate = notificationDate
        super.init(services: services)
    }
    
    func acceptDate(_ Date: Date) {
        notDate.accept(Date)
    }
    
}
