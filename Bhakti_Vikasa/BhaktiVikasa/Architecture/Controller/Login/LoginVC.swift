//
//  LoginVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 09/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
import Toaster
import GoogleSignIn
import SWRevealViewController
import FBSDKLoginKit
import Firebase
import DropDown
class LoginVC: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        isFirestLogin = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        isFirestLogin = false
    }
    
    
    
    @IBAction func signinWithEamil(_ sender: UIButton) {
 
        fireEmail = txtEmail.text ?? ""
        firePassword = txtPassword.text ?? ""
        guard  CommonFunc.shared.isEmailValide(&fireEmail) else {return}
        guard  CommonFunc.shared.isPasswrdValide(&firePassword) else {return}
        CommonFunc.shared.switchAppLoader(value: true)


        
        FRManager.shared.signInWithEmail(completionBlock: {(authResult, err) in
            if err == nil{
               DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    FRManager.shared.setInitalView()
                }
            }else{
                let error = err?.localizedDescription ?? ""
                Toast(text: error).show()
            }
            CommonFunc.shared.switchAppLoader(value: false)
        })
        
    }
    @IBAction func createNewAccount(_ sender: UIButton) {

        fireEmail = txtEmail.text ?? ""
        firePassword = txtPassword.text ?? ""
        let vc = AppStorybords.login.instantiateViewController(withIdentifier: "CreateAccountVC")as! CreateAccountVC
        self.present(vc, animated: true, completion: {
            vc.txtEmail.text = fireEmail
            vc.txtPassword.text = firePassword
        })
       
       
    }
    @IBAction func forgetPassword(_ sender: UIButton) {
        fireEmail = txtEmail.text ?? ""
        firePassword = txtPassword.text ?? ""
        guard  CommonFunc.shared.isEmailValide(&fireEmail) else {return}
        CommonFunc.shared.switchAppLoader(value: true)

        FRManager.shared.ForgotPassWord(completionBlock: {(succes, err) in
            if succes == true{
                Toast(text: "Password re-set link is send to your email id.",duration:Delay.long ).show()

            }else{
               let error = err?.localizedDescription ?? ""
                Toast(text: error,duration:Delay.long ).show()
            }
            CommonFunc.shared.switchAppLoader(value: false)
        })
       }
    // MARK: - Navigation

   
    @IBAction func signWithGoogle(){
        GIDSignIn.sharedInstance()?.delegate = UIApplication.shared.delegate as! AppDelegate

        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        CommonFunc.shared.switchAppLoader(value: true)
    }
    @IBAction func appleLogin(sender: UIButton) {
       
        if #available(iOS 13, *) {
            FRAppleSignHandler.shared.startSignInWithAppleFlow()
        } else {
            // Fallback on earlier versions
            Toast(text: "You need to Update Device OS for  Apple login", duration: Delay.long).show()
        }
    }
    @IBAction func facebookLogin(sender: UIButton) {
        LoginManager().logOut()
        CommonFunc.shared.switchAppLoader(value: true)
        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                CommonFunc.shared.switchAppLoader(value: false)

                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = AccessToken.current else {
                CommonFunc.shared.switchAppLoader(value: false)

                print("Failed to get access token")
                return
            }
     
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in

                if let error = error {
                    CommonFunc.shared.switchAppLoader(value: false)

                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    FRManager.shared.setInitalView()

                }
                
            })
     
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

}
