//
//  CreateAccountVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 09/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
import Toaster
class CreateAccountVC: UIViewController {
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtRePassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func closeAccountView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func createNewAccount(_ sender: UIButton) {
        
        
        fireEmail = txtEmail.text ?? ""
        firePassword = txtPassword.text ?? ""
        var confirmPWD = txtRePassword.text ?? ""
        guard  CommonFunc.shared.isEmailValide(&fireEmail) else {return}
        guard  CommonFunc.shared.isPasswrdValide(&firePassword) else {return}
        guard  CommonFunc.shared.isConfirmPWDValide(&confirmPWD) else {return}
        guard  CommonFunc.shared.isConfirmPWDmatch(&firePassword, &confirmPWD) else {return}
        
        
        CommonFunc.shared.switchAppLoader(value: true)
        
        FRManager.shared.signUpWithEmail(completionBlock: {(authResult, err) in
            CommonFunc.shared.switchAppLoader(value: false)
            
            if err == nil{
                Toast(text: "Profile Is created Successfully!").show()
                
                self.dismiss(animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                        FRManager.shared.setInitalView()
                    }
                })
                //self.sendAccountVarificationEmail()
            }else{
                let error = err?.localizedDescription ?? ""
                Toast(text: error,duration: Delay.long).show()
                
            }
            
        })
        
    }
    private func sendAccountVarificationEmail(){
        FRManager.shared.sendVarificationEmail { (success, erro) in
            if success == true{
               
                Toast(text: "Verification Email is send to your Email Address, Please check your Email Box").show()
                self.dismiss(animated: true, completion: nil)
            }else{
                Toast(text: "ERROR: Faild to send Verification Email").show()
                self.dismiss(animated: true, completion: nil)
                
            }
        }
    }
}
