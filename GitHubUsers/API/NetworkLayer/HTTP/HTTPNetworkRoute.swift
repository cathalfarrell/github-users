//
//  HTTPNetworkRoute.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 09/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

public enum HTTPNetworkRoute: String {
    case search = "search/users"
    case user = "users/:id"
}
