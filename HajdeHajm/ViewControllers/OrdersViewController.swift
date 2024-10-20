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
    
    private let ttppButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("TTPP", for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
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
        button.backgroundColor = .gray
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
        view.addSubview(ttppButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        ttppButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: totalLabel.topAnchor, constant: -20),
            
            totalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            totalLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            totalLabel.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20),
            
            ttppButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ttppButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            ttppButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
            ttppButton.heightAnchor.constraint(equalToConstant: 50),
            
            submitButton.leadingAnchor.constraint(equalTo: ttppButton.trailingAnchor, constant: 10),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        
        submitButton.addTarget(self, action: #selector(submitOrder), for: .touchUpInside)
        ttppButton.addTarget(self, action: #selector(ttppButtonTapped), for: .touchUpInside)
        
        // Setup refresh control
        refreshControl.addTarget(self, action: #selector(refreshMenuItems), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func ttppButtonTapped() {
        let funnyMessages = [
            "🍽️ Too posh to pack lunch? Time to flex those culinary muscles!",
            "🏃‍♂️ Running away from office food? Don't forget your sneakers!",
            "🌯 Burrito cravings intensifying? Time for a food truck adventure!",
            "🥗 Salad bar looking sad? Time to find greener pastures!",
            "☕️ Coffee not cutting it? Time to caffeinate elsewhere!",
            "🍕 Pizza party for one? The city awaits your taste buds!",
            "🥪 Sandwich artist on strike? Time to be your own Picasso of lunch!",
            "🍜 Instant noodles losing their instant appeal? Ramen to the rescue!",
            "🍔 Burger urge surging? Time to flip the script on lunch!",
            "🌮 Taco Tuesday on a non-Tuesday? Rebel without a lunch cause!"
        ]
        
        let _ = funnyMessages.randomElement() ?? "Time to venture out for food!"
        
        let alertController = UIAlertController(title: "TTPP Activated!", message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Let's Go!", style: .default, handler: { _ in
            self.animateTTPPExit()
        }))
        
        alertController.addAction(UIAlertAction(title: "Maybe Later", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func animateTTPPExit() {
        let exitImage = UIImageView(image: UIImage(systemName: "figure.walk.circle"))
        exitImage.tintColor = .systemOrange
        exitImage.contentMode = .scaleAspectFit
        exitImage.frame = CGRect(x: view.frame.width, y: view.frame.height / 2 - 50, width: 100, height: 100)
        view.addSubview(exitImage)
        
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseInOut, animations: {
            exitImage.frame.origin.x = -100
        }) { _ in
            exitImage.removeFromSuperview()
//            self.showReturnAlert()
        }
    }
    
    private func showReturnAlert() {
        let alertController = UIAlertController(title: "Welcome Back!", message: "Hope you enjoyed your culinary adventure! Ready to order in next time?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "You Bet!", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
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
        submitButton.backgroundColor = selectedItems.isEmpty ? .gray : .systemBlue
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
