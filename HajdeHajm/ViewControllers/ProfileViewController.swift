//
//  ProfileViewController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    private var window: UIWindow?
    // MARK: - UI Components
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Settings", for: .normal)
        button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var paymentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Payment Information", for: .normal)
        button.addTarget(self, action: #selector(openPaymentInfo), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var orderHistoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Order History", for: .normal)
        button.addTarget(self, action: #selector(openOrderHistory), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var signoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.addTarget(self, action: #selector(signout), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func signout(){
        do {
            try Auth.auth().signOut()
            window?.rootViewController = LoginViewController(window: window)
            
        }catch{
            print("failed to sign out")
        }
    }
    
    init(window: UIWindow?){
        super.init(nibName: nil, bundle: nil)
        self.window = window
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(settingsButton)
        view.addSubview(paymentButton)
        view.addSubview(orderHistoryButton)
        view.addSubview(signoutButton)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            settingsButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 40),
            settingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            paymentButton.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 20),
            paymentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            paymentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            orderHistoryButton.topAnchor.constraint(equalTo: paymentButton.bottomAnchor, constant: 20),
            orderHistoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            orderHistoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            signoutButton.topAnchor.constraint(equalTo: orderHistoryButton.bottomAnchor, constant: 20),
            signoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func loadUserData() {
        // In a real app, you would fetch this data from your user management system
        nameLabel.text = "John Doe"
        profileImageView.image = UIImage(systemName: "person.circle.fill")
    }
    
    // MARK: - Action Methods
    @objc private func openSettings() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc private func openPaymentInfo() {
        let paymentVC = PaymentViewController()
        navigationController?.pushViewController(paymentVC, animated: true)
    }
    
    @objc private func openOrderHistory() {
        let orderHistoryVC = OrderHistoryViewController()
        navigationController?.pushViewController(orderHistoryVC, animated: true)
    }
}
