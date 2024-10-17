//
//  DailyOverviewViewController.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit

class DailyOverviewViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Daily Overview"
        view.backgroundColor = .systemBackground
        
        // Add a table view to display team members' orders
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
}

extension DailyOverviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10 // Placeholder: Replace with actual number of team members
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "TeamMemberCell")
        cell.textLabel?.text = "Team Member \(indexPath.row + 1)"
        cell.detailTextLabel?.text = "\(Int.random(in: 100...300)) MKD" // Placeholder: Replace with actual order amount
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = MemberOrderDetailViewController()
        detailVC.memberName = "Team Member \(indexPath.row + 1)" // Placeholder: Replace with actual member name
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
