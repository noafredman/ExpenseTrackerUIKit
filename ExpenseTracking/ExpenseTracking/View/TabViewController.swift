//
//  TabViewController.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import UIKit

final class TabViewController: UITabBarController {
    
    private let plusButton = UIButton(type: .custom)
    private var homeVM: HomeViewModel!
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        plusButton.frame = CGRect(x: tabBar.center.x - 28, y: tabBar.frame.origin.y - 25, width: 56, height: 56)
        plusButton.addTarget(self, action: #selector(plusClicked), for: .touchDown)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationItem.title = DataManager.shared.getCurrentUserName() ?? ""
        setViewControllers()
        addPlusButton()
        addLine()
    }
    
    private func setViewControllers() {
        let storyboard = Storyboards.main
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        homeVM = HomeViewModel(dataManager: DataManager.shared)
        homeVC.viewModel = homeVM
        
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileVC.viewModel = ProfileViewModel(dataManager: DataManager.shared)
        
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.271, green: 0.369, blue: 1, alpha: 1), .font: HelveticaFontsEnum.bold(size: 16).font() as Any]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.412, green: 0.412, blue: 0.412, alpha: 1), .font: HelveticaFontsEnum.regular(size: 16).font() as Any]
        appearance.shadowColor = .black
        tabBar.standardAppearance = appearance
        tabBar.clipsToBounds = false

        setViewControllers([homeVC, profileVC], animated: false)
    }
    
    private func addPlusButton() {
        plusButton.frame = CGRect(x: 110, y: 0, width: 56, height: 56)
        plusButton.setImage(UIImage(named: "plus"), for: .normal)
        plusButton.cornerRadius = 28
        view.insertSubview(plusButton, aboveSubview: tabBar)
    }
    
    private func addLine() {
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.size.width, height: 1))
        lineView.backgroundColor = .systemGray6
        tabBar.addSubview(lineView)
    }
    
    @objc func plusClicked() {
        let storyboard = Storyboards.main
        let addExpenseVC = storyboard.instantiateViewController(withIdentifier: "ExpenseFormViewController") as! ExpenseFormViewController
        addExpenseVC.modalPresentationStyle = .formSheet
        addExpenseVC.preLoadingSetup(expenseFormViewDelegate: self, functionalityType: .createExpense, titleText: "Create Expense", saveButtonText: "Create")
        present(addExpenseVC, animated: true)
    }
}

extension TabViewController: ExpenseFormViewDelegate {
    func saveChanges(for type: ExpenseFormViewController.FunctionalityType) {
        homeVM.updateData(for: .none)
    }
}
