//
//  PersistencyService.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 11/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import UIKit
import CoreData

class PersistencyService {

    static let shared = PersistencyService()

    weak var appDelegate = UIApplication.shared.delegate as? AppDelegate

    // MARK: - Add User to Core Data

    func addUser(user: User) {

        guard appDelegate != nil else {
            return
        }

        let context = appDelegate!.persistentContainer.viewContext

        let userToStore = CDUser(entity: CDUser.entity(), insertInto: context)

        userToStore.login = user.login
        userToStore.avatarUrl = user.avatarUrl
        userToStore.name = user.name
        userToStore.location = user.location
        userToStore.publicRepos = Int16(user.publicRepos)
        userToStore.publicGists = Int16(user.publicGists)
        userToStore.followers = Int32(user.followers)
        userToStore.following = Int32(user.following)

        print("🔋 Saving User to Core Data")
        appDelegate!.saveContext()
    }

    func deleteAllUsers() {

        guard appDelegate != nil else {
            return
        }

        let context = appDelegate!.persistentContainer.viewContext

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CDUser")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {

            try context.execute(deleteRequest)
            try context.save()

            print("🔥 Deleted users")

        } catch let error as NSError {
            print("Could not delete stored user data. \(error), \(error.userInfo)")
        }

    }

    func fetchUsers() -> [User]? {

        var users = [User]()

        let request = CDUser.fetchRequest() as NSFetchRequest<CDUser>
        guard appDelegate != nil else {
            return nil
        }

        let context = appDelegate!.persistentContainer.viewContext

        do {

            let result = try context.fetch(request)

            print("🔋 CORE DATA USER FETCHED WITH \(result.count) RESULTS")

            for item in result {
                let user = User(id: item.wrappedId,
                                login: item.wrappedLogin,
                                avatarUrl: item.wrappedAvatarUrl,
                                name: item.wrappedName,
                                publicRepos: item.wrappedPublicRepos,
                                publicGists: item.wrappedPublicGists,
                                followers: item.wrappedFollowers,
                                following: item.wrappedFollowing,
                                location: item.wrappedLocation
                            )
                users.append(user)
            }

            return users

        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        return nil
    }
}
