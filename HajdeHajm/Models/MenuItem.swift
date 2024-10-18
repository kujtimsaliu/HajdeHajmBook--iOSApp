//
//  MenuItem.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import Foundation

struct MenuItem: Identifiable, Hashable {
    var id: String
    let name: String
    let description: String
    let price: Int
    let category: String?
    
    init(id: String = UUID().uuidString, name: String, description: String, price: Int, category: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.category = category
    }
}
