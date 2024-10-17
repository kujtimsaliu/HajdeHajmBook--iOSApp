//
//  MainTabBarController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }

    private func setupViewControllers() {
        let ordersVC = UINavigationController(rootViewController: OrdersViewController())
        ordersVC.tabBarItem = UITabBarItem(title: "Orders", image: UIImage(systemName: "list.bullet"), tag: 0)

        let summaryVC = UINavigationController(rootViewController: WeeklySummaryViewController())
        summaryVC.tabBarItem = UITabBarItem(title: "Summary", image: UIImage(systemName: "chart.bar"), tag: 1)

        let profileVC = UIViewController()
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 2)

        viewControllers = [ordersVC, summaryVC, profileVC]
    }
}
