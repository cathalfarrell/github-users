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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        let userCellNib = UINib(nibName: "UserCell", bundle: nil)
        self.collectionView!.register(userCellNib, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        //Set up bar button item toggle
        toggleButton = UIBarButtonItem(title: "Grid", style: .plain, target: self,
                                       action: #selector(gridListButtonTapped(sender:)))
        self.navigationItem.setRightBarButton(toggleButton, animated: true)

    }

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

        DispatchQueue.main.async {
            self.navigationItem.setRightBarButton(self.toggleButton, animated: true)
            self.collectionView?.reloadData()
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
extension UsersVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        if isListView {
            return CGSize(width: width - 15, height: 120)
        }else {
            return CGSize(width: (width - 15)/2, height: (width - 15)/2)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
}
