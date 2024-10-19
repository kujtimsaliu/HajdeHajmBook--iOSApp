//
//  LoginViewController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {
    private var window: UIWindow?
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(window: UIWindow?){
        super.init(nibName: nil, bundle: nil)
        self.window = window
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)

        NSLayoutConstraint.activate([
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),

            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalTo: emailTextField.widthAnchor),

            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20)
        ])

        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }

    @objc private func loginButtonTapped() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            showAlert(message: "Please enter both email and password")
            return
        }
        
        guard email.isEmpty == false, password.isEmpty == false else {
            showAlert(message: "Please enter both email and password")
            return
        }
        


        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.showCreateAccountAlert(email, password)
            } else {
                self?.dismiss(animated: true, completion: nil)
                self?.window?.rootViewController = MainTabBarController(window: self?.window, currentUser: Auth.auth().currentUser)
            }
        }
    }
    
    func showCreateAccountAlert(_ email: String, _ password: String) {
        let alert = UIAlertController(title: "Create Account", message: "Would you like to create an account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                if let error = error {
                    self?.showAlert(message: "Registration failed: \(error.localizedDescription)")
                } else {
                    self?.dismiss(animated: true, completion: nil)
                    self?.window?.rootViewController = MainTabBarController(window: self?.window, currentUser: Auth.auth().currentUser)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in }))
        present(alert, animated: true, completion: nil)
        
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
