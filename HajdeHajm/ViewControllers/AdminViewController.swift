import UIKit

class AdminViewController: UIViewController {
    
    // MARK: - Properties
    private var orders: [Order] = []
    private let datePicker = UIDatePicker()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let refreshControl = UIRefreshControl()
    private let copyButton = UIButton(type: .system)
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchOrders(for: Date())
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "Admin Dashboard"
        view.backgroundColor = .systemBackground
        
        setupDatePicker()
        setupTableView()
        setupCopyButton()
        setupRefreshControl()
        setupConstraints()
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
    }
    
    private func setupTableView() {
        tableView.register(OrderCell.self, forCellReuseIdentifier: "OrderCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setupCopyButton() {
        copyButton.setTitle("Copy Orders", for: .normal)
        copyButton.addTarget(self, action: #selector(copyOrdersToClipboard), for: .touchUpInside)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(copyButton)
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshOrders), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            copyButton.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor),
            copyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
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
                self?.orders = fetchedOrders.sorted(by: { $0.userName < $1.userName })
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
    
    @objc private func copyOrdersToClipboard() {
        let orderSummary = orders.map { order -> String in
//            let username = order.userName.components(separatedBy: "@").first ?? order.userName
            let items = order.items.map { "\($0.quantity) x \($0.menuItem.name)" }.joined(separator: "\n")
//            return "\(username):\n\(items)\n"
            return "\(items)\n"
        }.joined(separator: "\n")
        
        UIPasteboard.general.string = orderSummary
        showAlert(title: "Success", message: "Orders copied to clipboard")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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


// MARK: - UITableViewDelegate, UITableViewDataSource
extension AdminViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell
        let order = orders[indexPath.row]
        cell.configure(with: order)
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
}

// MARK: - OrderCell
class OrderCell: UITableViewCell {
    private let usernameLabel = UILabel()
    private let orderSummaryLabel = UILabel()
    private let totalLabel = UILabel()
    private let statusLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [usernameLabel, orderSummaryLabel, totalLabel, statusLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        orderSummaryLabel.font = UIFont.systemFont(ofSize: 14)
        orderSummaryLabel.numberOfLines = 2
        totalLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            orderSummaryLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            orderSummaryLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            orderSummaryLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            
            totalLabel.topAnchor.constraint(equalTo: orderSummaryLabel.bottomAnchor, constant: 4),
            totalLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            
            statusLabel.centerYAnchor.constraint(equalTo: totalLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with order: Order) {
        let username = order.userName.components(separatedBy: "@").first ?? order.userName
        usernameLabel.text = username
        
        let orderSummary = order.items.map { "\($0.quantity)x \($0.menuItem.name)" }.joined(separator: ", ")
        orderSummaryLabel.text = orderSummary
        
        totalLabel.text = "Total: \(order.total) MKD"
        statusLabel.text = order.isPaid ? "Paid" : "Not Paid"
        statusLabel.textColor = order.isPaid ? .systemGreen : .systemRed
    }
}
