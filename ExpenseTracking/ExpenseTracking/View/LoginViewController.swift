//
//  LoginViewController.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import UIKit

final class LoginViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var loginButtonView: SubmitButton!
    private let viewModel = LoginViewModel(dataManager: DataManager.shared)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButtonView.delegate = self
        setUpTextField()
        hideKeyboardWhenTappedAround()
    }
    
    private func setUpTextField() {
        textField.becomeFirstResponder()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 0.357, green: 0.345, blue: 0.678, alpha: 1).cgColor
        guard let parent = self.textField else {
            return
        }
        parent.layer.masksToBounds = false
        parent.layer.shadowOffset = CGSize(width: 0, height: 4)
        parent.layer.shadowRadius = 4
        parent.layer.shadowOpacity = 1
        
        parent.layer.cornerRadius = 5
        loginButtonView.button.setTitle("Login", for: .normal)
        
    }
}

//MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submit()
        return true
    }
}

//MARK: - SubmitButtonDelegate

extension LoginViewController: SubmitButtonDelegate {
    func submit() {
        #if DEBUG
        if let name = textField.text, name.isEmpty {
            textField.text = "m"
        }
        #endif
        guard let name = textField.text, name.isEmpty == false else {
            return
        }
        textField.text = ""
        login(name: name)
    }
    
    func login(name: String) {
        do {
            try viewModel.didLogin(name: name)
            let storyboard = Storyboards.main
            let tabVC = storyboard.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
            tabVC.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(tabVC, animated: true)
        } catch {
            let alert = UIAlertController(title: "Error Logging In", message: "Please try again later", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: false)
        }
    }
}
