//
//  SearchUsersVC.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 11/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//
//  swiftlint:disable type_body_length
//  swiftlint:disable unused_closure_parameter
//  swiftlint:disable file_length

import Kingfisher
import SwiftUI
import UIKit
import Lottie

class SearchUsersVC: UIViewController {

    private let viewModel = SearchUsersViewModel()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    private let refreshControl = UIRefreshControl()

    private var users = [User]()

    private var isListView = true
    private var toggleButton = UIBarButtonItem()

    private var deleteButton = UIBarButtonItem()

    private var lastSearchedQuery = ""
    private var parameters = JSONDictionary()

    private var isNewSearch: Bool {
        if let searchText = searchBar.text {
            return (searchText != lastSearchedQuery)
        }
        return true
    }

    private var isShowingError: Bool {
        if let errorText = self.textLabel.text {
            return !errorText.isEmpty
        }
        return false
    }

    var loadingAnimationView: AnimationView!

    private let reuseIdentifierList = "UserListCell"
    private let reuseIdentifierGrid = "UserGridCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        restoreAppState()

        setupNavigationBar()
        setupSearchBar()
        setupErrorLabel()

        viewModel.mainText.bind { [weak self] text in
            self?.mainTextLabel.text = text
        }

        setupCollection()

        restoreUsers()
    }

    fileprivate func setupSearchBar() {
        searchBar.placeholder = "Find a GitHub User"
        searchBar.delegate = self
    }

    fileprivate func setupErrorLabel() {
        //hide until required, i.e. when error displayed
        self.errorViewHeight.constant = 0
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

       //Pull to refresh
       self.collectionView.refreshControl = refreshControl
       self.refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)

    }

    fileprivate func setupNavigationBar() {

        //Set up Edit button & Delete Button
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self,
                                       action: #selector(deleteItem))
        navigationItem.leftBarButtonItems = [deleteButton, editButtonItem]
        deleteButton.isEnabled = false

        //Set up bar button item toggle
        toggleButton = UIBarButtonItem(title: isListView ? "Grid" : "List", style: .plain, target: self,
                                       action: #selector(gridListButtonTapped(sender:)))
        self.navigationItem.setRightBarButton(toggleButton, animated: true)
    }

    // MARK: - Get Users

    fileprivate func loadUsers(_ parameters: JSONDictionary) {

        //Hide any errors showing
        DispatchQueue.main.async {
            self.textLabel.text = nil

            UIView.animate(withDuration: 2.0) {
                self.errorViewHeight.constant = 0
            }
        }

        startLoadingAnimation()

        UserDefaults.saveSearchParameters(parameters)

        Users.shared.loadDataToCoreData(with: parameters) { (result) in

            switch result {
            case .success(let users):
                self.displayResults(users: users)
            case .failure(let error):
                self.displayError(message: error.localizedDescription)
            }
        }
    }

    @objc private func refreshData() {

        // Allows pull to refresh to restore failure after error

        if isShowingError {
            loadUsers(parameters)
        } else {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Persistency

    // Restore last search term and results returned

    fileprivate func restoreAppState() {

        //Restore app state by checking for any previously stored users & search parameters

        if let parametersFound = UserDefaults.restoreSearchParameters() {

            self.parameters = parametersFound

            if let searchTerm = parameters[queryKey] as? String {
                self.lastSearchedQuery = searchTerm
                self.searchBar.text = searchTerm
            }

            if let nextPage = parameters[pageKey] as? String {
                Users.shared.restoreNextPage(page: nextPage)
            }

            if let isListView = parameters[isListKey] as? Bool {
                self.isListView = isListView
            }
        }
    }

    func restoreUsers() {
        if !self.parameters.isEmpty {

            print("🔥 PARAMS restored: \(parameters)")

            if let storedUsers = PersistencyService.shared.fetchUsers(), storedUsers.count > 0 {
                self.displayResults(users: storedUsers)
            } else {
                print("🔥 No fetched users to restore found.")
                handleNoUsers()
            }
        }
    }

    // MARK: - Update UI

    func displayError(message: String) {
        print("🛑 Error: \(message)")

        stopLoadingAnimation()

        DispatchQueue.main.async {
            self.textLabel.text = message

            UIView.animate(withDuration: 2.0) {
                self.errorViewHeight.constant = 100
            }
        }
    }

    fileprivate func update(_ users: [User]) {

        // If new results then we must replace all existing data (including stored data)
        // but if paginating just append to the existing data.

        if parameters.contains(where: { (key, _) -> Bool in key == pageKey}) {
            //Paginating
            self.users.append(contentsOf: users)
        } else {
            //New Search
            self.users = users
            self.scrollToTopOfList()
        }
    }

    func displayResults(users: [User]) {

        stopLoadingAnimation()

        update(users)

        print("✅ Response: \(users.count) Users Returned in this response")
        print("✅ Total Users Count for display: \(self.users.count)")

        handleNoUsers()

        storeNextPageDetails()

        DispatchQueue.main.async {
            self.mainTextLabel.isHidden = (self.users.count > 0)
            self.collectionView.reloadData()
        }
    }

    fileprivate func handleNoUsers() {
        //Show Error when no users found from a search query
        if self.users.count == 0, parameters.contains(where: { (key, _) -> Bool in key == queryKey}) {
            print("🙄 No users found")
            displayError(message: "No users found.")

            DispatchQueue.main.async {
                    //TODO - remove this once you move users to view model
                    self.viewModel.mainText.bind { [weak self] text in
                    self?.mainTextLabel.text = text
                }
            }
        }
    }

    fileprivate func scrollToTopOfList() {

        //Force scroll to top for any new search
        let topOffest = CGPoint(x: 0, y: -(self.collectionView?.contentInset.top ?? 0))
        DispatchQueue.main.async {
            self.collectionView?.setContentOffset(topOffest, animated: true)
        }
    }

    fileprivate func storeNextPageDetails() {

        let nextPage = Users.shared.getNextPage()

        if  nextPage > 0 {
            parameters[pageKey] = "\(nextPage)"
        }

        UserDefaults.saveSearchParameters(parameters)
    }

    // MARK: - Grid/List Toggle

    @objc func gridListButtonTapped(sender: UIBarButtonItem) {

        hideSearchKeyboard()

        if isListView {
            toggleButton = UIBarButtonItem(title: "List", style: .plain, target: self,
                                           action: #selector(gridListButtonTapped(sender:)))
            isListView = false
        } else {
            toggleButton = UIBarButtonItem(title: "Grid", style: .plain, target: self,
                                           action: #selector(gridListButtonTapped(sender:)))
            isListView = true
        }

        // Persist preference
        parameters[isListKey] = isListView
        UserDefaults.saveSearchParameters(parameters)

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

    // MARK: - Editing i.e. To Delete Items Or Re-Order

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

            DispatchQueue.main.async {
                self.collectionView.deleteItems(at: selectedCells)
                PersistencyService.shared.updateUsers(users: self.users)
                self.handleNoUsers()
            }
        }
    }

    // MARK: - Drag/Drop Helpers

    func moveUser(at sourceIndex: Int, to destinationIndex: Int) {

        hideSearchKeyboard()

        guard sourceIndex != destinationIndex else { return }

        let user = users[sourceIndex]
        users.remove(at: sourceIndex)
        users.insert(user, at: destinationIndex)

        DispatchQueue.main.async {
            PersistencyService.shared.updateUsers(users: self.users)
        }
    }

    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        let item = self.users[indexPath.item]
        let itemProvider = NSItemProvider(object: item.login as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }

    // MARK: - Image Download into cells

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
                ]) { result in
                    /* //For Debug Purposes
                    switch result {
                    case .success(let value):
                        print("✅ KF Image Task done: \(value.source.url?.absoluteString ?? "")")
                    case .failure(let error):
                        print("🛑 KF Image Task Job failed: \(error.localizedDescription)")
                    }
                    */
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
                 ]) { result in

                 /* //For Debug Purposes
                 switch result {
                 case .success(let value):
                     print("✅ KF Image Task done: \(value.source.url?.absoluteString ?? "")")
                 case .failure(let error):
                     print("🛑 KF Image Task Job failed: \(error.localizedDescription)")
                 }
                 */
             }
         }
    }

}
extension SearchUsersVC: UICollectionViewDataSource {

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

