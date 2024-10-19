//
//  WeeklySummaryViewController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class WeeklySummaryViewController: UIViewController {
    
    // MARK: - Properties
    private var weeklyOrders: [Date: [Order]] = [:]
    private var currentWeekStart: Date = Date().startOfWeek
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let weekSelectorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let weekLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let previousWeekButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        return button
    }()
    
    private let nextWeekButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        return button
    }()
    
    private let summaryView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let totalSpentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let companyPaidLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let userOwesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let weeklyPaymentStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let weeklyPayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Mark Week as Paid", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let dailyBreakdownStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        return sv
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        fetchWeeklyOrders()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "Weekly Summary"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [weekSelectorView, summaryView, dailyBreakdownStackView].forEach { contentView.addArrangedSubview($0) }
        
        setupWeekSelectorView()
        setupSummaryView()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    private func setupWeekSelectorView() {
        weekSelectorView.addSubview(weekLabel)
        weekSelectorView.addSubview(previousWeekButton)
        weekSelectorView.addSubview(nextWeekButton)
        
        [weekLabel, previousWeekButton, nextWeekButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            weekLabel.centerYAnchor.constraint(equalTo: weekSelectorView.centerYAnchor),
            weekLabel.centerXAnchor.constraint(equalTo: weekSelectorView.centerXAnchor),
            
            previousWeekButton.centerYAnchor.constraint(equalTo: weekSelectorView.centerYAnchor),
            previousWeekButton.leadingAnchor.constraint(equalTo: weekSelectorView.leadingAnchor, constant: 20),
            
            nextWeekButton.centerYAnchor.constraint(equalTo: weekSelectorView.centerYAnchor),
            nextWeekButton.trailingAnchor.constraint(equalTo: weekSelectorView.trailingAnchor, constant: -20),
            
            weekSelectorView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupSummaryView() {
        let stackView = UIStackView(arrangedSubviews: [totalSpentLabel, companyPaidLabel, userOwesLabel, weeklyPaymentStatusLabel, weeklyPayButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        summaryView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: summaryView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: summaryView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        previousWeekButton.addTarget(self, action: #selector(showPreviousWeek), for: .touchUpInside)
        nextWeekButton.addTarget(self, action: #selector(showNextWeek), for: .touchUpInside)
        weeklyPayButton.addTarget(self, action: #selector(markWeekAsPaid), for: .touchUpInside)
    }
    
    // MARK: - Data Fetching and Display
    private func fetchWeeklyOrders() {
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "User not logged in")
            return
        }
        
        print("Fetching orders for user: \(userId), week starting: \(currentWeekStart)")
        
        firestoreManager.fetchWeeklyOrders(for: currentWeekStart, userId: userId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let orders):
                print("Successfully fetched \(orders.count) orders")
                
                let calendar = Calendar.current
                var groupedOrders: [Date: [Order]] = [:]
                
                for order in orders {
                    let startOfDay = calendar.startOfDay(for: order.date)
                    if groupedOrders[startOfDay] == nil {
                        groupedOrders[startOfDay] = []
                    }
                    groupedOrders[startOfDay]?.append(order)
                }
                
                self.weeklyOrders = groupedOrders
                
                print("Processed \(self.weeklyOrders.count) days with orders")
                
                DispatchQueue.main.async {
                    self.updateUI()
                }
                
            case .failure(let error):
                print("Error fetching weekly orders: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to fetch orders. Please try again.")
                }
            }
        }
    }
    
    
    
    private func updateUI() {
        updateWeekLabel()
        updateSummaryView()
        updateDailyBreakdown()
        
        nextWeekButton.isEnabled = currentWeekStart < Date().startOfWeek
    }
    
    private func updateWeekLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let startDateString = dateFormatter.string(from: currentWeekStart)
        let endDateString = dateFormatter.string(from: currentWeekStart.addingTimeInterval(6*24*60*60))
        weekLabel.text = "\(startDateString) - \(endDateString)"
    }
    
    private func updateSummaryView() {
        let totalSpent = weeklyOrders.values.flatMap { $0 }.reduce(0) { $0 + $1.total }
        let companyPaid = min(weeklyOrders.count * 150, totalSpent)
        let userOwes = max(0, totalSpent - companyPaid)
        
        totalSpentLabel.text = "Total spent: \(totalSpent) MKD"
        companyPaidLabel.text = "Company paid: \(companyPaid) MKD"
        userOwesLabel.text = "You owe: \(userOwes) MKD"
        
        let allPaid = weeklyOrders.values.flatMap { $0 }.allSatisfy { $0.isPaid }
        weeklyPaymentStatusLabel.text = "Week status: \(allPaid ? "Paid" : "Not Paid")"
        weeklyPayButton.isHidden = allPaid
    }
    
    private func updateDailyBreakdown() {
        dailyBreakdownStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        
        for i in 0...6 {
            let date = currentWeekStart.addingTimeInterval(TimeInterval(i * 24 * 60 * 60))
            let dateString = dateFormatter.string(from: date)
            
            let orders = weeklyOrders[date.startOfDay] ?? []
            
            let dayView = createDayView(dateString: dateString, orders: orders)
            dailyBreakdownStackView.addArrangedSubview(dayView)
        }
    }
    
    private func createDayView(dateString: String, orders: [Order]) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLabel = UILabel()
        dateLabel.text = dateString
        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        stackView.addArrangedSubview(dateLabel)
        
        if !orders.isEmpty {
            for order in orders {
                let orderView = createOrderView(order: order)
                stackView.addArrangedSubview(orderView)
            }
        } else {
            let noOrderLabel = UILabel()
            noOrderLabel.text = "No order"
            noOrderLabel.font = UIFont.systemFont(ofSize: 14)
            noOrderLabel.textColor = .systemGray
            
            stackView.addArrangedSubview(noOrderLabel)
        }
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        return containerView
    }
    
    private func createOrderView(order: Order) -> UIView {
        let orderView = UIView()
        orderView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let totalLabel = UILabel()
        totalLabel.text = "Total: \(order.total) MKD"
        totalLabel.font = UIFont.systemFont(ofSize: 14)
        
        let statusLabel = UILabel()
        statusLabel.text = "Status: \(order.isPaid ? "Paid" : "Not Paid")"
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        
        let toggleButton = UIButton(type: .system)
        toggleButton.setTitle(order.isPaid ? "Mark as Unpaid" : "Mark as Paid", for: .normal)
        toggleButton.tag = order.id.hashValue
        toggleButton.addTarget(self, action: #selector(toggleOrderPaymentStatus), for: .touchUpInside)
        
        [totalLabel, statusLabel, toggleButton].forEach { stackView.addArrangedSubview($0) }
        
        orderView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: orderView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: orderView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: orderView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: orderView.bottomAnchor)
        ])
        
        return orderView
    }
    
    private func createDayView(dateString: String, order: Order?) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLabel = UILabel()
        dateLabel.text = dateString
        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        stackView.addArrangedSubview(dateLabel)
        
        if let order = order {
            let totalLabel = UILabel()
            totalLabel.text = "Total: \(order.total) MKD"
            totalLabel.font = UIFont.systemFont(ofSize: 14)
            
            let statusLabel = UILabel()
            statusLabel.text = "Status: \(order.isPaid ? "Paid" : "Not Paid")"
            statusLabel.font = UIFont.systemFont(ofSize: 14)
            
            let toggleButton = UIButton(type: .system)
            toggleButton.setTitle(order.isPaid ? "Mark as Unpaid" : "Mark as Paid", for: .normal)
            toggleButton.tag = order.id.hashValue
            toggleButton.addTarget(self, action: #selector(toggleOrderPaymentStatus), for: .touchUpInside)
            
            [totalLabel, statusLabel, toggleButton].forEach { stackView.addArrangedSubview($0) }
        } else {
            let noOrderLabel = UILabel()
            noOrderLabel.text = "No order"
            noOrderLabel.font = UIFont.systemFont(ofSize: 14)
            noOrderLabel.textColor = .systemGray
            
            stackView.addArrangedSubview(noOrderLabel)
        }
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        return containerView
    }
    
    // MARK: - Actions
    @objc private func showPreviousWeek() {
        currentWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart)!
        fetchWeeklyOrders()
    }
    
    @objc private func showNextWeek() {
        currentWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart)!
        fetchWeeklyOrders()
    }
    
    @objc private func markWeekAsPaid() {
        guard Auth.auth().currentUser != nil else {
            showAlert(title: "Error", message: "You must be logged in to perform this action.")
            return
        }
        
        let unpaidOrders = weeklyOrders.values.flatMap { $0 }.filter { !$0.isPaid }
        
        if unpaidOrders.isEmpty {
            showAlert(title: "Info", message: "All orders for this week are already marked as paid.")
            return
        }
        
        print("Attempting to mark \(unpaidOrders.count) orders as paid")
        
        firestoreManager.markOrdersAsPaid(orders: unpaidOrders) { [weak self] result in
            switch result {
            case .success:
                print("Successfully marked orders as paid")
                DispatchQueue.main.async {
                    self?.fetchWeeklyOrders() // Refresh the data
                    self?.showAlert(title: "Success", message: "All unpaid orders have been marked as paid.")
                }
            case .failure(let error):
                print("Error marking week as paid: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "Failed to mark week as paid. Error: \(error.localizedDescription)")
                }
            }
        }
    }
    @objc private func toggleOrderPaymentStatus(_ sender: UIButton) {
        guard let order = weeklyOrders.values.flatMap({ $0 }).first(where: { $0.id.hashValue == sender.tag }) else { return }
        
        firestoreManager.toggleOrderPaymentStatus(order: order) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.fetchWeeklyOrders() // Refresh the data
                }
            case .failure(let error):
                print("Error toggling order payment status: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "Failed to update order status. Please try again.")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Date Extension
extension Date {
    //    var startOfDay: Date {
    //        return Calendar.current.startOfDay(for: self)
    //    }
    
    var startOfWeek: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
