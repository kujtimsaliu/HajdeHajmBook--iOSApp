//
//  SettingsViewController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your display name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(saveDisplayName), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        setupUI()
        loadCurrentDisplayName()
    }
    
    private func setupUI() {
        view.addSubview(nameTextField)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func loadCurrentDisplayName() {
        if let customName = UserDefaults.standard.string(forKey: "userDisplayName") {
            nameTextField.text = customName
        } else if let email = Auth.auth().currentUser?.email {
            let username = email.components(separatedBy: "@").first ?? email
            nameTextField.text = username
        }
    }
    
    @objc private func saveDisplayName() {
        guard let newName = nameTextField.text, !newName.isEmpty else {
            showAlert(message: "Please enter a valid name")
            return
        }
        
        UserDefaults.standard.set(newName, forKey: "userDisplayName")
        showAlert(message: "Display name updated successfully")
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Settings", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
