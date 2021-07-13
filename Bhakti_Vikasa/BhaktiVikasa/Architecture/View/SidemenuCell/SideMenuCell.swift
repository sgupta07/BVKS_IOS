//
//  SideMenuCell.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 09/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit


class SideMenuHeaderCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setGradientBackground()
    }
    func setGradientBackground() {
        let colorTop =  UIColor(red: 16.0/255.0, green: 16.0/255.0, blue: 17.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 34.0/255.0, green: 65.0/255.0, blue: 83.0/255.0, alpha: 1.0).cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.1]
        gradientLayer.frame = self.contentView.bounds
                
        self.contentView.layer.insertSublayer(gradientLayer, at:0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func webSidelink(_ sender: UIButton) -> Void{
        CommonFunc.shared.openSafari(with:"http://bvks.com")
       // CommanFunc.shared.openWebView(url: "http://bvks.com")
    }
    @IBAction func fbLink(_ sender: UIButton) -> Void{
        //CommonFunc.shared.openSafari(with:"fb://page/BhaktiVikasaSwami/")//"https://www.facebook.com/BhaktiVikasaSwami/"
        
        
         func openFacebookPage() {
                    let facebookURL = NSURL(string: "fb://profile/872903862835384")!
                    if UIApplication.shared.canOpenURL(facebookURL as URL) {
                    UIApplication.shared.open(facebookURL as URL)
                } else {
                    UIApplication.shared.open(NSURL(string:
                     "https://www.facebook.com/BhaktiVikasaSwami/")! as URL)
                   }
              }
        //By Using PageId or name only
              func openFacebookPage(pageID:String) {
                    let facebookURL = NSURL(string: "fb://profile/\(pageID)")!
                    if UIApplication.shared.canOpenURL(facebookURL as URL) {
                    UIApplication.shared.open(facebookURL as URL)
                 } else {
                        UIApplication.shared.open(NSURL(string:"https://www.facebook.com/\(pageID)")! as URL)
                 }
             }
        //By Using Url only
             func openFacebookPageURL(url:String) {
                       let facebookURL = NSURL(string: url)!
                       if UIApplication.shared.canOpenURL(facebookURL as URL) {
                       UIApplication.shared.open(facebookURL as URL)
                    } else {
                       UIApplication.shared.open(NSURL(string: url)! as URL)
                    }
                }
        openFacebookPage()
    }
    @IBAction func yutubLinke(_ sender: UIButton) -> Void{
        CommonFunc.shared.openSafari(with:"https://www.youtube.com/user/BVKSMediaMinistry")

       // CommanFunc.shared.openWebView(url: "https://www.youtube.com/user/BVKSMediaMinistry")
    }
    @IBAction func instagramLinke(_ sender: UIButton) -> Void{
        CommonFunc.shared.openSafari(with:"https://www.instagram.com/hhbvs/")

       // CommanFunc.shared.openWebView(url: "https://www.instagram.com/hhbvs/")
    }

}


class SideMenuCell: UITableViewCell {
    @IBOutlet weak var ledingConst: NSLayoutConstraint!
    @IBOutlet weak var imgItem: UIImageView!
    
    @IBOutlet weak var lblItem: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
import StoreKit

class SideMenuRatingCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       // setGradientBackground()
    }
    func setGradientBackground() {
        let colorTop =  UIColor(red: 16.0/255.0, green: 16.0/255.0, blue: 17.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 34.0/255.0, green: 65.0/255.0, blue: 83.0/255.0, alpha: 1.0).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.1]
        gradientLayer.frame = self.contentView.bounds
        self.contentView.layer.insertSublayer(gradientLayer, at:0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   @IBAction func rateUsBVKS(_ sender:UIButton){
    
    SKStoreReviewController.requestReview()
       
   }



}
