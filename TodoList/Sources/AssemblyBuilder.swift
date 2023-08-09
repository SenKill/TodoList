//
//  AssemblyBuilder.swift
//  TodoList
//
//  Created by Serik Musaev on 07.08.2023.
//

import UIKit

protocol AssemblyBuilderProtocol {
    func createListModule() -> UIViewController
}

final class AssemblyBuilder: AssemblyBuilderProtocol {
    func createListModule() -> UIViewController {
        let view = ListTableViewController()
        let coreDataStack = CoreDataStack(modelName: "TodoList")
        let presenter = ListPresenter(view: view, coreDataStack: coreDataStack)
        view.presenter = presenter
        view.title = "TODO List"
        return view
    }
}
