//
//  Order.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import Foundation
import FirebaseFirestore

struct Order: Identifiable, Codable {
    let id: String
    let userId: String
    let items: [OrderItem]
    let date: Date
    var isPaid: Bool
    let userName: String
    
    var total: Int {
        return items.reduce(0) { $0 + ($1.menuItem.price * $1.quantity) }
    }
    
    var userOwes: Int {
        return max(0, total - 150)
    }
    
    init(id: String = UUID().uuidString, userId: String, items: [OrderItem], date: Date, isPaid: Bool = false, userName: String) {
        self.id = id
        self.userId = userId
        self.items = items
        self.date = date
        self.isPaid = isPaid
        self.userName = userName
    }
}

struct OrderItem: Codable {
    let menuItem: MenuItem
    let quantity: Int
}
