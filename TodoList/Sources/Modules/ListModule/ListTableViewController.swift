//
//  ListTableViewController.swift
//  TodoList
//
//  Created by Serik Musaev on 07.08.2023.
//

import UIKit

protocol ListViewProtocol: AnyObject {
    func insertRow(at indexPath: IndexPath)
}

final class ListTableViewController: UITableViewController {
    // MARK: - Public vars
    var presenter: ListPresenterProtocol!
    
    // MARK: - Private vars
    private let reuseId = String(describing: ListTableViewCell.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        registerCell()
        addPlusBarButton()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.todoData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as? ListTableViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(viewData: presenter.presentTodo(for: indexPath))
        cell.titleTextView.delegate = self
        cell.delegate = self
        return cell
    }
    

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.deleteTodo(with: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - ListViewProtocol
extension ListTableViewController: ListViewProtocol {
    func insertRow(at indexPath: IndexPath) {
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        if let cell = tableView.cellForRow(at: indexPath) as? ListTableViewCell {
            cell.titleTextView.becomeFirstResponder()
        }
    }
}

// MARK: - Internal
private extension ListTableViewController {
    func registerCell() {
        let nib = UINib(nibName: reuseId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseId)
    }
    
    func addPlusBarButton() {
        let barButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapPlusButton))
        navigationItem.setRightBarButton(barButton, animated: true)
    }
    
    @objc func didTapPlusButton() {
        presenter.addNewTodo()
    }
}

// MARK: - UITextViewDelegate
extension ListTableViewController: UITextViewDelegate {
    // For resizing the table view cell corresponding to the text view's text
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let cell = textView.superview?.superview as? ListTableViewCell,
              let index = tableView.indexPath(for: cell) else {
            return
        }
        // Delete todo if the text's empty
        if cell.titleTextView.text?.isEmpty ?? true {
            presenter.deleteTodo(with: index)
            tableView.deleteRows(at: [index], with: .fade)
        } else {
            presenter.changeTitle(at: index, with: textView.text)
        }
    }
}

// MARK: - ListCellDelegate
extension ListTableViewController: ListCellDelegate {
    func listCell(didToggleRadioTo value: Bool, cell: ListTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter.toggleFinished(at: indexPath, value)
    }
    
    func listCell(didSelectDeadline date: Date, cell: ListTableViewCell) -> TodoViewData? {
        guard let indexPath = tableView.indexPath(for: cell) else { return nil }
        presenter.changeDeadline(at: indexPath, date: date)
        return presenter.presentTodo(for: indexPath)
    }
}
