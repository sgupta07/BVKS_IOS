//
//  AboutVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 17/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
import SWRevealViewController
class AboutVC: UIViewController {
    @IBOutlet weak var btnSidemenu:UIButton!
    @IBOutlet weak var lblAtribut:UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initalLoad()
        // Do any additional setup after loading the view.
    }
    
    func initalLoad(){
        setAttributeText()
        self.btnSidemenu.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
        //        if self.revealViewController() != nil {
        //            revealViewController()?.rearViewRevealWidth = self.view.frame.width/1.5
        //            btnSidemenu.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        //            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        //        }
    }
    
    func setAttributeText(){
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.orange
        //His Holiness Bhakti Vikasa Swami is a Disciple of His Divine Grace A.C Bhaktivedanta Swami Prabhupada (Founder-acarya of International Society for Krishna Conciousness)
        
        let a1 = NSAttributedString(string: "His Holiness Bhakti Vikasa Swami is a Disciple of ", attributes: attributes)
        
        let a2 = NSAttributedString(string: "His Divine Grace A.C Bhaktivedanta Swami Prabhupada ", attributes:
                                        [.underlineStyle: NSUnderlineStyle.single.rawValue , .foregroundColor :#colorLiteral(red: 0.9364468455, green: 0.3832363486, blue: 0.21308887, alpha: 1)])
        let a3 = NSAttributedString(string: "(Founder-acarya of International Society for Krishna Conciousness)", attributes: attributes)
        let combination = NSMutableAttributedString()
        combination.append(a1)
        combination.append(a2)
        combination.append(a3)
        lblAtribut.attributedText = combination
    }
    @IBAction func openUrlAbout(sender : UIButton){
        
        CommonFunc.shared.openSafari(with:"https://bvks.com/about/srila-prabhupada/")
        
        //        CommonFunc.shared.openSafari(with:"http://bvks.com/about/bhakti-vikasa-swami/")
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @objc func backAction(sender:UIButton)->Void
    {
        self.navigationController?.popViewController(animated: true)
    }
}
