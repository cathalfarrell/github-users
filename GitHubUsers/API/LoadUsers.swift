//
//  LoadUsers.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 10/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: Any]

class Users {
    
    static let shared = Users()
    let session = URLSession(configuration: .default)

    private var nextPage = 0

    // MARK: - Loads the data into the local Core Data Database for offline use.

    func loadDataToCoreData(with parameters: JSONDictionary,
                                  success succ: @escaping ([User]) -> Void,
                                  failure fail: @escaping (String) -> Void) {

        //Returning response on the main thread
        let success: ([User]) -> Void = { users in
            DispatchQueue.main.async { succ(users) }
        }
        let failure: (String) -> Void = { error in
            DispatchQueue.main.async { fail(String(describing: error)) }
        }

        downloadUsersFromNetwork(with: parameters, success: { (userItems) in

            var users = [User]()

            for item in userItems {
                //Only have limited User Details here...
                let user = User(id: item.id,
                                login: item.login,
                                avatarUrl: item.avatarUrl)
                users.append(user)

                //Store each to Persistence Manager
                DispatchQueue.main.async {
                    PersistencyService.shared.addUser(user: user)
                }
            }

            success(users)

        }) { (errorString) in

            failure(errorString)
        }
    }

    // MARK: - Get Users from Network

    func downloadUsersFromNetwork(with parameters: JSONDictionary,
                         success succ: @escaping ([UserItem]) -> Void,
                         failure fail: @escaping (String) -> Void) {

        //Returning response on the main thread
        let success: ([UserItem]) -> Void = { users in
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
                        success(userItems)
                    }

                case .failure(let err):

                    failure(err.localizedDescription)
                }
            }
        }
    }

    func handlePagination(nextPage: Int!) {

        if nextPage != nil {
            self.nextPage = nextPage
        } else {
            //If no next page link found then set this to zero
            self.nextPage = 0
        }

        print("➡️ Next Page: \(self.nextPage)")
    }

    func getNextPage() -> Int {
        return nextPage
    }


    // Set by persistency manager from stored search parameters when app restored
    
    func restoreNextPage(page: String) {
        if let intFromString = Int(page) {
            nextPage = intFromString
            print("➡️ Next Page Restored from defaults: \(self.nextPage)")
        }
    }

    // MARK: - Get User Detail

    func downloadUserDetailFromNetwork(with userName: String,
                         success succ: @escaping (User) -> Void,
                         failure fail: @escaping (String) -> Void) {

        //Returning response on the main thread
        let success: (User) -> Void = { user in
            DispatchQueue.main.async { succ(user) }
        }
        let failure: (String) -> Void = { error in
            DispatchQueue.main.async { fail(String(describing: error)) }
        }

        //Async on background
        DispatchQueue.global(qos: .background).async {

            UserService.shared.getUser(userName) { (resp) in
                switch resp {
                case .success(let resp):

                    //Convert Network Response to User Model
                    let user = User(id: resp.id,
                                    login: resp.login,
                                    avatarUrl: resp.avatarUrl,
                                    name: resp.name ?? "",
                                    publicRepos: resp.publicRepos,
                                    publicGists: resp.publicGists,
                                    followers: resp.followers,
                                    following: resp.following,
                                    location: resp.location ?? "")

                    //Store each to Persistence Manager
                    DispatchQueue.main.async {
                        PersistencyService.shared.addUser(user: user)
                    }

                    success(user)

                case .failure(let err):

                    failure(err.localizedDescription)
                }
            }
        }
    }
}
