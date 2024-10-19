//
//  AdminViewController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit

class AdminViewController: UIViewController {
    
    // MARK: - Properties
    private var orders: [Order] = []
    private let datePicker = UIDatePicker()
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchOrders(for: Date())
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "Admin View"
        view.backgroundColor = .systemBackground
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OrderCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(refreshOrders), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        view.addSubview(datePicker)
        view.addSubview(tableView)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Data Fetching
    private func fetchOrders(for date: Date) {
        FirestoreManager.shared.fetchAllOrdersForDate(date) { [weak self] result in
            switch result {
            case .success(let fetchedOrders):
                self?.orders = fetchedOrders
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refreshControl.endRefreshing()
                }
            case .failure(let error):
                print("Error fetching orders: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "Failed to fetch orders. Please try again.")
                    self?.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func dateChanged() {
        fetchOrders(for: datePicker.date)
    }
    
    @objc private func refreshOrders() {
        fetchOrders(for: datePicker.date)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AdminViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath)
        let order = orders[indexPath.row]
        
        cell.textLabel?.text = "\(order.userName) - Total: \(order.total) MKD"
        cell.detailTextLabel?.text = order.isPaid ? "Paid" : "Not Paid"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let order = orders[indexPath.row]
        showOrderDetails(order)
    }
    
    private func showOrderDetails(_ order: Order) {
        let alertController = UIAlertController(title: "Order Details", message: nil, preferredStyle: .actionSheet)
        
        for item in order.items {
            let itemDetails = "\(item.menuItem.name) x\(item.quantity) - \(item.menuItem.price * item.quantity) MKD"
            alertController.addAction(UIAlertAction(title: itemDetails, style: .default, handler: nil))
        }
        
        if !order.isPaid {
            alertController.addAction(UIAlertAction(title: "Mark as Paid", style: .default, handler: { [weak self] _ in
                self?.markOrderAsPaid(order)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func markOrderAsPaid(_ order: Order) {
        FirestoreManager.shared.markOrderAsPaid(order: order) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.fetchOrders(for: self?.datePicker.date ?? Date())
                }
            case .failure(let error):
                print("Error marking order as paid: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "Failed to mark order as paid. Please try again.")
                }
            }
        }
    }
}
