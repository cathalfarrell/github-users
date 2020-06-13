//
//  CDUser+CoreDataProperties.swift
//  
//
//  Created by Cathal Farrell on 12/06/2020.
//
//  swiftlint:disable identifier_name

import Foundation
import CoreData

extension CDUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUser> {
        return NSFetchRequest<CDUser>(entityName: "CDUser")
    }

    @NSManaged public var avatarUrl: String?
    @NSManaged public var followers: Int32
    @NSManaged public var following: Int32
    @NSManaged public var location: String?
    @NSManaged public var login: String?
    @NSManaged public var name: String?
    @NSManaged public var publicGists: Int16
    @NSManaged public var publicRepos: Int16
    @NSManaged public var id: Int32

    public var wrappedLogin: String {
        login ?? "Unknown login name"
    }

    public var wrappedAvatarUrl: String {
        avatarUrl ?? "Unknown avatar url"
    }

    public var wrappedName: String {
        name ?? "Unknown name"
    }

    public var wrappedPublicRepos: Int {
        Int(publicRepos)
    }

    public var wrappedPublicGists: Int {
        Int(publicGists)
    }

    public var wrappedFollowers: Int {
        Int(followers)
    }

    public var wrappedFollowing: Int {
        Int(following)
    }

    public var wrappedLocation: String {
        name ?? "Unknown location"
    }

    public var wrappedId: Int {
        return Int(id)
    }

}
