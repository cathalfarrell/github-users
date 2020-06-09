//
//  UserDragCoordinator.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 09/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

// MARK: - Drag & Drop Helper

class UserDragCoordinator {

  let sourceIndexPath: IndexPath
  var dragCompleted = false
  var isReordering = false

  init(sourceIndexPath: IndexPath) {
    self.sourceIndexPath = sourceIndexPath
  }
}
