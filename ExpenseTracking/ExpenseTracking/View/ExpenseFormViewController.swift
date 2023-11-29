//
//  ExpenseFormViewController.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import UIKit

protocol ExpenseFormViewDelegate {
    func saveChanges(for type: ExpenseFormViewController.FunctionalityType)
}

final class ExpenseFormViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    enum FunctionalityType {
        case createExpense
        case editExpense(expenseClusterId: UUID, expenseId: UUID)
        case filter(date: Date?, expense: Expense?)
    }
    
    @IBOutlet var saveButton_bottomConstraint_medium: NSLayoutConstraint!
    @IBOutlet var saveButton_bottomConstraint_large: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var cleanButton: UIButton!
    @IBOutlet weak var saveButtonView: SubmitButton!
    
    private var dateTextSelected =  ""
    private var selectedDate = Date()
    private var expenseFormViewDelegate: ExpenseFormViewDelegate!
    private let dataManager = DataManager.shared
    private var viewModel: ExpenseFormViewModelProtocol!
    private var saveButtonText = ""
    private var titleText = ""
    private var didClickClearDate = false
    private var functionalityType: FunctionalityType = .createExpense
    
    private let datePicker: UIDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func preLoadingSetup(expenseFormViewDelegate: ExpenseFormViewDelegate,
                         functionalityType: FunctionalityType,
                         titleText: String,
                         saveButtonText: String) {
        self.expenseFormViewDelegate = expenseFormViewDelegate
        self.functionalityType = functionalityType
        self.titleText = titleText
        self.saveButtonText = saveButtonText
    }
    
    private func setup() {
        hideKeyboardWhenTappedAround()
        viewModel = ExpenseFormViewModel(dataManager: dataManager)
        saveButtonView.delegate = self
        saveButtonView.title = saveButtonText
        
        titleLabel.text = titleText
        
        titleTextField.becomeFirstResponder()
        titleTextField.addTarget(self, action: #selector(handleTextEdited), for: .editingChanged)
        titleTextField.autocorrectionType = .no
        amountTextField.addTarget(self, action: #selector(handleTextEdited), for: .editingChanged)
        amountTextField.autocorrectionType = .no

        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date() // don't allow future expenses.
        dateTextField.inputView = datePicker
        
        // prevent manual text change
        dateTextField.addTarget(self, action: #selector(dateTextChanged), for: .editingChanged)
        
        switch functionalityType {
            
        case .createExpense:
            saveButton_bottomConstraint_large.isActive = true
            saveButton_bottomConstraint_medium.isActive = false
            cleanButton.isHidden = true
            saveButtonView.isEnabled = false
            saveButtonView.alpha = 0.5
            
        case let .filter(date: date, expense: expense):
            saveButton_bottomConstraint_large.isActive = false
            saveButton_bottomConstraint_medium.isActive = true
            cleanButton.isHidden = false
            titleTextField.text = expense?.title ?? ""
            amountTextField.text = expense?.amount == 0 ? "" : expense?.amount.toStringWithFractionDigits() ?? ""
            dateTextField.text = date?.toString() ?? ""
            
        case let .editExpense(expenseClusterId: expenseClusterId, expenseId: expenseId):
            saveButton_bottomConstraint_large.isActive = true
            saveButton_bottomConstraint_medium.isActive = false
            cleanButton.isHidden = true
            // show relevant info
            guard let expenseCluster = try? dataManager.getExpenseClusters().first(where: {
                $0.id == expenseClusterId
            }) else {
                return
            }
            guard let expense = expenseCluster.expenses.first(where: {
                $0.id == expenseId
            }) else {
                return
            }
            titleTextField.text = expense.title
            amountTextField.text = expense.amount.toStringWithFractionDigits()
            dateTextField.text = expenseCluster.date.toString()
            selectedDate = expenseCluster.date
            dateTextSelected = dateTextField.text ?? ""
        }
        
        if let text = dateTextField.text, text.isEmpty == false {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            datePicker.date = dateFormatter.date(from: text) ?? Date()
        }
    }

    @objc private func handleDatePicker(sender: UIDatePicker) {
        dateSelected()
    }
    
    @objc private func dateTextChanged() {
        dateTextField.text = dateTextSelected
    }
    
    @objc func handleTextEdited(sender: UITextField) {
        if sender.text == " " {
            sender.text = ""
        } else {
            setSaveButtonViewEnabled()
        }
        if sender == amountTextField && amountTextField.text?.toDouble() == nil {
            sender.text = ""
        }
    }
    
    @IBAction func xClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func cleanClicked(_ sender: Any) {
        titleTextField.text = ""
        amountTextField.text = ""
        dateTextField.text = ""
    }
    
    private func dateSelected() {
        let dateString = datePicker.date.toString()
        selectedDate = datePicker.date
        dateTextField.text = dateString
        dateTextSelected = dateString
        setSaveButtonViewEnabled()
    }
    
    private func setSaveButtonViewEnabled() {
        if case .filter = functionalityType {
            return
        } else {
            if let title = titleTextField.text, title.isEmpty == false,
               let amount = amountTextField.text, amount.isEmpty == false,
               let _ = amount.toDouble(),
               dateTextSelected.isEmpty == false
            {
                // should enable save btn
                if saveButtonView.isEnabled == false {
                    saveButtonView.isEnabled = true
                    saveButtonView.alpha = 1
                }
            } else if saveButtonView.isEnabled == true {
                // should disable save btn
                saveButtonView.isEnabled = false
                saveButtonView.alpha = 0.5
            }
        }
    }
}

// MARK: - SubmitButtonDelegate

extension ExpenseFormViewController: SubmitButtonDelegate {
    func submit() {
        let title = titleTextField.text
        let amount = amountTextField.text
        let date = dateTextField.text
        
        switch functionalityType {
            
        case .createExpense:
            guard let title, title.isEmpty == false, title.starts(with: " ") == false,
                  let amount, amount.isEmpty == false,
                  let amountNumber = amount.toDouble(),
                  let date, date.isEmpty == false
            else {
                return
            }
            viewModel.createClicked(date: selectedDate, expense: Expense(id: UUID(), title: title, amount: amountNumber), newExpenseClusterId: UUID())
            expenseFormViewDelegate.saveChanges(for: .createExpense)
            
        case let .editExpense(expenseClusterId: expenseClusterId, expenseId: infoId):
            guard let title, title.isEmpty == false,
                  let amount, amount.isEmpty == false,
                  let amountNumber = amount.toDouble(),
                  let date, date.isEmpty == false
            else {
                return
            }
            viewModel.saveEditedExpense(expenseClusterId: expenseClusterId, date: selectedDate, expense: Expense(id: infoId, title: title, amount: amountNumber))
            expenseFormViewDelegate.saveChanges(for: .editExpense(expenseClusterId: expenseClusterId, expenseId: infoId))
            
        case .filter:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            expenseFormViewDelegate.saveChanges(
                for: .filter(
                    date: dateFormatter.date(from: date ?? ""),
                    expense: Expense(
                        id: UUID(),
                        title: title ?? "",
                        amount: (amount ?? "").toDouble() ?? 0
                    )
                )
            )
        }
        
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension ExpenseFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField == amountTextField else {
            if textField == titleTextField {
                if titleTextField.isFirstResponder {
                    amountTextField.becomeFirstResponder()
                }
            }
            return true
        }
        let amount = (textField.text ?? "").toDoubleString()
        amountTextField.text = amount.isEmpty ? "" : (Locale.current.currencySymbol ?? "") + amount
        if amountTextField.isFirstResponder {
            dateTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setSaveButtonViewEnabled()
        if textField == dateTextField, textField.text?.isEmpty == true {
            dateSelected()
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == dateTextField {
            dateTextSelected = ""
            didClickClearDate = true
            setSaveButtonViewEnabled()
            return true
        }
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard textField == dateTextField else {
            return true
        }
        guard didClickClearDate == true else {
            return true
        }
        didClickClearDate = false
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField == amountTextField else {
            return
        }
        let amount = (textField.text ?? "").toDoubleString()
        amountTextField.text = amount.isEmpty ? "" : (Locale.current.currencySymbol ?? "") + amount
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" { // deleting
            return true
        }
            
        guard textField == amountTextField else {
            if textField == titleTextField, let oldText = textField.text, let r = Range(range, in: oldText) {
                return oldText.count < 40 ||
                oldText.replacingCharacters(in: r, with: string).count < 40 // new text has less than 40 characters
            }
            return true
        }
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }

        let newText = oldText.replacingCharacters(in: r, with: string)
        guard newText.components(separatedBy: ".").count - 1 <= 1,
                let newNumber = newText.toDouble(),
              newNumber < 1_000_000_000 else {
            return false
        }

        let numberOfDecimalDigits: Int
        if let dotIndex = newText.firstIndex(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }

        return numberOfDecimalDigits <= 2
    }
}

// MARK: - UISheetPresentationControllerDelegate

extension ExpenseFormViewController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        if let selectedDetentIdentifier = sheetPresentationController.selectedDetentIdentifier {
            switch selectedDetentIdentifier {
            case .medium:
                UIView.animate(withDuration: 0.3, animations: { [self] in
                    saveButtonView.transform = CGAffineTransform.identity
                })
            case .large:
                UIView.animate(withDuration: 0.6, animations: { [self] in
                    saveButtonView.transform = CGAffineTransform(translationX: 0, y: -30)
                })
            default:
                break
            }
        }
    }
}
