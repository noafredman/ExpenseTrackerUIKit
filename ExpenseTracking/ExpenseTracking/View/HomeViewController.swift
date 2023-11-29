//
//  HomeViewController.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import UIKit
import Combine

enum FilteredByTag: Int {
    case date, amount, title
}

final class HomeViewController: UIViewController {
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filtersButton: UIButton!
    @IBOutlet weak var filteredByStackView: UIStackView!
    @IBOutlet weak var noExpensesLabel: UILabel!
    
    var viewModel: (HomeViewModelProtocol)!
    private var cancellables: Set<AnyCancellable> = [] // when deinitialized it will cancel the subscriptions of the listeners ( those that call 'sink')
    private var expenses = [ExpenseCluster]()
    private var flattenedExpenses = [[Expense]]()
    private var viewDidLoadCalled = false
    private var currentExpensePresentedIndex = 0
    private var filteredBy: HomeViewModel.UpdateDataType = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadCalled = true
        filtersButton.tintColor = .black
            tableView.sectionHeaderTopPadding = 0
        sinkInit()
    }
    
    // MARK: - Private methods
    
    private func sinkInit() {
        viewModel.state.$amount.sink { [weak self] amount in
            guard let self else {
                return
            }
            self.amountLabel.text = amount
        }.store(in: &cancellables)
        viewModel.state.$expenses.sink { [weak self] expenses in
            guard let self else {
                return
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.filtersButton.alpha = expenses.isEmpty ? 0 : 1
                self.noExpensesLabel.alpha = !expenses.isEmpty ? 0 : 1
            })
            
            self.flattenedExpenses = [[Expense]]()
            self.expenses = expenses.sorted(by: {
                // The expenses list should be ordered by a descending date.
                $0.date > $1.date
            })
            for item in self.expenses {
                var infoArray = [Expense]()
                item.expenses.forEach {
                    infoArray.append($0)
                }
                self.flattenedExpenses.append(infoArray)
            }
            if viewModel.didDeleteInfo == false {
                tableView.reloadData()
            }
        }.store(in: &cancellables)
        
        viewModel.state.$isFiltered.sink { [weak self] filterType in
            guard let self else {
                return
            }
            switch filterType {
                
            case .filter(date: let date, expense: let expense):
                filteredBy = filterType
                let dateBtn = filteredByStackView.subviews.first(where: { $0.tag == FilteredByTag.date.rawValue})
                let amountBtn = filteredByStackView.subviews.first(where: { $0.tag == FilteredByTag.amount.rawValue})
                let titleBtn = filteredByStackView.subviews.first(where: { $0.tag == FilteredByTag.title.rawValue})
                
                if date == nil, let dateBtn = dateBtn as? UIButton {
                    // remove date button if exists
                    removeFilter(dateBtn)
                } else if let date, filteredByStackView.subviews.contains(where: { $0.tag == FilteredByTag.date.rawValue}) == false {
                    filteredByStackView.addArrangedSubview(getFilteredByButton(title: "date", tag: .date))
                }
                
                if let expense {
                    // amount and/or title updated
                    if expense.amount == 0 {
                        if let amountBtn = amountBtn as? UIButton {
                            removeFilter(amountBtn)
                        }
                    } else if filteredByStackView.subviews.contains(where: { $0.tag == FilteredByTag.amount.rawValue}) == false {
                        filteredByStackView.addArrangedSubview(getFilteredByButton(title: "amount", tag: .amount))
                    }
                    if expense.title.isEmpty {
                        if let titleBtn = titleBtn as? UIButton {
                            removeFilter(titleBtn)
                        }
                    } else if filteredByStackView.subviews.contains(where: { $0.tag == FilteredByTag.title.rawValue}) == false {
                        filteredByStackView.addArrangedSubview(getFilteredByButton(title: "title", tag: .title))
                    }
                } else {
                    // remove date button if exists
                    if let amountBtn = amountBtn as? UIButton {
                        removeFilter(amountBtn)
                    }
                    if let titleBtn = titleBtn as? UIButton {
                        removeFilter(titleBtn)
                    }
                }
            case .none, .removedInfo:
                filteredByStackView.removeAllArrangedSubviews()
                filteredBy = .none
            }
        }.store(in: &cancellables)
    }
    
    private func getFilteredByButton(title: String, tag: FilteredByTag) -> UIButton {
        var configuration = UIButton.Configuration.gray()
        configuration.imagePadding = 5
        let button = UIButton(configuration: configuration)
        button.setTitle(title, for: .normal)
        button.tintColor = .black
        let xImage = UIImage(systemName: "xmark.circle")
        button.setImage(xImage, for: .normal)
        button.cornerRadius = 5
        button.backgroundColor = .lightGray
        button.tag = tag.rawValue
        button.addTarget(self, action: #selector(removeFilter), for: .touchUpInside)
        return button
    }
    
    @objc private func removeFilter(_ sender: UIButton) {
        sender.removeFromSuperview()
        if filteredByStackView.subviews.isEmpty {
            viewModel.updateData(for: .none)
        } else {
            if case .filter(let date, let expense) = filteredBy {
                var newExpense: Expense? = expense
                if let expense {
                    if expense.amount > 0, sender.tag == FilteredByTag.amount.rawValue {
                        newExpense = Expense(id: UUID(), title: expense.title, amount: 0)
                    }
                    if expense.title.isEmpty == false, sender.tag == FilteredByTag.title.rawValue {
                        newExpense = Expense(id: UUID(), title: "", amount: expense.amount)
                    }
                }
                viewModel.updateData(for: .filter(date: sender.tag == FilteredByTag.date.rawValue ? nil : date, expense: sender.tag == FilteredByTag.date.rawValue ? expense : newExpense))
            }
        }
    }
    
    @IBAction func filterClicked(_ sender: Any) {
        let storyboard = Storyboards.main
        let filterVC = storyboard.instantiateViewController(withIdentifier: "ExpenseFormViewController") as! ExpenseFormViewController
        filterVC.modalPresentationStyle = .formSheet
        
        filterVC.sheetPresentationController?.detents = [.medium(), .large()] // worth noting that custom height detent is available from iOS 16
        
        filterVC.sheetPresentationController?.delegate = filterVC
        switch filteredBy {
            
        case .filter(date: let date, expense: let expense):
            filterVC.preLoadingSetup(
                expenseFormViewDelegate: self,
                functionalityType: .filter(
                    date: date,
                    expense: expense
                ),
                titleText: "Filters",
                saveButtonText: "Filter"
            )
        case .none, .removedInfo:
            filterVC.preLoadingSetup(
                expenseFormViewDelegate: self,
                functionalityType: .filter(
                    date: nil,
                    expense: nil
                ),
                titleText: "Filters",
                saveButtonText: "Filter"
            )
        }
        
        present(filterVC, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expenses[section].expenses.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        25
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseTableViewCell", for: indexPath) as? ExpenseTableViewCell else {
            return UITableViewCell()
        }
        cell.setupInfo(flattenedExpenses[indexPath.section][indexPath.row], shouldHideSeperator: indexPath.row == expenses[indexPath.section].expenses.count - 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseHeaderTableViewCell") as? ExpenseHeaderTableViewCell else {
            return UITableViewCell()
        }
        cell.headerLabel.text = expenses[section].date.toString()
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteContextItem = UIContextualAction(style: .destructive, title: "delete") {  (contextualAction, view, boolValue) in
            self.deleteButtonClicked(indexPath: indexPath)
        }
        
        let editContextItem = UIContextualAction(style: .normal, title: "edit") {  (contextualAction, view, boolValue) in
            self.editButtonClicked(indexPath: indexPath)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editContextItem])

        return swipeActions
    }
    
    private func editButtonClicked(indexPath: IndexPath) {
        // edit expense
        let storyboard = Storyboards.main
        let editExpenseVC = storyboard.instantiateViewController(withIdentifier: "ExpenseFormViewController") as! ExpenseFormViewController
        editExpenseVC.modalPresentationStyle = .formSheet
        let selectedExpenseId = expenses[indexPath.section].id
        let selectedInfoId = flattenedExpenses[indexPath.section][indexPath.row].id
        editExpenseVC.preLoadingSetup(
            expenseFormViewDelegate: self,
            functionalityType: .editExpense(
                expenseClusterId: selectedExpenseId,
                expenseId: selectedInfoId
            ),
            titleText: "Edit Expense",
            saveButtonText: "Save"
        )
        present(editExpenseVC, animated: true)
    }
    
    private func deleteButtonClicked(indexPath: IndexPath) {
        let selectedExpenseId = expenses[indexPath.section].id
        let selectedInfoId = flattenedExpenses[indexPath.section][indexPath.row].id
        do {
            try viewModel.removedExpense(expenseClusterId: selectedExpenseId, expenseId: selectedInfoId)
        } catch {
            print(error)
            return
        }
        tableView.performBatchUpdates({
            if tableView.numberOfRows(inSection: indexPath.section) == 1 {
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                tableView.reloadData()
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
            }
        }, completion: nil)
    }
}

// MARK: - ExpenseFormViewDelegate

extension HomeViewController: ExpenseFormViewDelegate {
    func saveChanges(for type: ExpenseFormViewController.FunctionalityType) {
        switch type {
        case .createExpense, .editExpense:
            viewModel.updateData(for: .none)
        case .filter(date: let date, expense: let expense):
            viewModel.updateData(for: .filter(date: date, expense: expense))
        }
    }
}
