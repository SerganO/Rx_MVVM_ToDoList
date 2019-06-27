//
//  DateViewController.swift
//  Rx_MVVM_ToDoList
//
//  Created by Trainee on 6/27/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class DateViewController: ViewController<DateViewModel> {
    
    var datePickerView = UIView()
    var datePicker = UIDatePicker()
    var doneButton = UIBarButtonItem()
    var backButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let done = UIButton()
        done.setTitle("Done", for: .normal)
        done.setTitleColor(.black, for: .normal)
        done.setTitleColor(.gray, for: .highlighted)
        done.rx.tap.bind {
            self.viewModel.acceptDate(self.datePicker.date)
            self.viewModel.services.sceneCoordinator.pop()
            }.disposed(by: disposeBag)
        doneButton = UIBarButtonItem.init(customView: done)
        navigationItem.rightBarButtonItem = doneButton
        
        let back = UIButton()
        back.setTitle("Back", for: .normal)
        back.setTitleColor(.black, for: .normal)
        back.setTitleColor(.gray, for: .highlighted)
        back.rx.tap.bind {
            self.viewModel.services.sceneCoordinator.pop()
            }.disposed(by: disposeBag)
        backButton = UIBarButtonItem.init(customView: back)
        navigationItem.leftBarButtonItem = backButton
        
        view.addSubview(datePickerView)
        datePickerView.snp.makeConstraints { (make) in
            if #available(iOS 11, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.top)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5).offset(-10)
        }
        
        datePickerView.addSubview(datePicker)
        datePicker.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().offset(-5)
        }
        
        datePickerView.layer.cornerRadius = 10
        datePicker.locale = Locale(identifier: "en_GB")
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        self.view.insertSubview(blurEffectView, at: 0)
        
        
    }
    
}
