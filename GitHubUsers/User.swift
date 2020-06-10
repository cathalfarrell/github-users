//
//  User.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 08/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

struct User: Codable {
    var login: String
    var avatarUrl: String
    var name: String

    enum CodingKeys: String, CodingKey {
        case login, name
        case avatarUrl = "avatar_url"
    }
}
