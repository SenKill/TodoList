//
//  CoreDataStack.swift
//  TodoList
//
//  Created by Serik Musaev on 07.08.2023.
//

import Foundation
import CoreData

final class CoreDataStack {
    private let modelName: String
    private let entityName = "TodoModel"
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved container error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    lazy var managedContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    // MARK: - Core Data Saving support
    func saveContext() {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved saving error \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Core Data Fetching
    func fetchTodoData() -> [TodoModel] {
        let fetchRequest = NSFetchRequest<TodoModel>(entityName: entityName)
        do {
            return try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Unresolved fetching error \(error), \(error.userInfo)")
        }
        return []
    }
    
    func createTodoData(title: String, detailedDescription: String?, deadline: Date?) -> TodoModel? {
        guard let description = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else {
            print("Error, couldn't create entity description for entity name: \(entityName)")
            return nil
        }
        let data = TodoModel(entity: description, insertInto: managedContext)
        data.title = title
        return data
    }
}
