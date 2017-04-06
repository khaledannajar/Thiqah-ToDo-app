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

    var todos = [TODO]()
    var selectedTodo: TODO?
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadDataFromLocalDB();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        setupPullToRefresh()
        registerForUpdatesNotifications()
        
    }
    
    func setupPullToRefresh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(loadDataFromLocalDB), for: .valueChanged)
    }
    
    func registerForUpdatesNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(todosUpdated), name: todosUpdatedNotificationName, object: nil)
    }
    
    func todosUpdated(){
        
        loadDataFromLocalDB()
    }
    
    func loadDataFromLocalDB() {
        
        CoreDBInteractor.shared.fetchTODOs(successBlock: { (fetchedTodos) in
            self.todos.removeAll()
            self.todos.append(contentsOf: fetchedTodos)
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            
        }) { (error) in
            AlertHelper.displayAlert(title: "Error", message: error.localizedDescription, inViewController: self)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return todos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let todoObj =  todos[indexPath.row]
        cell.textLabel?.text = todoObj.title

        return cell
    }
}

// MARK: - Actions

extension TodosTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedTodo = todos[indexPath.row]
        self.performSegue(withIdentifier: "TODOEdit", sender: self)
    }
    
    @IBAction func addNewTodoTapped(_ sender: Any) {
        self.selectedTodo = nil
        self.performSegue(withIdentifier: "TODOEdit", sender: self)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "TODOEdit" {
            if let editTodoVC = segue.destination as? TodoViewController {
                editTodoVC.todo = self.selectedTodo
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
            CoreDBInteractor.shared.remove(removeObject: self.todos[indexPath.row])
            self.todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
