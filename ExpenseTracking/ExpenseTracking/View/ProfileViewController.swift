//
//  ProfileViewController.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import UIKit
import Combine
final class ProfileViewController: UIViewController {

    @IBOutlet weak var amountLabel: UILabel!
    var viewModel: ProfileViewModelProtocol!
    var cancellables = Set<AnyCancellable>() // when deinitialized it will cancel the subscriptions of the listeners (those that call 'sink')
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        viewModel.state.$totalExpenseItems.sink { [weak self] in
            guard let self else {return}
            self.amountLabel.text = $0
        }.store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshData()
    }
    
    @IBAction func signOutClicked(_ sender: Any) {
        viewModel.logout()
        if (UIApplication.shared.firstKeyWindow?.rootViewController as? UINavigationController)?.viewControllers[0] is LoginViewController {
            navigationController?.popToRootViewController(animated: true)
        } else {
            // user was already logged in when app was openned -> root controller is the Tab controller -> need to set the root VC to the loginVC
            let loginVC = Storyboards.main.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            loginVC.modalPresentationStyle = .fullScreen
            UIApplication.shared.firstKeyWindow?.rootViewController = UINavigationController(rootViewController: loginVC)
            // pop to loginVC
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
}
