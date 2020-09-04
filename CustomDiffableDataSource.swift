//
//  CustomDiffableDataSource.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 04/09/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import UIKit

enum CollectionSection {
    case main
}

class CustomDiffableDataSource: UICollectionViewDiffableDataSource<CollectionSection, User> {

    var reorderedItems = [User]()

    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {

        let sourceIndex = sourceIndexPath.row
        let destinationIndex = destinationIndexPath.row
        guard sourceIndex != destinationIndex else { return }

        reorderedItems = self.snapshot().itemIdentifiers
        let userToMove = reorderedItems[sourceIndex]
        reorderedItems.remove(at: sourceIndex)
        reorderedItems.insert(userToMove, at: destinationIndex)

    }

    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func getReorderedItems() -> [User] {
        return reorderedItems
    }
}
