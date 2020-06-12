//
//  UserDefaultsExtensions.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 12/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

enum UserDefaultsKey: String {
    case searchTerm = "searchTerm"
    case nextPage = "nextPage"
}

extension UserDefaults {

    static func saveSearchParameters(_ parameters: JSONDictionary) {
        
        //Store parameters for persistance
        if let searchTerm = parameters["q"] as? String {
            UserDefaults.standard.set(searchTerm, forKey: UserDefaultsKey.searchTerm.rawValue)
        } else {
             UserDefaults.standard.removeObject(forKey: UserDefaultsKey.searchTerm.rawValue)
        }

        if let nextPage = parameters["page"] as? String {
            UserDefaults.standard.set(nextPage, forKey: UserDefaultsKey.nextPage.rawValue)
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefaultsKey.nextPage.rawValue)
        }

        print("🔥 PARAMS Saved: \(parameters)")
    }

    static func restoreSearchParameters() -> JSONDictionary? {

        var parameters = JSONDictionary()

        if let searchTerm = UserDefaults.standard.string(forKey: UserDefaultsKey.searchTerm.rawValue) {
            parameters["q"] = searchTerm
        }

        if let nextPage = UserDefaults.standard.string(forKey: UserDefaultsKey.nextPage.rawValue) {
            parameters["page"] = nextPage
        }

        if parameters.isEmpty {
            return nil
        } else {
            return parameters
        }

    }
}
