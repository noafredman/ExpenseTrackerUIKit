//
//  SplashViewController.swift
//  ExpenseTracking
//
//  Created by Noa Fredman on 19/11/2023.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigate()
    }
    
    func navigate() {
        let storyboard = Storyboards.main
        if DataManager.shared.getCurrentUserName() == nil {
            // login
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
        } else {
            // home
            let tabVC = storyboard.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
            tabVC.modalPresentationStyle = .fullScreen
            present(tabVC, animated: true)
        }
    }

}
