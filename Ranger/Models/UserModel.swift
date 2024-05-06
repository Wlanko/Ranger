//
//  UserModel.swift
//  Ranger
//
//  Created by Vlad Kyrylenko on 22.03.2024.
//

import Foundation

struct UserModel : Codable {
    var expertName: String
    var createdPolls: [String]
}