    // MARK: Pagination - Request for next page made here when last row detected

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        if collectionView.isLast(for: indexPath) {
            print("🔥 Reached last item in collection")

            if parameters.contains(where: { (key, _) -> Bool in key == pageKey}) {
                //Pagination available
                loadUsers(parameters)
            }
        }
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
        } else {
            return CGSize(width: (width - 15)/2, height: (width - 15)/2)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
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

        hideSearchKeyboard()

        guard let query = searchText, !query.isEmpty else {
          print("No search text found")
          return
        }

        if isNewSearch || isShowingError {

            removeUserData()

            parameters[queryKey] = query
            lastSearchedQuery = query

            print("🔥 Making fresh search for users with name: \(query)")
            loadUsers(parameters)

        } else {
            print("🛑 No point making same network call for same search query as last time")
        }
    }

    fileprivate func removeUserData() {

        // For a fresh request we need to remove last results from data store,
        // reset pagination data and remove previous users, before requesting the new users

        parameters.removeValue(forKey: pageKey)
        Users.shared.restoreNextPage(page: "0")
        PersistencyService.shared.deleteAllUsers()
    }

    func hideSearchKeyboard() {
        view.endEditing(true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideSearchKeyboard()
    }
}
extension SearchUsersVC: UISearchBarDelegate {

    // MARK: - UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchFor(searchBar.text)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    }
}
extension SearchUsersVC {

    // MARK: - Loading Animation from Lottie

    func startLoadingAnimation() {

        let midX = UIScreen.main.bounds.midX
        let midY = UIScreen.main.bounds.midY
        let size: CGFloat = 100
        let offset: CGFloat = size/2

        if loadingAnimationView == nil {

            loadingAnimationView = AnimationView(name: "LoadingAnimation")
            loadingAnimationView.frame = CGRect(x: midX-offset, y: midY, width: size, height: size)
            loadingAnimationView.loopMode = .loop

            if let animation = Animation.named("18357-spinner-dots") {
                loadingAnimationView.animation = animation
            } else {
                print("🛑 Animation not found.")
            }
        }

        print("🌈 Load animation")

        DispatchQueue.main.async {
            self.view.addSubview(self.loadingAnimationView)
            self.loadingAnimationView.play()
        }
    }

    func stopLoadingAnimation() {
        if let animation = loadingAnimationView {
            DispatchQueue.main.async {
                animation.stop()
                animation.removeFromSuperview()

                self.collectionView.refreshControl?.endRefreshing()
            }
        }
    }
}
