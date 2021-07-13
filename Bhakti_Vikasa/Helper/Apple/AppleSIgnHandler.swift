//
//  AppleSIgnHandler.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 19/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import AuthenticationServices

@available(iOS 13, *)
class AppleSignHAndler: NSObject {
    static let shared = AppleSignHAndler()
         private override init() {
             
         }
    
    func nativeAppleBTN(loginProviderView:UIView){
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleLogInWithAppleIDButtonPress), for: .touchUpInside)
        //loginProviderView.addArrangedSubview(authorizationButton)
        loginProviderView.addSubview(authorizationButton)
    }
    @objc private func handleLogInWithAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
            
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
       // authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

     func AppleExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(), ASAuthorizationPasswordProvider().createRequest()]

        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        //authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    func getUserState(userID:String){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userID) {  (credentialState, error) in
             switch credentialState {
                case .authorized:
                    // The Apple ID credential is valid.
                    break
                case .revoked:
                    // The Apple ID credential is revoked.
                    break
                case .notFound:
                    // No credential was found, so show the sign-in UI.
                break
                default:
                    break
             }
        }
    }
}


@available(iOS 13, *)
extension AppleSignHAndler:ASAuthorizationControllerDelegate{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
      //  print("\(error.localizedDescription)")
        //Handle error here
    }
    // ASAuthorizationControllerDelegate function for successful authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Create an account in your system.

            let userIdentifier = appleIDCredential.user
            let userFirstName = appleIDCredential.fullName?.givenName
            let userLastName = appleIDCredential.fullName?.familyName
            let userEmail = appleIDCredential.email
            print("User id is \(userIdentifier) \n Full Name is \(String(describing: userFirstName))  \(String(describing: userLastName)) \n Email id is \(String(describing: userEmail))")
            //Navigate to other view controller
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
               print(" UserName \(String(describing: username)) \n Password \(String(describing: password))")
            //Navigate to other view controller
        }
    }
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return UIApplication.getTopViewController()!.view.window!
    }
}
