//
//  URLExtensions.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 10/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation
extension URL {
    var params: [String: String]? {
        if let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) {
            if let queryItems = urlComponents.queryItems {
                var params = [String: String]()
                queryItems.forEach {
                    params[$0.name] = $0.value
                }
                return params
            }
        }
        return nil
    }
}
