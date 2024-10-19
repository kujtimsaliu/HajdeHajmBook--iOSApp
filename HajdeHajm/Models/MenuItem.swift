//
//  MenuItem.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import Foundation

struct MenuItem: Codable, Hashable {
    let name: String
    let description: String
    let price: Int
    let category: String?
    
    init(name: String, description: String, price: Int, category: String? = nil) {
        self.name = name
        self.description = description
        self.price = price
        self.category = category
    }
}
