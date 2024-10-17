//
//  Order.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import Foundation

struct Order {
    let userId: String
    let items: [MenuItem: Int]
    let date: Date
    var total: Int {
        return items.reduce(0) { $0 + $1.key.price * $1.value }
    }
}
