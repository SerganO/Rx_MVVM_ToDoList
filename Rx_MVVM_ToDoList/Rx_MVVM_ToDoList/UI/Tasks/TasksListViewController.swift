//
//  TasksListViewController.swift
//  Rx_MVVM_ToDoList
//
//  Created by Trainee on 6/26/19.
//  Copyright © 2019 Trainee. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn

class TasksListViewController: ViewController<TasksListViewModel>, UITableViewDelegate {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    var addButton = UIBarButtonItem()
    var syncButton = UIBarButtonItem()
    var logOutButton = UIBarButtonItem()
    var reorderButton = UIBarButtonItem()
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, TaskModel>>(configureCell: { dataSource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.Identifier, for: indexPath) as! TaskCell
        TasksListViewModel.configureTaskCell(item, cell: cell)
        return cell
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "To Do List"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let add = UIButton()
        add.setImage(UIImage(named: "Add"), for: .normal)
        add.setTitleColor(.black, for: .normal)
        add.setTitleColor(.gray, for: .highlighted)
        add.rx.tap.bind {
            self.addButtonTap()
            }.disposed(by: disposeBag)
        addButton = UIBarButtonItem.init(customView: add)
        navigationItem.rightBarButtonItem = addButton
        
        let reorder = UIButton()
        reorder.setImage(UIImage(named:"Reorder"), for: .normal)
        reorder.rx.tap.bind {
            self.reorderButtonTap()
            }.disposed(by: disposeBag)
        
        let reorderButton = UIBarButtonItem(customView: reorder)
        navigationItem.rightBarButtonItems?.append(reorderButton)
        
        let logOut = UIButton()
        logOut.setTitle("LOG OUT", for: .normal)
        logOut.setTitleColor(.black, for: .normal)
        logOut.setTitleColor(.gray, for: .highlighted)
        logOut.rx.tap.bind {
            self.logOutButtonTap()
            }.disposed(by: disposeBag)
        logOutButton = UIBarButtonItem.init(customView: logOut)
        navigationItem.leftBarButtonItem = logOutButton
        
        let sync = UIButton()
        sync.setTitle("...", for: .normal)
        sync.setTitleColor(.black, for: .normal)
        sync.setTitleColor(.gray, for: .highlighted)
        sync.rx.tap.bind {
            self.syncButtonTap()
            }.disposed(by: disposeBag)
        syncButton = UIBarButtonItem.init(customView: sync)
        setupSyncImage()
        navigationItem.leftBarButtonItems?.append(syncButton)
        
        navigationItem.hidesBackButton = true
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].model
        }
        dataSource.canEditRowAtIndexPath = { _, indexPath in
            let cell = self.tableView.cellForRow(at: indexPath)
            cell?.showsReorderControl = false
            return true
        }
        
        dataSource.canMoveRowAtIndexPath = {_,_ in
            return true
        }
        
        viewModel.sections.asDriver().drive(
            tableView.rx.items(dataSource: dataSource)
            ).disposed(by: disposeBag)
        
    }
    
    func setupSyncImage() {
        viewModel.services.databaseService.getSync(for: viewModel.currentUser.uuid).subscribe(onNext: { (isSync) in
            if let sync = self.syncButton.customView as? UIButton {
                sync.setTitle(nil, for: .normal)
                if isSync {
                    sync.setImage(UIImage(named:"AllDone"), for: .normal)
                } else {
                    if self.viewModel.currentUser.idType == .facebook {
                        sync.setImage(UIImage(named:"GoogleIcon"), for: .normal)
                    } else {
                        sync.setImage(UIImage(named:"Facebook"), for: .normal)
                    }
                }
            }
            
        }).disposed(by: disposeBag)
    }
    
    func reorderButtonTap() {
        viewModel.updateId()
        tableView.isEditing = !tableView.isEditing
    }
    
    func addButtonTap() {
        viewModel.addTask()
        tableView.reloadData()
    }
    
    func syncButtonTap() {
        
        viewModel.services.databaseService.getSync(for: viewModel.currentUser.uuid)
            .flatMap { (isSync) -> Observable<Bool> in
                guard !isSync else { return Observable.empty() }
                return self.viewModel.services.userService.sync()
            }
            .subscribe(onNext: { (result) in
                if let button = self.syncButton.customView as? UIButton {
                    button.setImage(UIImage(named:"AllDone"), for: .normal)
                }
            }).disposed(by: self.disposeBag)
        
    }
    
    func logOutButtonTap() {
        let loginManager = LoginManager()
        loginManager.logOut()
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
        let cookies = HTTPCookieStorage.shared
        var facebookCookies = cookies.cookies(for: URL(string: "http://login.facebook.com")!)
        for cookie in facebookCookies! {
            cookies.deleteCookie(cookie )
        }
        facebookCookies = cookies.cookies(for: URL(string: "https://facebook.com/")!)
        for cookie in facebookCookies! {
            cookies.deleteCookie(cookie )
        }
        
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        
        GIDSignIn.sharedInstance()?.signOut()
        viewModel.services.notificationService.removeAllNotification()
        viewModel.services.userService.clearData()
        viewModel.services.sceneCoordinator.pop()
    }
    
    override func setupRx() {
        super.setupRx()
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.Identifier)
        tableView.delegate = self
        configureReactiveTableView()
    }
    
    func configureReactiveTableView() {
        tableView.rx.itemSelected.subscribe(onNext: {
            [unowned self] indexPath in
            guard let cell = self.tableView.cellForRow(at: indexPath) as? TaskCell else {
                return
            }
            self.viewModel.selectCell(cell, indexPath: indexPath)
            if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
            }
        }).disposed(by: disposeBag)
        
        tableView.rx.itemMoved.subscribe(onNext: { (movePath) in
            
            let (sourceIndexPath, destinationIndexPath) = movePath
            if(sourceIndexPath.section == destinationIndexPath.section) {
                if sourceIndexPath.section == 0 {
                    var uncheckedGroup = self.viewModel.sections.value
                    let itemToMove = uncheckedGroup[0].items[sourceIndexPath.row]
                    uncheckedGroup[0].items.remove(at: sourceIndexPath.row)
                    uncheckedGroup[0].items.insert(itemToMove, at: destinationIndexPath.row)
                    self.viewModel.sections.accept(uncheckedGroup)
                } else {
                    var checkedGroup = self.viewModel.sections.value
                    let itemToMove = checkedGroup[1].items[sourceIndexPath.row]
                    checkedGroup[1].items.remove(at: sourceIndexPath.row)
                    checkedGroup[1].items.insert(itemToMove, at: destinationIndexPath.row)
                    self.viewModel.sections.accept(checkedGroup)
                }
            } else  {
                let task = self.viewModel.sections.value[sourceIndexPath.section].items[sourceIndexPath.row]
                self.viewModel.services.tasksService.editTask(task, editItems: [["text":""],["text":task.text]], for: self.viewModel.currentUser.uuid).subscribe(onNext: { (result) in
                    if result {
                        self.viewModel.updateId()
                    }
                }).disposed(by: self.disposeBag)
                self.tableView.reloadData()
            }
        }).disposed(by: disposeBag)
        
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?  {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit" , handler: { (action:UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.viewModel.updateId()
            let task = self.viewModel.sections.value[indexPath.section].items[indexPath.row]
            self.viewModel.editTask(task)
            
        })
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete" , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            let task = self.viewModel.sections.value[indexPath.section].items[indexPath.row]
            self.viewModel.deleteTask(task,indexPath: indexPath )
            
            tableView.rx.itemDeleted.subscribe().disposed(by: self.viewModel.disposeBag)
            
        })
        
        return [deleteAction,editAction]
    }
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if(sourceIndexPath.section == destinationIndexPath.section) {
            if sourceIndexPath.section == 0 {
                var uncheckedGroup = viewModel.sections.value
                let itemToMove = uncheckedGroup[0].items[sourceIndexPath.row]
                uncheckedGroup[0].items.remove(at: sourceIndexPath.row)
                uncheckedGroup[0].items.insert(itemToMove, at: destinationIndexPath.row)
                viewModel.sections.accept(uncheckedGroup)
            } else {
                var checkedGroup = viewModel.sections.value
                let itemToMove = checkedGroup[1].items[sourceIndexPath.row]
                checkedGroup[1].items.remove(at: sourceIndexPath.row)
                checkedGroup[1].items.insert(itemToMove, at: destinationIndexPath.row)
                viewModel.sections.accept(checkedGroup)
            }
        } else {
            tableView.reloadData()
        }
    }
    
}
