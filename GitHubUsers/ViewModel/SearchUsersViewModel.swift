//
//  SearchUsersViewModel.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 27/08/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation
import UIKit

public class SearchUsersViewModel {

    // Bindings - As these update - the bound UI updates
    
    let parameters = Box(JSONDictionary())
    let mainText = Box("You can search for users of the GitHub API by username. " +
                              "Just enter some text in the above search bar and tap on the search key on the keyboard.")
    let errorText = Box("")
    let users = Box([User]())
    let errorViewHeight: Box<CGFloat> = Box(0)
    let isListView: Box<Bool> = Box(false)
    let searchQuery = Box("")

    init() {
        restoreAppState()
        restoreUsers()
    }

    // MARK: - Get Users

    func loadUsers(_ parameters: JSONDictionary) {

        self.errorText.value = ""
        self.errorViewHeight.value = 0

        UserDefaults.saveSearchParameters(parameters)

        Users.shared.loadDataToCoreData(with: parameters) { (result) in

            switch result {
            case .success(let users):
                print("✅ Response: \(users.count) Users Returned in this response")
                print("✅ Total Users Count for display: \(self.users.value.count)")

                // Update Users

                // If new results then we must replace all existing data (including stored data)
                // but if paginating just append to the existing data.

                if parameters.contains(where: { (key, _) -> Bool in key == pageKey}) {
                    //Paginating
                    self.users.value.append(contentsOf: users)
                } else {
                    //New Search
                    self.users.value = users

                }

                self.mainText.value = ""

                // Handle No Users
                if self.users.value.count == 0, parameters.contains(where: { (key, _) -> Bool in key == queryKey}) {
                    print("🙄 No users found")
                    self.errorText.value = "No users found."
                    self.errorViewHeight.value = 100
                }

                // Store Pagination Details
                self.parameters.value = parameters
                let nextPage = Users.shared.getNextPage()

                if  nextPage > 0 {
                    self.parameters.value[pageKey] = "\(nextPage)"
                }

                UserDefaults.saveSearchParameters(self.parameters.value)

            case .failure(let error):
                self.errorText.value = error.localizedDescription
                self.errorViewHeight.value = 100
                print("Error Text: \(error.localizedDescription)")
            }
        }
    }
}
extension SearchUsersViewModel {

    // MARK: - Persistence

    // Restore last search term and results returned

    fileprivate func restoreAppState() {

        //Restore app state by checking for any previously stored users & search parameters

        if let parametersFound = UserDefaults.restoreSearchParameters() {

            self.parameters.value = parametersFound

            if let searchTerm = parameters.value[queryKey] as? String {
                self.searchQuery.value = searchTerm
            }

            if let nextPage = parameters.value[pageKey] as? String {
                Users.shared.restoreNextPage(page: nextPage)
            }

            if let isListView = parameters.value[isListKey] as? Bool {
                self.isListView.value = isListView
            }
        }
    }

    fileprivate func restoreUsers() {

        if !self.parameters.value.isEmpty {

            print("🔥 PARAMS restored: \(parameters.value)")

            if let storedUsers = PersistencyService.shared.fetchUsers(), storedUsers.count > 0 {
                self.users.value = storedUsers

                self.mainText.value = ""

            } else {
                print("🔥 No fetched users to restore found.")
                self.users.value = [User]()
            }

            // Handle No Users
            if self.users.value.count == 0, parameters.value.contains(where: { (key, _) -> Bool in key == queryKey}) {
                print("🙄 No users found")
                self.errorText.value = "No users found."
                self.errorViewHeight.value = 100
            }
        }
    }
}
