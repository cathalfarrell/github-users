//
//  SearchUsersVC.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 11/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Kingfisher
import SwiftUI
import UIKit

private let reuseIdentifierList = "UserListCell"
private let reuseIdentifierGrid = "UserGridCell"

class SearchUsersVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    var users = [User]()

    var isListView = true
    var toggleButton = UIBarButtonItem()

    var deleteButton = UIBarButtonItem()

    var searchText: String?
    private var lastSearchedQuery = ""
    private var parameters = JSONDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupSearchBar()
        setupCollection()
    }

    fileprivate func setupSearchBar() {
        searchBar.placeholder = "Find a GitHub User"
        searchBar.delegate = self
    }

    fileprivate func setupCollection() {

        // Register cell classes
       let userCellNib = UINib(nibName: reuseIdentifierList, bundle: nil)
       let userCellGridNib = UINib(nibName: reuseIdentifierGrid, bundle: nil)
       self.collectionView.register(userCellNib, forCellWithReuseIdentifier: reuseIdentifierList)
       self.collectionView.register(userCellGridNib, forCellWithReuseIdentifier: reuseIdentifierGrid)
       self.collectionView.delegate = self
       self.collectionView.dataSource = self

       //Drag & Drop
       self.collectionView.dragDelegate = self
       self.collectionView.dropDelegate = self
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

        if let lastquery = parameters["q"] as? String {
            self.lastSearchedQuery = lastquery
        }

        self.users = users //replaced for now - will paginate later
        print("✅ Response: \(users.count) Users FOUND")
        self.collectionView.reloadData()
    }

    // MARK: - Grid/List Toggle

    @objc func gridListButtonTapped(sender: UIBarButtonItem) {

        hideSearchKeyboard()

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

        if let cells = collectionView.visibleCells as? [UserListCell] {
            for cell in cells {
                cell.isInEditingMode = false
            }
        }

        if let cells = collectionView.visibleCells as? [UserGridCell] {
            for cell in cells {
                cell.isInEditingMode = false
            }
        }
    }

    // MARK:- Editing i.e. To Delete Items Or Re-Order

    // Called when EDIT button tapped -> Enable Drag & Drop and Selection

    override func setEditing(_ editing: Bool, animated: Bool) {

        hideSearchKeyboard()

        super.setEditing(editing, animated: animated)
        self.collectionView.dragInteractionEnabled = editing
        self.collectionView.allowsMultipleSelection = editing

        let indexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            if let cell = collectionView.cellForItem(at: indexPath) as? UserListCell {
                cell.isInEditingMode = editing
            } else if let cell = collectionView.cellForItem(at: indexPath) as? UserGridCell {
                cell.isInEditingMode = editing
            }
        }

        if !editing {
            deleteButton.isEnabled = false
        }
    }

    @objc func deleteItem() {

        hideSearchKeyboard()

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

      hideSearchKeyboard()

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

    // MARK:- Image Download into cells

    fileprivate func downloadAvatarImage(_ user: User, _ cell: UICollectionViewCell) {

        // Using Kingfisher to asynchronously download and cache avatar
        let url = URL(string: user.avatarUrl)

        if let cell = cell as? UserListCell {

            let processor = DownsamplingImageProcessor(size: cell.avatarImageView.bounds.size)
                |> RoundCornerImageProcessor(cornerRadius: 20)
            cell.avatarImageView.kf.indicatorType = .activity
            cell.avatarImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholderImage"),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
            {
                result in
                switch result {
                case .success(let value):
                    print("✅ KF Image Task done: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("🛑 KF Image Task Job failed: \(error.localizedDescription)")
                }
            }
        }

        if let cell = cell as? UserGridCell {

             let processor = DownsamplingImageProcessor(size: cell.avatarImageView.bounds.size)
                 |> RoundCornerImageProcessor(cornerRadius: 20)
             cell.avatarImageView.kf.indicatorType = .activity
             cell.avatarImageView.kf.setImage(
                 with: url,
                 placeholder: UIImage(named: "placeholderImage"),
                 options: [
                     .processor(processor),
                     .scaleFactor(UIScreen.main.scale),
                     .transition(.fade(1)),
                     .cacheOriginalImage
                 ])
             {
                 result in
                 switch result {
                 case .success(let value):
                     print("✅ KF Image Task done: \(value.source.url?.absoluteString ?? "")")
                 case .failure(let error):
                     print("🛑 KF Image Task Job failed: \(error.localizedDescription)")
                 }
             }
         }
    }

}
extension SearchUsersVC: UICollectionViewDataSource  {

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let user = self.users[indexPath.row]

        if isListView {

            if let listCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierList,
                                                             for: indexPath) as? UserListCell {
                // Configure the List cell
                DispatchQueue.main.async {
                    listCell.configureCell(user: user)
                    self.downloadAvatarImage(user, listCell)
                }

                return listCell
            }

        } else {

            if let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierGrid,
                                                             for: indexPath) as? UserGridCell {
                // Configure the Grid cell
                DispatchQueue.main.async {
                    gridCell.configureCell(user: user)
                    self.downloadAvatarImage(user, gridCell)
                }

                return gridCell
            }

        }

        //Fallback
        return UICollectionViewCell()
    }
}
extension SearchUsersVC: UICollectionViewDelegate {

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        hideSearchKeyboard()

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

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        hideSearchKeyboard()

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
extension SearchUsersVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        if isListView {
            return CGSize(width: width - 15, height: 80)
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
extension SearchUsersVC: UICollectionViewDragDelegate {

    // MARK: UICollectionViewDragDelegate

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {

        let dragCoordinator = UserDragCoordinator(sourceIndexPath: indexPath)
        session.localContext = dragCoordinator
        return self.dragItems(for: indexPath)
    }
}
extension SearchUsersVC: UICollectionViewDropDelegate {

    // MARK: UICollectionViewDropDelegate

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {

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

    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {

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
extension SearchUsersVC {

    // MARK: - Search Functionality

    func searchFor(_ searchText: String?) {
        guard let searchText = searchText else {
          print("No search text found")
          return
        }

        if searchText != "" {
            print("Search for this: \(searchText)")
            hideSearchKeyboard()

            parameters["q"] = searchText

            if lastSearchedQuery != searchText {

                //Pagination
                /*
                let nextPage = Users.shared.getNextPage()
                if  nextPage > 0 {
                    parameters["page"] = "\(nextPage)"
                }
                */

                loadUsers(parameters)
            } else {
                print("No point making same network call for same search query as last time")
            }
        }
    }

    func hideSearchKeyboard() {
        view.endEditing(true)
    }
}
extension SearchUsersVC: UISearchBarDelegate {

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchFor(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    }
}
