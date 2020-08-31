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
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}
extension LoginViewController: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        //handle authorization

        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIdCredential.user
            let userFullName = appleIdCredential.fullName
            let userGivenName = userFullName?.givenName ?? "Missing Given Name"
            let userFamilyName = userFullName?.familyName ?? "Missing Family Name"
            let userEmail = appleIdCredential.email ?? "Missing email"

            //create an account for your system
            // for demo purposes store details in keychain
            print("✅ User Identifier: \(userIdentifier)")
            print("✅ User Given Name: \(userGivenName)")
            print("✅ User Family Name: \(userFamilyName)")
            print("✅ User Email: \(userEmail)")
        default:
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        //handle error
    }

}
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {

        return self.view.window!
    }
}
