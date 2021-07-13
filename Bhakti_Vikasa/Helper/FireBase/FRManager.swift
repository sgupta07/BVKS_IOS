//
//  FireBaseHelper.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 09/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
import Toaster



class FRManager: NSObject {

    
    static let shared = FRManager()
       private override init() {
           
       }
    
private func isUserLoggedIn() -> Bool {
    if Auth.auth().currentUser != nil
    {
        guard Auth.auth().currentUser?.isEmailVerified == true else {
            sendVarificationEmail { (success, erro) in
                self.firebaseUserSignOut()
                if success == true{
                    Toast(text: "Verification Email has been sent to your email address. Please check your email and try after completing the verification.",duration: Delay.long).show()
                }else{
                    Toast(text: "ERROR: Faild to send Varification Email",duration: Delay.long).show()
                }
            }
            return false
            
        }
        return true
    }else{
        return  false
    }
}
   private func isValidEmail(_ email: String) -> Bool {
      let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
      return emailPred.evaluate(with: email)
    }
    
   private func isValidPassword(_ password: String) -> Bool {
      let minPasswordLength = 6
      return password.count >= minPasswordLength
    }
     func firebaseUserSignOut(){
        do {
          try Auth.auth().signOut()
            GIDSignIn.sharedInstance()?.signOut()
        } catch {
          print("Sign out error")
        }
    }
    private func getEmailAddress() ->String{
        if isUserLoggedIn(){
            return Auth.auth().currentUser?.email ?? ""
        }else{
            return fireEmail
        }
    }
     func setInitalView(){
        if isUserLoggedIn(){
            let authUser = Auth.auth().currentUser
            GlobleVAR.appUser.name = String(authUser?.email?.split(separator: "@").first ?? "")
            GlobleVAR.appUser.email = authUser?.email ?? ""
            GlobleVAR.appUser.uuid = authUser?.uid ?? ""
            if isFirestLogin{
                onUserNotificationAtSignIn()
            }
            CommonFunc.shared.setHoemInital()
          
            
        }else{

            CommonFunc.shared.setLoginital()

        }
    }
    

}
//MARK: USER WITH EMAIL
extension FRManager{
    func signUpWithEmail(completionBlock: @escaping (_ authUser: AuthDataResult?, _ authError: Error? )-> Void){
        let email = fireEmail
        let password = firePassword
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
          if let error = error as? NSError {
            defer {
                completionBlock(nil,error)
            }
            switch AuthErrorCode(rawValue: error.code) {
            case .operationNotAllowed:
                print("Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.")
              // Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.
            case .emailAlreadyInUse:
                print("Error: The email address is already in use by another account.")
              // Error: The email address is already in use by another account.
            case .invalidEmail:
                print(" Error: The email address is badly formatted.")
              // Error: The email address is badly formatted.
            case .weakPassword:
                print("Error: The password must be 6 characters long or more.")
              // Error: The password must be 6 characters long or more.
            default:
                print("Error: \(error.localizedDescription)")
            }
          } else {
            print("User signs up successfully")
            let newUserInfo = Auth.auth().currentUser
            let email = newUserInfo?.email
            completionBlock(authResult,nil)

          }
        }
    }
    
    func signInWithEmail(completionBlock: @escaping (_ authUser: AuthDataResult?, _ authError: Error? )-> Void){
        let email = fireEmail
        let password = firePassword
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
          if let error = error as? NSError {
            defer {
                completionBlock(nil,error)
            }
            switch AuthErrorCode(rawValue: error.code) {
            case .operationNotAllowed:
                print("Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.")
              // Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.
            case .userDisabled:
                print(" Error: The user account has been disabled by an administrator.")
              // Error: The user account has been disabled by an administrator.
            case .wrongPassword:
                print(" Error: The password is invalid or the user does not have a password.")
              // Error: The password is invalid or the user does not have a password.
            case .invalidEmail:
                print(" Error: Indicates the email address is malformed.")
              // Error: Indicates the email address is malformed.
            default:
                print("Error: \(error.localizedDescription)")
            }
          } else {
            print("User signs in successfully")
            let userInfo = Auth.auth().currentUser
            let email = userInfo?.email
            completionBlock(authResult,nil)
          }
        }
    }
    func ForgotPassWord(completionBlock: @escaping (_ success: Bool?, _ authError: Error? )-> Void){
        Auth.auth().sendPasswordReset(withEmail: getEmailAddress()) { (error) in
          if let error = error as? NSError {
            defer {
                completionBlock(false,error)
            }
            switch AuthErrorCode(rawValue: error.code) {
            case .userNotFound:
                print("Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.")
              // Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.
            case .invalidEmail:
                print("Error: The email address is badly formatted.")
              // Error: The email address is badly formatted.
            case .invalidRecipientEmail:
                print("Error: Indicates an invalid recipient email was sent in the request.")
              // Error: Indicates an invalid recipient email was sent in the request.
            case .invalidSender:
                print(" Error: Indicates an invalid sender email is set in the console for this action.")
              // Error: Indicates an invalid sender email is set in the console for this action.
            case .invalidMessagePayload:
                print("Error: Indicates an invalid email template for sending update email.")
              // Error: Indicates an invalid email template for sending update email.
            default:
              print("Error message: \(error.localizedDescription)")
            }
          } else {
            print("Reset password email has been successfully sent")
            completionBlock(true,nil)

          }
        }}
    func updateUserPassword(){
        Auth.auth().currentUser?.updatePassword(to: "", completion: { (error) in
          if let error = error as? NSError {
            switch AuthErrorCode(rawValue: error.code) {
            case .userDisabled:
                print("Error: The user account has been disabled by an administrator.")
              // Error: The user account has been disabled by an administrator.
            case .weakPassword:
                print("Error: The password must be 6 characters long or more.")
              // Error: The password must be 6 characters long or more.
            case .operationNotAllowed:
                print("Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.")
              // Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.
            case .requiresRecentLogin:
                print("Error: Updating a user’s password is a security sensitive operation that requires a recent login from the user. This error indicates the user has not signed in recently enough. To resolve, reauthenticate the user by invoking reauthenticateWithCredential:completion: on FIRUser.")
              // Error: Updating a user’s password is a security sensitive operation that requires a recent login from the user. This error indicates the user has not signed in recently enough. To resolve, reauthenticate the user by invoking reauthenticateWithCredential:completion: on FIRUser.
            default:
              print("Error message: \(error.localizedDescription)")
            }
          } else {
            print("User signs up successfully")
          }
        })
    }
    func updateUserEmail(){
        Auth.auth().currentUser?.updateEmail(to: getEmailAddress(), completion: { (error) in
          if let error = error as? NSError {
            switch AuthErrorCode(rawValue: error.code) {
            case .invalidRecipientEmail:
              // Error: Indicates an invalid recipient email was sent in the request.
              print("Indicates an invalid recipient email was sent in the request.")
            case .invalidSender:
              // Error: Indicates an invalid sender email is set in the console for this action.
              print("Indicates an invalid sender email is set in the console for this action.")
            case .invalidMessagePayload:
              // Error: Indicates an invalid email template for sending update email.
              print("Indicates an invalid email template for sending update email.")
            case .emailAlreadyInUse:
              // Error: The email address is already in use by another account.
              print("Email has been already used by another user.")
            case .invalidEmail:
              // Error: The email address is badly formatted.
              print("Email is not well formatted")
            case .requiresRecentLogin:
              // Error: Updating a user’s password is a security sensitive operation that requires a recent login from the user. This error indicates the user has not signed in recently enough. To resolve, reauthenticate the user by invoking reauthenticateWithCredential:completion: on FIRUser.
              print("Updating a user’s password is a security sensitive operation that requires a recent login from the user. This error indicates the user has not signed in recently enough. To resolve, reauthenticate the user by invoking reauthenticateWithCredential:completion: on FIRUser.")
            default:
              print("Error message: \(error.localizedDescription)")
            }
          } else {
            print("Update email is successful")
          }
        })
    }
    func deleteFireBaseUser(){
        Auth.auth().currentUser?.delete(completion: { (error) in
          if let error = error as? NSError {
            switch AuthErrorCode(rawValue: error.code) {
            case .operationNotAllowed:
              // Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.
              print("Email/ Password sign in provider is new disabled")
            case .requiresRecentLogin:
              // Error: Updating a user’s password is a security sensitive operation that requires a recent login from the user. This error indicates the user has not signed in recently enough. To resolve, reauthenticate the user by invoking reauthenticateWithCredential:completion: on FIRUser.
              print("Updating a user’s password is a security sensitive operation that requires a recent login from the user. This error indicates the user has not signed in recently enough. To resolve, reauthenticate the user by invoking reauthenticateWithCredential:completion: on FIRUser.")
            default:
              print("Error message: \(error.localizedDescription)")
            }
          } else {
            print("User account is deleted successfully")
          }
        })
    }
    
    func sendVarificationEmail(completionBlock: @escaping (_ success: Bool?, _ authError: Error? )-> Void){
        let authUser = Auth.auth().currentUser
        if authUser != nil && !authUser!.isEmailVerified {
            authUser!.sendEmailVerification(completion: { (error) in
                // Notify the user that the mail has sent or couldn't because of an error.
                if let error = error as? NSError {
                    completionBlock(false,error)
                }else{
                    completionBlock(true,error)
                }
            })
        }
        else {
            print("USER NOT LOGIN")
            // Either the user is not available, or the user is already verified.
        }
    }
}

