//
//  ProfileViewController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit

class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .systemBackground
        
        // Add UI components for user profile, logout button, and payment history
        // This is a placeholder implementation
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        logoutButton.frame = CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 44)
        view.addSubview(logoutButton)
    }
    
    @objc private func logout() {
        // Implement logout functionality
        print("User logged out")
    }
}
