//
//  MenuScreen.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit

class MenuScreen: UIViewController {
    private var menuItems: [MenuItem] = []
    private var selectedItems: [MenuItem: Int] = [:]
    
    // MARK: - UI Components
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(MenuItemCell.self, forCellReuseIdentifier: "MenuItemCell")
        return tv
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .red
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Order", for: .normal)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateDateLabel()
        fetchMenuItems()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(dateLabel)
        view.addSubview(tableView)
        view.addSubview(totalLabel)
        view.addSubview(warningLabel)
        view.addSubview(submitButton)
        
        // Add constraints here
        
        tableView.delegate = self
        tableView.dataSource = self
        
        submitButton.addTarget(self, action: #selector(submitOrder), for: .touchUpInside)
    }
    
    private func updateDateLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMM"
        dateLabel.text = dateFormatter.string(from: Date())
    }
    
    private func fetchMenuItems() {
        // Fetch menu items from your data source (e.g., API or local database)
        // For now, let's use dummy data
        menuItems = [
            MenuItem(id: "1", name: "Burger", description: "Delicious beef burger", price: 120),
            MenuItem(id: "2", name: "Fries", description: "Crispy fries", price: 60),
            MenuItem(id: "3", name: "Cola", description: "Refreshing drink", price: 40)
        ]
        tableView.reloadData()
    }
    
    private func updateTotalAndWarning() {
        let total = selectedItems.reduce(0) { $0 + ($1.key.price * $1.value) }
        totalLabel.text = "Total: \(total) MKD"
        
        if total > 150 {
            warningLabel.text = "Warning: Total exceeds 150 MKD"
            warningLabel.isHidden = false
        } else {
            warningLabel.isHidden = true
        }
        
        submitButton.isEnabled = !selectedItems.isEmpty
    }
    
    @objc private func submitOrder() {
        // Implement order submission logic
        print("Order submitted")
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MenuScreen: UITableViewDelegate, UITableViewDataSource {
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
extension MenuScreen: MenuItemCellDelegate {
    func cell(_ cell: MenuItemCell, didUpdateQuantityFor menuItem: MenuItem, to quantity: Int) {
        if quantity > 0 {
            selectedItems[menuItem] = quantity
        } else {
            selectedItems.removeValue(forKey: menuItem)
        }
        updateTotalAndWarning()
    }
}
