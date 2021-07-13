//
//  AppDelegate.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 09/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FirebaseMessaging
import SWRevealViewController
import DropDown
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,GIDSignInDelegate{
var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        applicationLoad()
        PushNotificationManager(application: application)
        handleUniversalLink(launchOptions:launchOptions)
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        guard let clect = GlobleVAR.currentPlay ,GlobleVAR.isVideoMode, CommonPlayerFunc.shared.isPlaying  else{return}
        CommonPlayerFunc.shared.pause()
        NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerState), object: nil)
        // change video mode to Audio mode
      //  GlobleVAR.mustAudio = true
       // NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerModel), object: ["playerModel":clect])
      //      GlobleVAR.mustAudio = true
      //      NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerModel), object: ["playerModel":clect])
    }
    
   
    internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = ApplicationDelegate.shared.application(app, open: url, options: options)

        return handled
    }
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        let mySessionID = "com.example.bgSession"
        let bgSessionConfig = URLSessionConfiguration.background(withIdentifier: mySessionID)
        
        let session = URLSession(configuration: bgSessionConfig)
        completionHandler()
    }
    
    
}
//MARK: GOOGLE SDK DELIGATE
extension AppDelegate{
    func sign(_ signIn: GIDSignIn!,didSignInFor user: GIDGoogleUser!,withError error:Error!) {
        
        // Check for sign in error
        if let error = error {
            CommonFunc.shared.switchAppLoader(value: false)
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        
        // Get credential object using Google ID token and Google access token
        guard let authentication = user.authentication else {
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        
        // Authenticate with Firebase using the credential object
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                CommonFunc.shared.switchAppLoader(value: false)
                
                print("Error occurs when authenticate with Firebase: \(error.localizedDescription)")
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                FRManager.shared.setInitalView()
            }

            print("CURRENT LOGGIN USER EMAIL--->\(Auth.auth().currentUser?.email)")
        }
    }
    
    func applicationLoad(){
        UIApplication.shared.setMinimumBackgroundFetchInterval(
          UIApplication.backgroundFetchIntervalMinimum)

        DropDown.startListeningToKeyboard()
        DropDown.appearance().selectionBackgroundColor = AppColors.primaryOring
        DropDown.appearance().selectedTextColor = UIColor.white
        DropDown.appearance().setupCornerRadius(10)
        FirebaseApp.configure()
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        FRManager.shared.setInitalView()
        CommonPlayerFunc.shared.setInitialPlayer()
    }
    
}


//MARK: FIR DYNAMIC LINKING
extension AppDelegate{
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
         
        guard Auth.auth().currentUser != nil else {
            print("USER NEED TO LOGIN FIRST")
            return false
        }
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            if (error != nil){
                print(error?.localizedDescription)
            }else {
                if let vc = UIApplication.getTopViewController(){
                    vc.navigationController?.popToRootViewController(animated: true)
                    vc.dismiss(animated: true, completion: nil)
                    vc.revealViewController()?.revealToggle(animated: true)
                }else{ }
                UnivarsalLinkHandler.shared.appHandle(with: dynamiclink)

            }
        }
        return handled
    }
    
  
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            
            return true
        }
        return false
    }
    //INIT FUNCTION FOR UNIVARSAL LINK
    func handleUniversalLink(launchOptions:[UIApplication.LaunchOptionsKey: Any]?){
        let activityKey = NSString(string: "UIApplicationLaunchOptionsUserActivityKey")
        if let userActivityDict = launchOptions?[.userActivityDictionary] as? [NSObject : AnyObject], let userActivity = userActivityDict[activityKey] as? NSUserActivity, let webPageUrl = userActivity.webpageURL {
            
            DynamicLinks.dynamicLinks().handleUniversalLink(webPageUrl) { (dynamiclink, error) in
                
                // do some stuff with dynamiclink
               
            }
            
        }else{
            print("NO UNIVERSAL LINK IS THER")
        }
    }
    
    
}

