//
//  ViewController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    // MARK: - Properties
    private var currentUser: User?
    private var menuItems: [MenuItem] = []
    private var currentOrder: Order?

    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "MenuItemCell")
        return tv
    }()

    private lazy var orderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Place Order", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(placeOrder), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchMenuItems()
        checkUserAuthentication()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(orderButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: orderButton.topAnchor, constant: -20),

            orderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            orderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            orderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            orderButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Data Fetching
    private func fetchMenuItems() {
        // Fetch menu items from Firebase
        // For now, let's add some dummy data
        menuItems = [
            MenuItem(id: "1", name: "Burger", description: "Delicious burger", price: 200, category: ""),
            MenuItem(id: "2", name: "Fries", description: "Crispy fries", price: 100,category: ""),
            MenuItem(id: "3", name: "Cola", description: "Refreshing drink", price: 80, category: "")
        ]
        tableView.reloadData()
    }

    private func checkUserAuthentication() {
//        if Auth.auth().currentUser == nil {
            presentLoginViewController()
//        } else {
            // User is already logged in, fetch user data if needed
//        }
    }

    private func presentLoginViewController() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true, completion: nil)
    }

    // MARK: - Actions
    @objc private func placeOrder() {
        // Handle order placement
        print("Order placed")
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath)
        let menuItem = menuItems[indexPath.row]
        cell.textLabel?.text = "\(menuItem.name) - \(menuItem.price) MKD"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentLoginViewController()
        print("tapped")
    }
}
