//
//  TodosViewModel.swift
//  Thiqah ToDo app
//
//  Created by khaledannajar on 4/6/17.
//  Copyright © 2017 THIQAH. All rights reserved.
//

import UIKit

protocol TodosViewable {
    func todosCount() -> Int
    func loadTodos()
    func getTodo(at index: Int) -> TODO
    func createNewTodo()
    func updateTodo(at index: Int)
    func getEditableTodo() -> TODO?
    func removeTodo(at index: Int)
}

protocol TodosView {
    func reloadData()
    func display(error: String)
}
class TodosViewModel: TodosViewable {
    
    var theView: TodosView
    var todos = [TODO]()
    var selectedTodo: TODO?
    
    init(todosView: TodosView) {
        
        self.theView = todosView
        registerForUpdatesNotifications()
    }
    
    func registerForUpdatesNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(todosUpdated), name: todosUpdatedNotificationName, object: nil)
    }
    
    @objc func todosUpdated(){
        
        loadDataFromLocalDB()
    }
    
    func loadTodos() {
        loadDataFromLocalDB()
    }
    
    func loadDataFromLocalDB() {
        
        DBInteractor.shared.fetchTODOs(successBlock: { (fetchedTodos) in
        
            self.todos.removeAll()
            self.todos.append(contentsOf: fetchedTodos)
            
            self.theView.reloadData()
            
        }) { (error) in
            self.theView.display(error: error.localizedDescription)

        }
    }
    func todosCount() -> Int {
        return todos.count
    }
    
    func getTodo(at index: Int) -> TODO {
        return todos[index]
    }
    func selectTodo(at index: Int) {
        self.selectedTodo = todos[index]
    }
    
    func createNewTodo() {
        self.selectedTodo = nil
    }
    
    func updateTodo(at index: Int) {
        self.selectedTodo = todos[index]
    }
    func getEditableTodo() -> TODO? {
        return self.selectedTodo
    }
    func removeTodo(at index: Int) {
        DBInteractor.shared.remove(todo: self.todos[index])
        self.todos.remove(at: index)
    }
}

