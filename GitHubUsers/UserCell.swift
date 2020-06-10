//
//  UserCell.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 08/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import UIKit

class UserCell: UICollectionViewCell {

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
        // Initialization code
    }

    func configureCell(user: User){
        self.userName.text = user.login
    }

    override func prepareForReuse() {
        self.checkmarkLabel.text = ""
        self.userName.text = ""
        self.isInEditingMode = false
        self.isSelected = false
    }
}
