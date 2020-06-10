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
extension User {

    // Sample User for Development - e.g. in SwiftUI View Previews

    static func sampleUser() -> User {
        let user = User(login: "cathalfarrell",
                        avatarUrl: "https://avatars2.githubusercontent.com/u/1584591?v=4",
                        name: "Cathal Farrell")
        return user
    }
}
