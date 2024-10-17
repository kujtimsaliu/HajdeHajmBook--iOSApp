//
//  OrderSummaryViewController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit

class OrderSummaryViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Order Summary"
        view.backgroundColor = .systemBackground
        
        // Add UI components to display order summary
        // This is a placeholder implementation
        let label = UILabel()
        label.text = "Your order summary will be displayed here"
        label.textAlignment = .center
        label.frame = view.bounds
        view.addSubview(label)
    }
}
