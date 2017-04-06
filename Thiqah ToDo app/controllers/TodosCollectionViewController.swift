//
//  TodosCollectionViewController.swift
//  Thiqah ToDo app
//
//  Created by khaledannajar on 4/6/17.
//  Copyright © 2017 mycompany. All rights reserved.
//

import UIKit

class TodosCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var todosViewModel: TodosViewable?
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        todosViewModel = TodosViewModel(todosView: self)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        askLoadData()
    }
    
    func askLoadData() {
        todosViewModel?.loadTodos()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todosViewModel!.todosCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let todoObj = todosViewModel?.getTodo(at: indexPath.row)
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TodoCollectionCell
        
        cell.titleLabel.text = todoObj?.title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        todosViewModel?.updateTodo(at: indexPath.row)
        self.performSegue(withIdentifier: "EditFromCollection", sender: self)
    }
    
    @IBAction func addNewTodoTapped(_ sender: Any) {
        todosViewModel?.createNewTodo()
        self.performSegue(withIdentifier: "EditFromCollection", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EditFromCollection" {
            if let editTodoVC = segue.destination as? TodoViewController {
                editTodoVC.todo = todosViewModel?.getEditableTodo()
            }
        }
    }

}

extension TodosCollectionViewController: TodosView {
    func display(error: String) {
        AlertHelper.displayAlert(title: "Error", message: error, inViewController: self)
    }
    
    func reloadData() {
//        self.refreshControl?.endRefreshing()
        self.collectionView.reloadData()
    }
}

class TodoCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
}
