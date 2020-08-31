//
//  LoginViewController.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 31/08/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {

    @IBOutlet weak var loginProviderStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        loginProviderStackView.addArrangedSubview(button)
    }

    @objc
    func handleAuthorizationAppleIDButtonPress() {

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
