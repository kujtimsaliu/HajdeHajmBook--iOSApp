//
//  PaymentTrackingViewController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit

class PaymentTrackingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Payment Tracking"
        view.backgroundColor = .systemBackground
        
        // Add UI components to display payment tracking information
        // This is a placeholder implementation
        let label = UILabel()
        label.text = "Payment tracking information will be displayed here"
        label.textAlignment = .center
        label.frame = view.bounds
        view.addSubview(label)
    }
}
