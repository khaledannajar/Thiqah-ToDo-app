//
//  TodoViewController.swift
//  Thiqah ToDo app
//
//  Created by khaledannajar on 4/6/17.
//  Copyright © 2017 THIQAH. All rights reserved.
//

import UIKit

class TodoViewController: UIViewController {

    var todo: TODO?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let todo = todo {
            titleTextField.text = todo.title
            notesTextView.text = todo.notes
        }
    }
    
    @IBAction func dismissCalled(_ sender: Any) {
        dismissSelf()
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        trimWhiteSpaces()
        
        guard isValidData() else {
            return
        }
        
        if todo == nil {
            DBInteractor.shared.createTODOObject(successBlock: { (todo) in
                self.todo = todo
                self.setData(inTodo: todo)
            })
        } else {
            if oldDataChanged() {
                self.setData(inTodo: todo!)
            }
        }
        
        dismissSelf()
    }
    
    func trimWhiteSpaces() {
        titleTextField.text = titleTextField.text?.trimmingCharacters(in: .whitespaces)
        notesTextView.text = notesTextView.text.trimmingCharacters(in: .whitespaces)
        
    }
    
    func isValidData() -> Bool {
        return titleTextField.text!.characters.count > 0
    }
    
    func setData(inTodo: TODO) {
        inTodo.title = titleTextField.text
        inTodo.notes = notesTextView.text
        inTodo.lastUpdated = Date().timeIntervalSince1970

        DBInteractor.shared.save(todo: inTodo)
    }
    
    func oldDataChanged() -> Bool {
        return titleTextField.text != todo?.title || notesTextView.text != todo?.notes
    }
    
    func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }
}
