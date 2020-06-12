//
//  User.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 08/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

struct User {
    var id: Int
    var login: String
    var avatarUrl: String
    var name = ""
    var publicRepos = 0
    var publicGists = 0
    var followers = 0
    var following = 0
    var location: String?
}
extension User {

    // Sample User for Development - e.g. in SwiftUI View Previews

    static func sampleUser() -> User {
        let user = User(id: 123456789,
                        login: "cathalfarrell",
                        avatarUrl: "https://avatars2.githubusercontent.com/u/1584591?v=4",
                        name: "Cathal Farrell",
                        publicRepos: 10,
                        publicGists: 9,
                        followers: 8,
                        following: 7,
                        location: "Dublin, Ireland"
        )
        return user
    }
}
