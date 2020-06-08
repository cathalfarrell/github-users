//
//  User.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 08/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

struct User {
    var userName: String
    var fullName: String
}
extension User {

    //Used to help configure the basics - before network call or core data implemented

    static func getTestUsers() -> [User] {

        let user1 = User(userName: "AmyHanno", fullName: "Amy O'Hanlon")
        let user2 = User(userName: "BobbySox", fullName: "Bobby Sox")
        let user3 = User(userName: "Cathal", fullName: "Cathal Farrell")
        let user4 = User(userName: "Darah", fullName: "Darah Farrell")
        let user5 = User(userName: "Eilis", fullName: "Eilis Farrell")
        let user6 = User(userName: "Farrellyfox", fullName: "Farrell Fox")
        let user7 = User(userName: "GithubUser", fullName: "Another Github User")
        let user8 = User(userName: "HarryIsGreat", fullName: "Harry O'Sullivan")
        let user9 = User(userName: "IansKeys", fullName: "Ian Cunneen")

        let array = [user1, user2, user3, user4, user5, user6, user7, user8, user9]
        return array
    }
}
