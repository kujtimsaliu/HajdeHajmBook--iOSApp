//
//  MainTabBarController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit
import Firebase

import FirebaseAuth

class MainTabBarController: UITabBarController {
    
    private var currentUser: FirebaseAuth.User?
    var window: UIWindow?
    
    init(window: UIWindow?, currentUser: FirebaseAuth.User?) {
        super.init(nibName: nil, bundle: nil)
        print("current user: \(String(describing: currentUser?.email))")
        self.window = window
        self.currentUser = currentUser
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }
    

    private func setupViewControllers() {
        let ordersVC = UINavigationController(rootViewController: OrdersViewController())
        ordersVC.tabBarItem = UITabBarItem(title: "Orders", image: UIImage(systemName: "list.bullet"), tag: 0)

        let summaryVC = UINavigationController(rootViewController: WeeklySummaryViewController())
        summaryVC.tabBarItem = UITabBarItem(title: "Summary", image: UIImage(systemName: "chart.bar"), tag: 1)

        let profileVC = UINavigationController(rootViewController: ProfileViewController(window: window))
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 2)

        var viewControllers = [ordersVC, summaryVC, profileVC]
        
        if Auth.auth().currentUser?.email == "kujtimsaliu011@gmail.com" {
            let adminVC = UINavigationController(rootViewController: AdminViewController())
            adminVC.tabBarItem = UITabBarItem(title: "Admin", image: UIImage(systemName: "gear"), tag: 3)
            viewControllers.append(adminVC)
        }

        self.viewControllers = viewControllers
    }
}
