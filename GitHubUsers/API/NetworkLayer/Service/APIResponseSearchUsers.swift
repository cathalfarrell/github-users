//
//  APIResponseSearchUsers.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 09/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

struct UserItem: Codable {
    var login: String
    var avatarUrl: String

    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
    }
}

struct APIResponseSearchUsers: Codable {

    var items: [UserItem]!
    var nextPage: Int!

    enum CodingKeys: String, CodingKey {
        case items
    }
}
/*
 // Sample Response = https://api.github.com/search/users?q=tom+repos:%3E42+followers:%3E1000

 {
 "total_count": 8,
 "incomplete_results": false,
 "items": [
 {
 "login": "mojombo",
 "id": 1,
 "node_id": "MDQ6VXNlcjE=",
 "avatar_url": "https://avatars0.githubusercontent.com/u/1?v=4",
 "gravatar_id": "",
 "url": "https://api.github.com/users/mojombo",
 "html_url": "https://github.com/mojombo",
 "followers_url": "https://api.github.com/users/mojombo/followers",
 "following_url": "https://api.github.com/users/mojombo/following{/other_user}",
 "gists_url": "https://api.github.com/users/mojombo/gists{/gist_id}",
 "starred_url": "https://api.github.com/users/mojombo/starred{/owner}{/repo}",
 "subscriptions_url": "https://api.github.com/users/mojombo/subscriptions",
 "organizations_url": "https://api.github.com/users/mojombo/orgs",
 "repos_url": "https://api.github.com/users/mojombo/repos",
 "events_url": "https://api.github.com/users/mojombo/events{/privacy}",
 "received_events_url": "https://api.github.com/users/mojombo/received_events",
 "type": "User",
 "site_admin": false,
 "score": 1
 },
 */
