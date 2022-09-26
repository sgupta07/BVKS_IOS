//
//  SideMenuVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 09/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
import SWRevealViewController
import LinkPresentation
import Toaster
class SideMenuVC: UIViewController {
    private let sectionItems = ["Media Library","About","Share","Donate","Settings","Sign Out"]
    private let sectionItemImg = [#imageLiteral(resourceName: "s_lecturelist"),#imageLiteral(resourceName: "s_info"),#imageLiteral(resourceName: "S_share"),#imageLiteral(resourceName: "s_redeem"),#imageLiteral(resourceName: "settings"),#imageLiteral(resourceName: "s_signout")]
    private let rowItems = ["History","Stats","Popular Lectures"]
    private let rowItemImg = [#imageLiteral(resourceName: "s_history"),#imageLiteral(resourceName: "statistics"),#imageLiteral(resourceName: "heart")]
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()
        // Do any additional setup after loading the view.
    }
    func setGradientBackground() {
        let colorTop =  UIColor(red: 16.0/255.0, green: 16.0/255.0, blue: 17.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 34.0/255.0, green: 65.0/255.0, blue: 83.0/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.1]
        gradientLayer.frame = view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
}
extension SideMenuVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionItems.count+2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return 3
            
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuHeaderCell")as! SideMenuHeaderCell
            return cell
        }else if section == sectionItems.count+1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuRatingCell")as! SideMenuRatingCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell")as! SideMenuCell
            cell.lblItem.text = sectionItems[section-1]
            cell.imgItem?.image = sectionItemImg[section-1]
            let btnframe = CGRect(x: 0, y: 0, width: 300, height: 40)
            let tuchBtn = UIButton(frame: btnframe)
            tuchBtn.tag = section
            tuchBtn.addTarget(self, action: #selector(sectionTap(_:)), for: .touchUpInside)
            cell.addSubview(tuchBtn)
            cell.bringSubviewToFront(tuchBtn)
            return cell
            
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuHeaderCell")as! SideMenuHeaderCell
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell")as! SideMenuCell
            print("dequeueReusableCell",rowItems[indexPath.row])
            cell.lblItem.text = rowItems[indexPath.row]
            cell.imgItem?.image = rowItemImg[indexPath.row]
            cell.ledingConst.constant = 50.0
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            //HISTORT
            
            let vc = AppStorybords.home.instantiateViewController(withIdentifier: "SelectedPlaylistVC")as! SelectedPlaylistVC
            vc.vType = .history
            vc.isBackViewActive = true
            self.navigationController?.pushViewController(vc, animated: true)
            revealViewController()?.revealToggle(animated: true)
            
            
        case 1:
            let vc = AppStorybords.home.instantiateViewController(withIdentifier: "StatsVC")as! StatsVC
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            //            MainTabVC.tabBarController?(2)
            //            revealViewController()?.revealToggle(animated: true)
            let vc = AppStorybords.home.instantiateViewController(withIdentifier: "SelectedPlaylistVC")as! SelectedPlaylistVC
            vc.vType = .popular
            vc.isBackViewActive = true
            self.navigationController?.pushViewController(vc, animated: true)
            revealViewController()?.revealToggle(animated: true)
            
        default:
            break
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 120
        case sectionItems.count+1:
            return 300
        default:
            return 40
        }
    }
    @objc func sectionTap(_ sender: UIButton){
        didselect(section: sender.tag)
    }
    func didselect(section Index:Int){
        if Index == 0{
            
        }else if Index == 1{
            revealViewController()?.revealToggle(animated: true)
        }else if Index == 2{
            let vc = AppStorybords.home.instantiateViewController(withIdentifier: "AboutVC")as! AboutVC
            
            self.revealViewController()?.navigationController?.pushViewController(vc, animated: true)
            self.revealViewController()?.revealToggle(animated: true)
            
        }else if Index == 3{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                // Setting description
                let firstActivityItem = "Bhakti Vikasa Swami"
                // Setting url
                let secondActivityItem : NSURL = NSURL(string: "https://apps.apple.com/us/app/bhakti-vikasa-swami/id1536451261")!
                let textToShare = [secondActivityItem,firstActivityItem] as [Any]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ,
                                                                 UIActivity.ActivityType.mail ]
                self.present(activityViewController, animated: true, completion: nil)
            }
        }else if Index == 4{
            Toast(text: "Temporarily disabled due to recent RBI mandate.", delay: 0.0, duration: 5.0).show()
            revealViewController()?.revealToggle(animated: true)
            //            revealViewController()?.revealToggle(animated: true)
            //            let vc = AppStorybords.home.instantiateViewController(withIdentifier: "PaymentVC")as! DonationVC
            //            UIApplication.getTopViewController()?.show(vc, sender: nil)
        }else if Index == 5{
            revealViewController()?.revealToggle(animated: true)
            let vc = AppStorybords.home.instantiateViewController(withIdentifier: "SettingVC")as! SettingVC
            UIApplication.getTopViewController()?.show(vc, sender: nil)
        }else{
            revealViewController()?.revealToggle(animated: true)
            CommonPlayerFunc.shared.pause()
            FRManager.shared.firebaseUserSignOut()
            GlobleVAR.resetAllPreSets()
            FRManager.shared.subscribeAll(isSubscribe: false)
            FRManager.shared.setInitalView()
        }
    }
}
