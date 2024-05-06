//
//  PollModel.swift
//  Ranger
//
//  Created by Vlad Kyrylenko on 22.03.2024.
//

import Foundation
import FirebaseFirestoreSwift

struct PollModel : Codable, Hashable {
    var id: String
    var creatorId: String
    var name: String
    var isClosed: Bool
    var password: String
    var alternatives: [String]
    var statistics: [String]
    var experts: [String]
    var gradationMin: String
    var gradationMax: String
}
