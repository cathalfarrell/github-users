//
//  UICollectionViewExtensions.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 11/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import UIKit

extension UICollectionView {

    func isLast(for indexPath: IndexPath) -> Bool {

        let indexOfLastSection = numberOfSections > 0 ? numberOfSections - 1 : 0
        let indexOfLastRowInLastSection = numberOfItems(inSection: indexOfLastSection) - 1

        return indexPath.section == indexOfLastSection && indexPath.row == indexOfLastRowInLastSection
    }
}
