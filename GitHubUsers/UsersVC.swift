//
//  UsersVC.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 08/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import SwiftUI
import UIKit

private let reuseIdentifier = "UserCell"

class UsersVC: UICollectionViewController {

    var users = [User]()

    var isListView = true
    var toggleButton = UIBarButtonItem()
    var deleteButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        let userCellNib = UINib(nibName: reuseIdentifier, bundle: nil)
        self.collectionView.register(userCellNib, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        //Drag & Drop
        self.collectionView.dragDelegate = self
        self.collectionView.dropDelegate = self

        setupNavigationBar()

        let searchTerm = "tom" //hard-coded for now but searchbar later

        var parameters = JSONDictionary()
        parameters["q"] = searchTerm


        //Pagination
        let nextPage = Users.shared.getNextPage()
        if  nextPage > 0 {
            parameters["page"] = "\(nextPage)"
        }

        loadUsers(parameters)
    }

    fileprivate func setupNavigationBar() {

        //Set up Edit button & Delete Button
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self,
                                       action: #selector(deleteItem))
        navigationItem.leftBarButtonItems = [deleteButton, editButtonItem]
        deleteButton.isEnabled = false


        //Set up bar button item toggle
        toggleButton = UIBarButtonItem(title: "Grid", style: .plain, target: self,
                                       action: #selector(gridListButtonTapped(sender:)))
        self.navigationItem.setRightBarButton(toggleButton, animated: true)
    }

    // MARK:- Get Users

    fileprivate func loadUsers(_ parameters: JSONDictionary) {

        //Load Users - this method returns on Main Thread

        Users.shared.downloadUsersFromNetwork(with: parameters, success: { (users) in
            self.displayResults(users: users)
        }) { (errorString) in
            self.displayError(message: errorString)
        }

        //Get users from Persistency Manager later if time
    }

    // MARK: - Update UI

    func displayError(message: String) {
        print("🛑 Error: \(message)")
    }

    func displayResults(users: [User]) {
        self.users = users
        print("✅ Response: \(users.count) Users FOUND")
        self.collectionView.reloadData()
    }

    // MARK: - Grid/List Toggle

    @objc func gridListButtonTapped(sender: UIBarButtonItem) {
        if isListView {
            toggleButton = UIBarButtonItem(title: "List", style: .plain, target: self,
                                           action: #selector(gridListButtonTapped(sender:)))
            isListView = false
        }else {
            toggleButton = UIBarButtonItem(title: "Grid", style: .plain, target: self,
                                           action: #selector(gridListButtonTapped(sender:)))
            isListView = true
        }

        clearSelectedCells() // when we switch layouts its better

        DispatchQueue.main.async {
            self.navigationItem.setRightBarButton(self.toggleButton, animated: true)
            self.collectionView?.reloadData()
        }
    }

    func clearSelectedCells() {
        setEditing(false, animated: false)

        guard let cells = collectionView.visibleCells as? [UserCell] else {
            return
        }

        for cell in cells {
            cell.isInEditingMode = false
        }
    }

    // MARK:- Editing i.e. To Delete Items Or Re-Order

    // Called when EDIT button tapped -> Enable Drag & Drop and Selection

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.collectionView.dragInteractionEnabled = editing
        self.collectionView.allowsMultipleSelection = editing

        let indexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            if let cell = collectionView.cellForItem(at: indexPath) as? UserCell {
                cell.isInEditingMode = editing
            }
        }

        if !editing {
            deleteButton.isEnabled = false
        }
    }

    @objc func deleteItem() {
        if let selectedCells = collectionView.indexPathsForSelectedItems {
            let items = selectedCells.map { $0.item }.sorted().reversed()
            for item in items {
                users.remove(at: item)
            }
            collectionView.deleteItems(at: selectedCells)
        }
    }

    // MARK:- Drag/Drop Helpers

    func moveUser(at sourceIndex: Int, to destinationIndex: Int) {
      guard sourceIndex != destinationIndex else { return }

      let user = users[sourceIndex]
      users.remove(at: sourceIndex)
      users.insert(user, at: destinationIndex)
    }

    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        let item = self.users[indexPath.item]
        let itemProvider = NSItemProvider(object: item.login as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }

}
extension UsersVC  {

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                            for: indexPath) as? UserCell
        else {
            return UICollectionViewCell()
        }

        // Configure the cell
        DispatchQueue.main.async {
            cell.configureCell(user: self.users[indexPath.row])
        }

        return cell
    }
}
extension UsersVC {

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            toggleDeleteButton(collectionView)
        } else {
            // Just a normal tap to launch to Detail Screen
            let selectedUser = self.users[indexPath.row]
            let view = UserDetailView(user: selectedUser)
            let hostVC = UIHostingController(rootView: view)
            navigationController?.pushViewController(hostVC, animated: true)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        if isEditing {
            toggleDeleteButton(collectionView)
        }
    }

    fileprivate func toggleDeleteButton(_ collectionView: UICollectionView) {
        if let selectedCells = collectionView.indexPathsForSelectedItems {
            let enableButton = selectedCells.count > 0 && isEditing
            deleteButton.isEnabled = enableButton
        }
    }
}
extension UsersVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        if isListView {
            return CGSize(width: width - 15, height: 120)
        }else {
            return CGSize(width: (width - 15)/2, height: (width - 15)/2)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
}
extension UsersVC: UICollectionViewDragDelegate {

    // MARK: UICollectionViewDragDelegate

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragCoordinator = UserDragCoordinator(sourceIndexPath: indexPath)
        session.localContext = dragCoordinator
        return self.dragItems(for: indexPath)
    }
}
extension UsersVC: UICollectionViewDropDelegate {

    // MARK: UICollectionViewDropDelegate

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {

        guard session.items.count == 1 else {
          return UICollectionViewDropProposal(operation: .cancel)
        }

        if collectionView.hasActiveDrag {
          return UICollectionViewDropProposal(operation: .move,
                                              intent: .insertAtDestinationIndexPath)
        } else {
          return UICollectionViewDropProposal(operation: .copy,
                                              intent: .insertAtDestinationIndexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {

        // Get the datasource for this collection view
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
          destinationIndexPath = indexPath
        } else {
          // Drop first item at the end of the collection view
          destinationIndexPath =
            IndexPath(item: collectionView.numberOfItems(inSection: 0), section: 0)
        }
        let item = coordinator.items[0]

        switch coordinator.proposal.operation {
        case .move:
          guard let dragCoordinator =
            coordinator.session.localDragSession?.localContext as? UserDragCoordinator
            else { return }
          // Save information to calculate reordering
          if let sourceIndexPath = item.sourceIndexPath {
            print("Moving within the same collection view...")
            dragCoordinator.isReordering = true
            // Update datasource and collection view
            collectionView.performBatchUpdates({
              self.moveUser(at: sourceIndexPath.item, to: destinationIndexPath.item)
              collectionView.deleteItems(at: [sourceIndexPath])
              collectionView.insertItems(at: [destinationIndexPath])
            })
          }

          // Set flag to indicate drag completed
          dragCoordinator.dragCompleted = true
          coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        default:
          return
        }
    }
}
