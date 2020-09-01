//
//  Result.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 09/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
}
