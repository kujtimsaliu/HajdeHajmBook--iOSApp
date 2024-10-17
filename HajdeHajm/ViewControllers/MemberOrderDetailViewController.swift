//
//  MemberOrderDetailViewController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit

class MemberOrderDetailViewController: UIViewController {
    var memberName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = memberName ?? "Order Detail"
        view.backgroundColor = .systemBackground
        
        // Add UI components to display member's order details
        // This is a placeholder implementation
        let label = UILabel()
        label.text = "Order details for \(memberName ?? "member") will be displayed here"
        label.textAlignment = .center
        label.frame = view.bounds
        view.addSubview(label)
    }
}

