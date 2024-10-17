//
//  AdminViewController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit

class AdminViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Admin"
        view.backgroundColor = .systemBackground
        
        let orderOverviewButton = UIBarButtonItem(title: "Orders", style: .plain, target: self, action: #selector(showOrderOverview))
        let paymentTrackingButton = UIBarButtonItem(title: "Payments", style: .plain, target: self, action: #selector(showPaymentTracking))
        navigationItem.rightBarButtonItems = [paymentTrackingButton, orderOverviewButton]
    }
    
    @objc private func showOrderOverview() {
        let overviewVC = AdminOrderOverviewViewController()
        navigationController?.pushViewController(overviewVC, animated: true)
    }
    
    @objc private func showPaymentTracking() {
        let paymentVC = PaymentTrackingViewController()
        navigationController?.pushViewController(paymentVC, animated: true)
    }
}
