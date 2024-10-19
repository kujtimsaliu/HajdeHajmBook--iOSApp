//
//  OrdersViewController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class OrdersViewController: UIViewController {
    
    // MARK: - Properties
    private var menuItems: [MenuItem] = []
    private var selectedItems: [MenuItem: Int] = [:]
    private let refreshControl = UIRefreshControl()
    private var currentUser: User?
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(MenuItemCell.self, forCellReuseIdentifier: "MenuItemCell")
        return tv
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .right
        return label
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Order", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchCurrentUser()
        fetchMenuItems()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "Menu"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(totalLabel)
        view.addSubview(submitButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: totalLabel.topAnchor, constant: -20),
            
            totalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            totalLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            totalLabel.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20),
            
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        
        submitButton.addTarget(self, action: #selector(submitOrder), for: .touchUpInside)
        
        // Setup refresh control
        refreshControl.addTarget(self, action: #selector(refreshMenuItems), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Data Fetching
    private func fetchCurrentUser() {
        FirestoreManager.shared.getCurrentUser { [weak self] result in
            switch result {
            case .success(let user):
                self?.currentUser = user
            case .failure(let error):
                print("Error fetching current user: \(error.localizedDescription)")
                // Handle error (e.g., show an alert to the user)
            }
        }
    }
    
    private func fetchMenuItems() {
        FirestoreManager.shared.fetchMenuItems { [weak self] result in
            switch result {
            case .success(let items):
                self?.menuItems = items
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refreshControl.endRefreshing()
                }
            case .failure(let error):
                print("Error fetching menu items: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    @objc private func refreshMenuItems() {
        fetchMenuItems()
    }
    
    private func updateTotalLabel() {
        let total = selectedItems.reduce(0) { $0 + ($1.key.price * $1.value) }
        totalLabel.text = "Total: \(total) MKD"
        
        if total > 150 {
            let excess = total - 150
            totalLabel.text?.append(" (You pay: \(excess) MKD)")
        }
        
        submitButton.isEnabled = !selectedItems.isEmpty
    }
    
    @objc private func submitOrder() {
            guard let currentUser = Auth.auth().currentUser else {
                showAlert(title: "Error", message: "You must be logged in to submit an order.")
                return
            }
            
            let orderItems = selectedItems.map { menuItem, quantity in
                OrderItem(menuItem: menuItem, quantity: quantity)
            }
            
            let order = Order(
                id: UUID().uuidString,
                userId: currentUser.uid,
                items: orderItems,
                date: Date(),
                isPaid: false,
                userName: currentUser.email ?? "Unknown User"
            )
            
            FirestoreManager.shared.saveOrder(order) { [weak self] result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Success", message: "Your order has been submitted.")
                        self?.clearOrder()
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Error", message: "Failed to submit order: \(error.localizedDescription)")
                    }
                }
            }
        }
    
    private func clearOrder() {
           selectedItems.removeAll()
           tableView.reloadData()
           updateTotalLabel()
       }
       
       private func showAlert(title: String, message: String) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
       }
    private func showOrderConfirmation() {
        let alert = UIAlertController(title: "Order Submitted", message: "Your order has been successfully submitted.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension OrdersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! MenuItemCell
        let menuItem = menuItems[indexPath.row]
        cell.configure(with: menuItem, quantity: selectedItems[menuItem] ?? 0)
        cell.delegate = self
        return cell
    }
}

// MARK: - MenuItemCellDelegate
extension OrdersViewController: MenuItemCellDelegate {
    func cell(_ cell: MenuItemCell, didUpdateQuantityFor menuItem: MenuItem, to quantity: Int) {
        if quantity > 0 {
            selectedItems[menuItem] = quantity
        } else {
            selectedItems.removeValue(forKey: menuItem)
        }
        updateTotalLabel()
    }
}
