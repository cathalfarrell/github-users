//
//  UserCell.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 08/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import UIKit
import Kingfisher

class UserListCell: UICollectionViewCell, SelfConfiguringCell {
    static let reuseIdentifier: String = "UserListCell"

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var checkmarkLabel: UILabel!

    var isInEditingMode: Bool = false {
        didSet {
            checkmarkLabel.isHidden = !isInEditingMode
        }
    }

    override var isSelected: Bool {
        didSet {
            if isInEditingMode {
                checkmarkLabel.text = isSelected ? "✓" : ""
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.avatarImageView.layer.cornerRadius = 25
        self.avatarImageView.clipsToBounds = true

    }

    func configure(with user: User) {

        let url = URL(string: user.avatarUrl)
        let processor = DownsamplingImageProcessor(size: avatarImageView.bounds.size)
            |> RoundCornerImageProcessor(cornerRadius: 20)
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ]) { result in
                //For Debug Purposes
                switch result {
                case .success(let value):
                    print("✅ KF Image Task done: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("🛑 KF Image Task Job failed: \(error.localizedDescription)")
                }

        }

        userName.text = user.login
    }

    override func prepareForReuse() {
        self.checkmarkLabel.text = ""
        self.userName.text = ""
        self.isInEditingMode = false
        self.isSelected = false
    }
}
