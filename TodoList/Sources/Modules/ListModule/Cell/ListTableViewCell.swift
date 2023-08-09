//
//  ListTableViewCell.swift
//  TodoList
//
//  Created by Serik Musaev on 07.08.2023.
//

import UIKit

protocol ListCellDelegate: AnyObject {
    func listCell(didToggleRadioTo value: Bool, cell: ListTableViewCell)
    func listCell(didSelectDeadline date: Date, cell: ListTableViewCell) -> TodoViewData?
}

final class ListTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet private weak var deadlineTextField: UITextField!
    @IBOutlet private weak var radioButton: UIButton!
    
    // MARK: - Public properties
    weak var delegate: ListCellDelegate?
    
    // MARK: - Private vars
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        return picker
    }()
    
    // MARK: - IBActions
    @IBAction func didTapRadioButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        toggleTextFieldActivity(sender.isSelected)
        delegate?.listCell(didToggleRadioTo: sender.isSelected, cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
        setupToolbarForPicker()
    }
    
    func configureCell(viewData: TodoViewData) {
        titleTextView.text = viewData.title
        deadlineTextField.text = viewData.deadline
        radioButton.isSelected = viewData.isFinished
        toggleTextFieldActivity(viewData.isFinished)
    }
}

// MARK: - UITextFieldDelegate
extension ListTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

// MARK: - Internal
private extension ListTableViewCell {
    func toggleTextFieldActivity(_ isFinished: Bool) {
        titleTextView.isUserInteractionEnabled = !isFinished
        deadlineTextField.isEnabled = !isFinished
        if isFinished {
            titleTextView.textColor = .secondaryLabel
            deadlineTextField.textColor = .secondaryLabel
        } else {
            titleTextView.textColor = .label
        }
    }
    
    func configureViews() {
        deadlineTextField.inputView = datePicker
        deadlineTextField.delegate = self
        deadlineTextField.tintColor = .clear
        titleTextView.textContainer.lineFragmentPadding = 0
    }
    
    func setupToolbarForPicker() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 35))
        let marginView = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let leftButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(toolbarDidCancel))
        let rightButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(toolbarDidDone))
        
        marginView.width = 10
        toolbar.sizeToFit()
        toolbar.tintColor = .systemGreen
        toolbar.setItems([leftButton, flexibleSpace, rightButton], animated: false)
        deadlineTextField.inputAccessoryView = toolbar
        titleTextView.inputAccessoryView = toolbar
    }
    
    @objc func toolbarDidCancel() {
        titleTextView.resignFirstResponder()
        deadlineTextField.resignFirstResponder()
    }
    
    @objc func toolbarDidDone() {
        if titleTextView.isFirstResponder {
            titleTextView.resignFirstResponder()
        } else {
            guard let newData = delegate?.listCell(didSelectDeadline: datePicker.date, cell: self) else { return }
            configureCell(viewData: newData)
            deadlineTextField.resignFirstResponder()
        }
    }
}
