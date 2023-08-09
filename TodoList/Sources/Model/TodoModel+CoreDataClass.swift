//
//  TodoModel+CoreDataClass.swift
//  TodoList
//
//  Created by Serik Musaev on 07.08.2023.
//
//

import Foundation
import CoreData

@objc(TodoModel)
public class TodoModel: NSManagedObject {

}

extension TodoModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoModel> {
        return NSFetchRequest<TodoModel>(entityName: "TodoModel")
    }

    @NSManaged public var deadline: Date?
    @NSManaged public var title: String?
    @NSManaged public var isFinished: Bool

}

extension TodoModel : Identifiable { }
