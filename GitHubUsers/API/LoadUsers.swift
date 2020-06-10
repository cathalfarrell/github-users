//
//  LoadUsers.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 10/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

typealias JSONDICTIONARY = [String: Any]

class Users {
    
    static let shared = Users()
    let session = URLSession(configuration: .default)

    private var currentPage = 0
    private var nextPage = 0

    func downloadUsersFromNetwork(with parameters: JSONDICTIONARY,
                         success succ: @escaping ([User]) -> Void,
                         failure fail: @escaping (String) -> Void) {

        //Returning response on the main thread
        let success: ([User]) -> Void = { users in
            DispatchQueue.main.async { succ(users) }
        }
        let failure: (String) -> Void = { error in
            DispatchQueue.main.async { fail(String(describing: error)) }
        }

        //Async on background
        DispatchQueue.global(qos: .background).async {

            SearchUsersService.shared.getUsers(parameters) { (resp) in

                switch resp {
                case .success(let resp):

                    Users.shared.handlePagination(nextPage: resp.nextPage)

                    if let userItems = resp.items {
                        var users = [User]()

                        for item in userItems {
                            let user = User(login: item.login, avatarUrl: item.avatarUrl, name: "")
                            users.append(user)
                        }

                        success(users)
                    }

                case .failure(let err):

                    failure(err.localizedDescription)
                }
            }
        }
    }

    func handlePagination(nextPage: Int!) {

        self.currentPage += 1

        if nextPage != nil {
            self.nextPage = nextPage
        } else {
            //If no next page link found then set this to zero
            self.nextPage = 0
        }

        print("⬆️ Current Page: \(self.currentPage)")
        print("➡️ Next Page: \(self.nextPage)")
    }

    func getCurrentPage() -> Int {
        return currentPage
    }

    func getNextPage() -> Int {
        return nextPage
    }
}