extension FRManager{
    func googleSignOut(){
        GIDSignIn.sharedInstance()?.signOut()
        
        // Sign out from Firebase
        do {
            try Auth.auth().signOut()
            
            // Update screen after user successfully signed out
            self.setInitalView()
        } catch let error as NSError {
            print ("Error signing out from Firebase: %@", error)
        }
    }
}

//MARK: FIREBASE TOPIC NOTIFICATIONS
extension FRManager{
    enum Topics:String{
        case BVKS_ENGLISH
        case BVKS_HINDI
        case BVKS_BENGALI
    }
    func subscribe(with topic:Topics, isSubscribe:Bool){
        DispatchQueue.main.async {
            
        
        if isSubscribe {
            Messaging.messaging().subscribe(toTopic: topic.rawValue) { error in
                if let err = error{
                    Toast(text: "Fail subscribeption",duration: Delay.long).show()
                    print(err.localizedDescription)
                }else{
                    print("Subscribed to \(topic.rawValue) Lecture")
                }
            }
        }else{
            Messaging.messaging().unsubscribe(fromTopic: topic.rawValue) { error in
                if let err = error{
                    Toast(text: "Fail unsubscription",duration: Delay.long).show()
                    print(err.localizedDescription)
                }else{
                    print("unsubscribe to \(topic.rawValue) Lecture")
                }
            }
        }
        }
    }
    
    func subscribeAll(topics:[Topics]=[Topics.BVKS_ENGLISH,Topics.BVKS_HINDI,Topics.BVKS_BENGALI],isSubscribe:Bool){
        for (index,item) in topics.enumerated(){
            DispatchQueue.main.asyncAfter(deadline: .now()+Double(index)) {
                self.subscribe(with: item,isSubscribe: isSubscribe)
            }
        }
    }

    
    
  
    
    func onUserNotificationAtSignIn(){
        guard isFirestLogin == true else{return}
        Settinges.getUserSettings { (settinges) in
            print("FIRST LOGIN")
            guard let notification = settinges?.notification else{
                    print("create a default notification nodeif node is not present")
                    Settinges.setTodefaultSetting()
                return
            }
            print("subscribe user seting accroding to user prefrance")
            if notification.hindi == true{
                self.subscribe(with: .BVKS_HINDI,isSubscribe: true)
            }
            if notification.bengali == true{
                self.subscribe(with: .BVKS_BENGALI,isSubscribe: true)
            }
            if notification.english == true{
                self.subscribe(with: .BVKS_ENGLISH,isSubscribe: true)
            }
        }
    }
}
