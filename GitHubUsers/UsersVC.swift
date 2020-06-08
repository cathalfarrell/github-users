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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        let userCellNib = UINib(nibName: "UserCell", bundle: nil)
        self.collectionView!.register(userCellNib, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

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
