//
//  SearchUsersVC.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 11/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//
//  swiftlint:disable file_length

import SwiftUI
import UIKit
import Lottie

// DataSource & DataSourceSnapshot typealias
typealias DataSource = CustomDiffableDataSource
typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<CollectionSection, User>

class SearchUsersVC: UIViewController {

    private let viewModel = SearchUsersViewModel()

    //DataSourec & Snapshot
    private var dataSource: DataSource!
    private var snapshot = DataSourceSnapshot()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    private let refreshControl = UIRefreshControl()

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

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViewModel()
        setupNavigationBar()
        setupSearchBar()
        setupCollection()
    }

    override func viewWillAppear(_ animated: Bool) {
        // Use long press to detect re-order of cell action
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(self.reOrderOfCells(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }

    fileprivate func setUpViewModel() {

        // MARK: - View Model Bindings for UI Updates

        viewModel.parameters.bind { [weak self] (parameters) in
            self?.parameters = parameters
        }

        viewModel.mainText.bind { [weak self] text in
            self?.mainTextLabel.text = text
        }

        viewModel.errorText.bind { [weak self] text in
            self?.textLabel.text = text
        }

        viewModel.users.bind { [weak self] users in

            DispatchQueue.main.async {
                self?.applySnapshot(users: users, withAnimation: true)
                self?.stopLoadingAnimation()
                //If a new search then scroll back up to top
                if !(self?.parameters.contains(where: { (key, _) -> Bool in key == pageKey}) ?? false) {
                    self?.scrollToTopOfList()
                }
            }
        }

        viewModel.errorViewHeight.bind { [weak self] height in
            UIView.animate(withDuration: 2.0) {
                self?.errorViewHeight.constant = height
                if height == 100 {
                    self?.stopLoadingAnimation()
                }
            }
        }

        viewModel.isListView.bind { [weak self] isListView in
            self?.isListView = isListView
        }

        viewModel.searchQuery.bind { [weak self] searchQuery in
            self?.lastSearchedQuery = searchQuery
            self?.searchBar.text = searchQuery
        }
    }

    fileprivate func setupSearchBar() {
        searchBar.placeholder = "Find a GitHub User"
        searchBar.delegate = self
    }

    fileprivate func setupCollection() {

        // Register cell classes
        let userCellNib = UINib(nibName: UserListCell.reuseIdentifier, bundle: nil)
        let userCellGridNib = UINib(nibName: UserGridCell.reuseIdentifier, bundle: nil)
        self.collectionView.register(userCellNib, forCellWithReuseIdentifier: UserListCell.reuseIdentifier)
        self.collectionView.register(userCellGridNib, forCellWithReuseIdentifier: UserGridCell.reuseIdentifier)
        self.collectionView.delegate = self

        //Layout - Compositional
        self.collectionView.collectionViewLayout = createCompositionalLayout()

        //Pull to refresh
        self.collectionView.refreshControl = refreshControl
        self.refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)

        configureCollectionViewDataSource(forList: isListView)
    }

    fileprivate func setupNavigationBar() {

        //Set up Edit button & Delete Button
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self,
                                       action: #selector(deleteItems))
        navigationItem.leftBarButtonItems = [deleteButton, editButtonItem]
        deleteButton.isEnabled = false

        //Set up bar button item toggle
        toggleButton = UIBarButtonItem(title: isListView ? "Grid" : "List", style: .plain, target: self,
                                       action: #selector(gridListButtonTapped(sender:)))
        self.navigationItem.setRightBarButton(toggleButton, animated: true)
    }

    @objc private func refreshData() {

        // Allows pull to refresh to restore failure after error

        if isShowingError {

            startLoadingAnimation()

            viewModel.loadUsers(parameters)
        } else {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }

    fileprivate func scrollToTopOfList() {

        //Force scroll to top for any new search
        let topOffest = CGPoint(x: 0, y: -(self.collectionView?.contentInset.top ?? 0))
        DispatchQueue.main.async {
            self.collectionView?.setContentOffset(topOffest, animated: true)
        }
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

        configureCollectionViewDataSource(forList: isListView)
        collectionView.collectionViewLayout = createCompositionalLayout()

        DispatchQueue.main.async {
            self.navigationItem.setRightBarButton(self.toggleButton, animated: true)
            self.applySnapshot(users: self.snapshot.itemIdentifiers, withAnimation: false)
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

        self.collectionView.allowsMultipleSelection = editing

        if !editing {
            deleteButton.isEnabled = false
        }
    }

    @objc func deleteItems() {

        hideSearchKeyboard()

        if let selectedCells = collectionView.indexPathsForSelectedItems {
            let items = selectedCells.map { $0.item }.sorted().reversed()

            var usersToDelete = [User]()

            for item in items {
                let userToDelete = snapshot.itemIdentifiers[item]
                usersToDelete.append(userToDelete)
            }

            snapshot.deleteItems(usersToDelete)
            applySnapshot(users: self.snapshot.itemIdentifiers, withAnimation: true)
        }
    }

    // MARK: - Drag/Drop Helpers

    @objc func reOrderOfCells(gesture: UILongPressGestureRecognizer) {

        if isEditing {
            switch gesture.state {
            case .began:
                guard let selectedIndexPath = collectionView.indexPathForItem(at:
                    gesture.location(in: collectionView)) else {
                        break
                }
                collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            case .changed:
                collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            case .ended:
                collectionView.endInteractiveMovement()
                //Now that move has completed apply...
                let reorderedItems = dataSource.getReorderedItems()
                applySnapshot(users: reorderedItems, withAnimation: false)
            default:
                collectionView.cancelInteractiveMovement()
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
            guard let selectedUser = dataSource.itemIdentifier(for: indexPath) else {
                return
            }
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

    // MARK: Pagination - Request for next page made here when last row detected

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        // Pagination
        if collectionView.isLast(for: indexPath) {
            print("🔥 Reached last item in collection")

            if parameters.contains(where: { (key, _) -> Bool in key == pageKey}) {
                //Pagination available
                viewModel.loadUsers(parameters)
            }
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
            self.startLoadingAnimation()
            self.viewModel.loadUsers(parameters)

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
extension SearchUsersVC {

    // MARK: - CollectionView Set Up

    // Configure Cells
    func configure<T: SelfConfiguringCell>(_ cellType: T.Type, with user: User, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier,
                                                            for: indexPath) as? T else {
            fatalError("Unable to dequeue \(cellType)")
        }

        cell.configure(with: user)

        return cell
    }

    // Diffable Data Source
    private func configureCollectionViewDataSource(forList: Bool) {

        dataSource = DataSource(collectionView: collectionView) { _, indexPath, user in

            switch forList {
            case true:
                let cell = self.configure(UserListCell.self, with: user, for: indexPath)
                cell.isInEditingMode = self.isEditing
                return cell

            default:
                let cell = self.configure(UserGridCell.self, with: user, for: indexPath)
                cell.isInEditingMode = self.isEditing
                return cell
            }
        }
    }

    // Snapshot
    private func applySnapshot(users: [User], withAnimation: Bool) {

        snapshot = DataSourceSnapshot()
        snapshot.appendSections([CollectionSection.main])
        snapshot.appendItems(users)
        dataSource.apply(snapshot, animatingDifferences: withAnimation)

        PersistencyService.shared.updateUsers(users: users)
    }
}
extension SearchUsersVC {

    // MARK: - Compostional Layout

    func createCompositionalLayout() -> UICollectionViewLayout {

        let layout = UICollectionViewCompositionalLayout { _, _ in

            switch self.isListView {
            case true:
                return self.createListLayout()
            default:
                return self.createGridLayout()
            }
        }

        return layout
    }

    func createListLayout() -> NSCollectionLayoutSection {

        let rowHeight: CGFloat = 80

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .absolute(rowHeight))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                     heightDimension: .absolute(rowHeight))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitems: [layoutItem])

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        // Makes it a vertical list - stops horizontal scrolling
        layoutSection.orthogonalScrollingBehavior = .none
        return layoutSection
    }

    func createGridLayout() -> NSCollectionLayoutSection {

        let numberOfColumns: CGFloat = 2

        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/numberOfColumns),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalWidth(1/numberOfColumns))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // Section
        let section = NSCollectionLayoutSection(group: group)
        // Makes it a vertical list - stops horizontal scrolling
        section.orthogonalScrollingBehavior = .none

        return section
    }
}
