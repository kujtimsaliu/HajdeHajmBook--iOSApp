//
//  User.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import Foundation

struct User: Codable {
    let id: String
    let email: String
    let name: String
    let isAdmin: Bool
}
