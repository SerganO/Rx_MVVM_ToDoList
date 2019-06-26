//
//  TaskCell.swift
//  Rx_MVVM_ToDoList
//
//  Created by Trainee on 6/26/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import UIKit
import SnapKit

class TaskCell: UITableViewCell {
    
    static let Identifier = "TaskCell"
    
    let taskTextLabel = UILabel(frame: .zero)
    let taskCompletedImageView = UIImageView(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        constructor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        constructor()
    }
    
    func constructor() {
        
        let container = UIView()
        contentView.addSubview(container)
        
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        container.addSubview(taskCompletedImageView)
        taskCompletedImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().offset(5)
            make.bottom.greaterThanOrEqualToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(5)
            make.width.equalTo(taskCompletedImageView.snp.height)
        }
        
        container.addSubview(taskTextLabel)
        taskTextLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        taskTextLabel.textAlignment = .left
        taskTextLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().offset(5)
            make.bottom.greaterThanOrEqualToSuperview().offset(-5)
            make.leading.equalTo(taskCompletedImageView.snp.trailing).offset(10)
        }
        
    }
    
    
}
