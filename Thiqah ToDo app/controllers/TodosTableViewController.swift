//
//  TodosTableViewController.swift
//  Thiqah ToDo app
//
//  Created by khaledannajar on 4/6/17.
//  Copyright © 2017 THIQAH. All rights reserved.
//

import UIKit


let todosUpdatedNotificationName = Notification.Name("todosUpdatedNotificationName")

class TodosTableViewController: UITableViewController {

    var todosViewModel: TodosViewable?
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        askLoadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationItem.leftBarButtonItem = self.editButtonItem
        var items = self.navigationItem.rightBarButtonItems
        items?.append(self.editButtonItem)
        self.navigationItem.rightBarButtonItems = items
        todosViewModel = TodosViewModel(todosView: self)
        
        setupPullToRefresh()
    }
    
    func setupPullToRefresh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(askLoadData), for: .valueChanged)
    }

    @objc func askLoadData() {
        todosViewModel?.loadTodos()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return todosViewModel!.todosCount()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let todoObj = todosViewModel?.getTodo(at: indexPath.row)
        cell.textLabel?.text = todoObj?.title

        return cell
    }
}

// MARK: - MVVM functions
extension TodosTableViewController: TodosView {
    func display(error: String) {
        AlertHelper.displayAlert(title: "Error", message: error, inViewController: self)
    }
    
    func reloadData() {
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
}

// MARK: - Actions

extension TodosTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        todosViewModel?.updateTodo(at: indexPath.row)
        self.performSegue(withIdentifier: "TODOEdit", sender: self)
    }
    
    @IBAction func addNewTodoTapped(_ sender: Any) {
        todosViewModel?.createNewTodo()
        self.performSegue(withIdentifier: "TODOEdit", sender: self)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "TODOEdit" {
            if let editTodoVC = segue.destination as? TodoViewController {
                editTodoVC.todo = todosViewModel?.getEditableTodo()
            }
        }
    }
}

// MARK: - Edit mode

extension TodosTableViewController {
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            todosViewModel?.removeTodo(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
