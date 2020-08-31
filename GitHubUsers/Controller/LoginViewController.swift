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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performExistingAccountSetupFlows()
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

    // Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found
    func performExistingAccountSetupFlows() {
        // prepare requests for both Apple ID and password providers
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()
        ]

        // create an authorization controller with the given requests
        let controller = ASAuthorizationController(authorizationRequests: requests)
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

}
extension LoginViewController: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        //handle authorization

        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIdCredential.user
            let userFullName = appleIdCredential.fullName
            let userGivenName = userFullName?.givenName ?? "Missing Given Name"
            let userFamilyName = userFullName?.familyName ?? "Missing Family Name"
            let userEmail = appleIdCredential.email ?? "Missing email"

            // Create an account for your system

            print("✅ User Identifier: \(userIdentifier)")
            print("✅ User Given Name: \(userGivenName)")
            print("✅ User Family Name: \(userFamilyName)")
            print("✅ User Email: \(userEmail)")

            //print("Token \(appleIdCredential.identityToken)")

            // For demo purposes store details in keychain
            saveUserIdentifier(userIdentifier: userIdentifier)

            //Successful login so hide the login UI
            self.dismiss(animated: true, completion: nil)

        case let passwordCredential as ASPasswordCredential:
            // Sign in using an exisitng iCloud Keychain credential
            // For demo purposes just print
            print("✅ Password Credential User: \(passwordCredential.user)")
            print("✅ Password Credential Password: \(passwordCredential.password)")

            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password

            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }

        default:
            break
        }
    }

    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    func saveUserIdentifier(userIdentifier: String) {
        // Save into KeyChain here
        do {
            try KeychainItem(service: "com.cathalfarrell.GitHubUsers", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
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
extension UIViewController {

    func showLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            loginViewController.modalPresentationStyle = .formSheet
            loginViewController.isModalInPresentation = true
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
}
