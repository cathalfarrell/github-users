//
//  APIResponseUser.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 10/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

struct APIResponseUser: Codable {

    var login: String
    var avatarUrl: String
    var name: String
    var publicRepos: Int
    var publicGists: Int
    var followers: Int
    var following: Int
    var location: String

    enum CodingKeys: String, CodingKey {
        case login, name, followers, following, location
        case avatarUrl = "avatar_url"
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
    }
}
/*
 https://api.github.com/users/mojombo
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
 "name": "Tom Preston-Werner",
 "company": null,
 "blog": "http://tom.preston-werner.com",
 "location": "San Francisco",
 "email": null,
 "hireable": null,
 "bio": null,
 "twitter_username": null,
 "public_repos": 61,
 "public_gists": 62,
 "followers": 21993,
 "following": 11,
 "created_at": "2007-10-20T05:24:19Z",
 "updated_at": "2020-06-06T03:01:50Z"
}
 */
