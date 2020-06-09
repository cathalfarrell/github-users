//
//  UsersVC.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 08/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import UIKit

private let reuseIdentifier = "UserCell"

class UsersVC: UICollectionViewController {

    var users = User.getTestUsers()
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

        setupNavigationBar()
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

    // MARK:- Editing i.e. To Delete Items

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        collectionView.allowsMultipleSelection = editing
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
        toggleDeleteButton(collectionView)
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        toggleDeleteButton(collectionView)
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
