//
//  AppleHandler.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 19/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//
//NOTE IOS 12 LOWER: ADD other linking Flaf <~> weak_framework CryptoKit
import Foundation
import CryptoKit
import Firebase
import AuthenticationServices

// Unhashed nonce.
@available(iOS 13, *)
class FRAppleSignHandler:NSObject{
    fileprivate var currentNonce: String?

    static let shared = FRAppleSignHandler()
       private override init() {
           
       }
//
//    func reauthenticateWithApple(){
//        // Initialize a fresh Apple credential with Firebase.
//        let credential = OAuthProvider.credential(
//          withProviderID: "apple.com",
//          IDToken: appleIdToken,
//          rawNonce: rawNonce
//        )
//        // Reauthenticate current Apple user with fresh Apple credential.
//        Auth.auth().currentUser.reauthenticate(with: credential) { (authResult, error) in
//          guard error != nil else { return }
//          // Apple user successfully re-authenticated.
//          // ...
//        }
//    }
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    

    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
       // authorizationController.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
      authorizationController.performRequests()
    }

    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
}
@available(iOS 13, *)
extension FRAppleSignHandler: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      // Initialize a Firebase credential.
      let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                idToken: idTokenString,
                                                rawNonce: nonce)
      // Sign in with Firebase.
      Auth.auth().signIn(with: credential) { (authResult, error) in
        if (error != nil) {
          // Error. If error.code == .MissingOrInvalidNonce, make sure
          // you're sending the SHA256-hashed nonce as a hex string with
          // your request to Apple.
            print(error?.localizedDescription)
          return
        }else{
            print("USer login WIth Apple")
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                FRManager.shared.setInitalView()
            }
        }
      }
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }

}
