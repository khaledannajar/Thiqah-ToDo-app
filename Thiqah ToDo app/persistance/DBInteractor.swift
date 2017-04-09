//
//  DBInteractor.swift
//  Thiqah ToDo app
//
//  Created by khaledannajar on 4/6/17.
//  Copyright © 2017 mycompany. All rights reserved.
//

import Foundation
import FirebaseDatabase
import CoreData

fileprivate enum TodoKeys: String {
    case titleKey = "title", noteKey = "note", updatedTimeKey = "updatedTime", idKey = "idkey"
}

class DBInteractor {
    static let shared = DBInteractor()
    
    private let local = CoreDBInteractor.shared
    private let cloud = firDBInteractor.shared
    
    func save(todo: TODO) {
        cloud.saveTodo(todo: todo) { (error) in
            print(error)
        }
        local.saveContext { (error) in
            print(error)
        }
    }
    private func persistLocally(todoDicts: [[String : String]]) {
        for todoDict in todoDicts {
            persistLocally(todoDict: todoDict)
        }
        
        //        NotificationCenter.default.post(name: todosUpdatedNotificationName, object: nil)
    }
    private func persistLocally(todoDict: [String : String]) {
        let title = todoDict[TodoKeys.titleKey.rawValue]
        let notes = todoDict[TodoKeys.noteKey.rawValue]
        let lastUpdated = todoDict[TodoKeys.updatedTimeKey.rawValue]
        let id = todoDict[TodoKeys.idKey.rawValue]
        local.createTODOObject { (todo) in
            todo.id = id
            todo.title = title
            todo.notes = notes
            if let _ = lastUpdated, let lastUpdatedNumeric = Double(lastUpdated!) {
                todo.lastUpdated = lastUpdatedNumeric
            }
        }
    }
    
    func createTODOObject(successBlock: @escaping (_ todo: TODO) ->()) {
        local.createTODOObject(successBlock: successBlock)
    }
    
    func fetchTODOs(successBlock: @escaping (_ todos: [TODO]) ->(), failureBlock: @escaping (_ error: Error)->()) {
        local.fetchTODOs(successBlock: successBlock, failureBlock: failureBlock)
        
        cloud.loadData { (todos: [[String : String]]) in
            self.persistLocally(todoDicts: todos)
        }
    }
    
    func syncLocalDB() {
        local.saveContext { (error) in
            print(error)
        }
    }
    
    func remove(todo: TODO) {
        local.remove(removeObject: todo)
        local.saveContext { (error) in
            print(error)
        }
        if todo.id != nil {
            cloud.remove(todoId: todo.id!)
        }
    }
}


fileprivate class CoreDBInteractor {
    static let shared = CoreDBInteractor()
    
    private var backgroundContext: NSManagedObjectContext?
    
    func createTODOObject(successBlock: @escaping (_ todo: TODO) ->()) {
        
        backgroundContext?.perform {
            let todoObject = TODO(context: self.backgroundContext!)
            successBlock(todoObject)
        }
    }
    
    func fetchTODOs(successBlock: @escaping (_ todos: [TODO]) ->(), failureBlock: @escaping (_ error: Error)->()) {
        persistentContainer.viewContext.perform {
            
            do {
                if let todos = try self.persistentContainer.viewContext.fetch(TODO.fetchRequest()) as? [TODO] {
                    successBlock(todos)
                }
                
            } catch {
                failureBlock(error)
            }
        }
    }
    
    func remove(removeObject: NSManagedObject) {
        persistentContainer.viewContext.delete(removeObject)
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Thiqah_ToDo_app")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        self.backgroundContext = container.newBackgroundContext()
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext(failureBlock: @escaping (_ error: String)->()) {
        
        do {
            let viewContext = persistentContainer.viewContext
            if viewContext.hasChanges{
                try viewContext.save()
                freeMemory(in: viewContext)
            }
            if let backgroundContext = backgroundContext, backgroundContext.hasChanges {
                try backgroundContext.save()
                freeMemory(in: backgroundContext)
            }
            
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
    }
    
    func freeMemory(in context: NSManagedObjectContext) {
        for entityObj in context.registeredObjects {
            context.refresh(entityObj, mergeChanges: false)
        }
    }
}

fileprivate class firDBInteractor {
    static let shared = firDBInteractor()
    
    var dbRef: FIRDatabaseReference = FIRDatabase.database().reference()
    let todosNode = FIRDatabase.database().reference().child("Todos")
    
    func todoDictionary(todo: TODO) -> [String : String] {
        
        var dict = [TodoKeys.titleKey.rawValue : todo.title!]
        if todo.notes != nil {
            dict[TodoKeys.noteKey.rawValue] = todo.notes!
        }
        dict[TodoKeys.updatedTimeKey.rawValue] = String(todo.lastUpdated)
        
        return dict
    }
    
    func remove(todoId: String){
        todosNode.child(todoId).removeValue()
    }
    
    func loadData(successBlock: @escaping (_ todos:  [[String : String]]) ->()) {
        
        var results = [[String : String]]()
        todosNode.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let todoDict = snapshot.value as? [String:AnyObject] {
                for (key ,todoElement) in todoDict {
                    
                    print(todoElement);
                    
                    let title = todoElement[TodoKeys.titleKey.rawValue]
                    let notes  = todoElement[TodoKeys.noteKey.rawValue]
                    let lastUpdated = todoElement[TodoKeys.updatedTimeKey.rawValue]
                    
                    var dict = [String : String]()
                    if let title = title as? String {
                        dict[TodoKeys.titleKey.rawValue] = title
                    }
                    
                    if let notes = notes as? String {
                        dict[TodoKeys.noteKey.rawValue] = notes
                    }
                    if let lastUpdated = lastUpdated as? String {
                        dict[TodoKeys.noteKey.rawValue] = lastUpdated
                    }
                    
                    dict[TodoKeys.idKey.rawValue] = key
                    
                    results.append(dict)
                }
                successBlock(results)
            }
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func saveTodo(todo: TODO, failureBlock: @escaping (_ error: String)->()) {
        
        guard todo.title != nil else {
            failureBlock("Todo title is mandatory and can not be nil")
            return
        }
        if todo.id == nil {
            // saved on core data only
            let dictionary = todoDictionary(todo: todo)
            
            let todoNode = dbRef.child("Todos").childByAutoId()
            todoNode.setValue(dictionary)
            let todoNodeId = todoNode.key
            todo.id = todoNodeId
        } else {
            let cloudTodo = todosNode.child(todo.id!)
            let title = cloudTodo.value(forKey: TodoKeys.titleKey.rawValue)
            let notes = cloudTodo.value(forKey: TodoKeys.noteKey.rawValue)
            let timestamp = cloudTodo.value(forKey: TodoKeys.updatedTimeKey.rawValue)
            
            if let timestamp = timestamp as? String, let cloudLastUpdated = Double(timestamp) {
                
                if cloudLastUpdated > todo.lastUpdated {
                    todo.title = title as? String
                    todo.notes = notes as? String
                    todo.lastUpdated = cloudLastUpdated
                    
                } else if cloudLastUpdated < todo.lastUpdated {
                    cloudTodo.setValue(todo.title, forKey: TodoKeys.titleKey.rawValue)
                    cloudTodo.setValue(todo.notes, forKey: TodoKeys.noteKey.rawValue)
                    cloudTodo.setValue(todo.lastUpdated, forKey: TodoKeys.updatedTimeKey.rawValue)
                }
            }
        }
        
    }
    
}
