//
//  AdminOrderOverviewViewController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit

class AdminOrderOverviewViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Admin Order Overview"
        view.backgroundColor = .systemBackground
        
        // Add UI components to display all team members' orders
        // This is a placeholder implementation
        let label = UILabel()
        label.text = "Admin order overview will be displayed here"
        label.textAlignment = .center
        label.frame = view.bounds
        view.addSubview(label)
    }
}
