//
//  ListPresenter.swift
//  TodoList
//
//  Created by Serik Musaev on 07.08.2023.
//

import Foundation
import CoreData

struct TodoViewData {
    let title: String?
    let deadline: String?
    let isFinished: Bool
}

protocol ListPresenterProtocol: AnyObject {
    init(view: ListViewProtocol, coreDataStack: CoreDataStack)
    var todoData: [TodoModel] { get }
    func addNewTodo()
    func presentTodo(for indexPath: IndexPath) -> TodoViewData
    func deleteTodo(with indexPath: IndexPath)
    func changeTitle(at index: IndexPath, with text: String)
    func changeDeadline(at index: IndexPath, date: Date)
    func toggleFinished(at index: IndexPath, _ value: Bool)
}

final class ListPresenter: ListPresenterProtocol {
    // MARK: - Private properties
    private weak var view: ListViewProtocol?
    private let coreDataStack: CoreDataStack
    
    // MARK: - Public properties
    var todoData: [TodoModel]
    
    required init(view: ListViewProtocol, coreDataStack: CoreDataStack) {
        self.view = view
        self.coreDataStack = coreDataStack
        self.todoData = coreDataStack.fetchTodoData()
    }
    
    func addNewTodo() {
        if let data = coreDataStack.createTodoData(title: "", detailedDescription: nil, deadline: nil) {
            todoData.append(data)
            view?.insertRow(at: IndexPath(row: todoData.count-1, section: 0))
        }
        coreDataStack.saveContext()
    }
    
    func presentTodo(for indexPath: IndexPath) -> TodoViewData {
        let data = todoData[indexPath.row]
        var deadlineDate: String?
        
        if let deadline = data.deadline {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yy, HH:mm"
            deadlineDate = formatter.string(from: deadline)
        }
        
        let viewData = TodoViewData(
            title: data.title,
            deadline: deadlineDate,
            isFinished: data.isFinished)
        return viewData
    }
    
    func deleteTodo(with indexPath: IndexPath) {
        let object = todoData[indexPath.row]
        coreDataStack.managedContext.delete(object)
        todoData.remove(at: indexPath.row)
        coreDataStack.saveContext()
    }
    
    func changeTitle(at index: IndexPath, with text: String) {
        todoData[index.row].title = text
        coreDataStack.saveContext()
    }
    
    func changeDeadline(at index: IndexPath, date: Date) {
        todoData[index.row].deadline = date
        coreDataStack.saveContext()
    }
    
    func toggleFinished(at index: IndexPath, _ value: Bool) {
        todoData[index.row].isFinished = value
        coreDataStack.saveContext()
    }
}
