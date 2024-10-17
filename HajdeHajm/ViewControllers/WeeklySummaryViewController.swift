//
//  WeeklySummaryViewController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit

class WeeklySummaryViewController: UIViewController {
    
    // MARK: - Properties
    private var weeklyOrders: [Date: [Order]] = [:]
    private var currentWeekStart: Date = Date().startOfWeek
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let weekLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let previousWeekButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("< Previous", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nextWeekButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next >", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let totalSpentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let companyPaidLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userOwesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dailyBreakdownStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false
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
        
        [weekLabel, previousWeekButton, nextWeekButton, totalSpentLabel, companyPaidLabel, userOwesLabel, dailyBreakdownStackView].forEach { contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            weekLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            weekLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            previousWeekButton.centerYAnchor.constraint(equalTo: weekLabel.centerYAnchor),
            previousWeekButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            nextWeekButton.centerYAnchor.constraint(equalTo: weekLabel.centerYAnchor),
            nextWeekButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            totalSpentLabel.topAnchor.constraint(equalTo: weekLabel.bottomAnchor, constant: 20),
            totalSpentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            totalSpentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            companyPaidLabel.topAnchor.constraint(equalTo: totalSpentLabel.bottomAnchor, constant: 10),
            companyPaidLabel.leadingAnchor.constraint(equalTo: totalSpentLabel.leadingAnchor),
            companyPaidLabel.trailingAnchor.constraint(equalTo: totalSpentLabel.trailingAnchor),
            
            userOwesLabel.topAnchor.constraint(equalTo: companyPaidLabel.bottomAnchor, constant: 10),
            userOwesLabel.leadingAnchor.constraint(equalTo: totalSpentLabel.leadingAnchor),
            userOwesLabel.trailingAnchor.constraint(equalTo: totalSpentLabel.trailingAnchor),
            
            dailyBreakdownStackView.topAnchor.constraint(equalTo: userOwesLabel.bottomAnchor, constant: 20),
            dailyBreakdownStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dailyBreakdownStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dailyBreakdownStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        previousWeekButton.addTarget(self, action: #selector(showPreviousWeek), for: .touchUpInside)
        nextWeekButton.addTarget(self, action: #selector(showNextWeek), for: .touchUpInside)
    }
    
    // MARK: - Data Fetching and Display
    private func fetchWeeklyOrders() {
        // In a real app, you would fetch this data from a database or API
        // For this example, we'll use dummy data
        let thisWeek = generateDummyOrders(for: currentWeekStart)
        let lastWeek = generateDummyOrders(for: currentWeekStart.addingTimeInterval(-7*24*60*60))
        
        weeklyOrders[currentWeekStart] = thisWeek
        weeklyOrders[currentWeekStart.addingTimeInterval(-7*24*60*60)] = lastWeek
        
        updateUI()
    }
    
    private func updateUI() {
        guard let orders = weeklyOrders[currentWeekStart] else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let startDateString = dateFormatter.string(from: currentWeekStart)
        let endDateString = dateFormatter.string(from: currentWeekStart.addingTimeInterval(6*24*60*60))
        weekLabel.text = "Week of \(startDateString) - \(endDateString)"
        
        let totalSpent = orders.reduce(0) { $0 + $1.total }
        totalSpentLabel.text = "Total spent: \(totalSpent) MKD"
        
        let companyPaid = min(orders.count * 150, totalSpent)
        companyPaidLabel.text = "Company paid: \(companyPaid) MKD"
        
        let userOwes = max(0, totalSpent - companyPaid)
        userOwesLabel.text = "You owe: \(userOwes) MKD"
        
        updateDailyBreakdown(orders: orders)
        
        nextWeekButton.isEnabled = currentWeekStart < Date().startOfWeek
    }
    
    private func updateDailyBreakdown(orders: [Order]) {
        dailyBreakdownStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        
        for i in 0...6 {
            let date = currentWeekStart.addingTimeInterval(TimeInterval(i * 24 * 60 * 60))
            let dateString = dateFormatter.string(from: date)
            
            let ordersForDay = orders.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            let totalForDay = ordersForDay.reduce(0) { $0 + $1.total }
            
            let dayLabel = UILabel()
            dayLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            dayLabel.text = "\(dateString): \(totalForDay) MKD"
            
            if !ordersForDay.isEmpty {
                let itemsLabel = UILabel()
                itemsLabel.font = UIFont.systemFont(ofSize: 12)
                itemsLabel.numberOfLines = 0
                itemsLabel.text = ordersForDay.flatMap { $0.items.map { "  • \($0.key.name) x\($0.value)" } }.joined(separator: "\n")
                
                let dayStackView = UIStackView(arrangedSubviews: [dayLabel, itemsLabel])
                dayStackView.axis = .vertical
                dayStackView.spacing = 5
                dailyBreakdownStackView.addArrangedSubview(dayStackView)
            } else {
                dailyBreakdownStackView.addArrangedSubview(dayLabel)
            }
        }
    }
    
    // MARK: - Actions
    @objc private func showPreviousWeek() {
        currentWeekStart = currentWeekStart.addingTimeInterval(-7*24*60*60)
        if weeklyOrders[currentWeekStart] == nil {
            weeklyOrders[currentWeekStart] = generateDummyOrders(for: currentWeekStart)
        }
        updateUI()
    }
    
    @objc private func showNextWeek() {
        currentWeekStart = currentWeekStart.addingTimeInterval(7*24*60*60)
        if weeklyOrders[currentWeekStart] == nil {
            weeklyOrders[currentWeekStart] = generateDummyOrders(for: currentWeekStart)
        }
        updateUI()
    }
    
    // MARK: - Helper Methods
    private func generateDummyOrders(for weekStart: Date) -> [Order] {
        var orders: [Order] = []
        for i in 0...6 {
            let date = weekStart.addingTimeInterval(TimeInterval(i * 24 * 60 * 60))
            if Int.random(in: 0...1) == 1 { // Randomly decide if there's an order for this day
                let items: [MenuItem: Int] = [
                    MenuItem(id: "1", name: "Burger", description: "", price: 120): Int.random(in: 1...2),
                    MenuItem(id: "2", name: "Fries", description: "", price: 60): Int.random(in: 0...1),
                    MenuItem(id: "3", name: "Cola", description: "", price: 40): Int.random(in: 0...1)
                ]
                orders.append(Order(userId: "1", items: items, date: date))
            }
        }
        return orders
    }
}

// MARK: - Date Extension
extension Date {
    var startOfWeek: Date {
        Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
}
