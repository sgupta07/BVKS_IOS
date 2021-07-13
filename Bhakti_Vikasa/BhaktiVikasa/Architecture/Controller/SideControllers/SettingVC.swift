//
//  SettingVC.swift
//  Bhakti_Vikasa
//
//  Created by gagandeepmishra on 12/01/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import UIKit
class NottificationSettingCell:UITableViewCell{
    @IBOutlet weak var titlelbl:UILabel!
    @IBOutlet weak var setingState:UISwitch!
    
    
}


class SettingVC: UIViewController {
    @IBOutlet weak var tblSettinges:UITableView!
    var userSettinges :Settinges? = nil
    
    let sectionItems = ["Choose the language(s) you wish to get notifications for:"]
    let notificationSetting = ["English","Hindi","Bengali"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewWithDataModel()
        // Do any additional setup after loading the view.
    }
    
    func setViewWithDataModel(){
        Settinges.getUserSettings { (setting) in
            if let s = setting{
                print(s)
                self.userSettinges = s
                self.tblSettinges.reloadData()
            }else{
                DispatchQueue.main.async {
                    let set =  Settinges.setTodefaultSetting()
                    self.userSettinges = set
                    self.tblSettinges.reloadData()
                }
                
            }
            CommonFunc.shared.switchAppLoader(value: false)
        }
    }
    @IBAction func setDefultNotificationSettinges(_ sender:UIButton){
        // CommonFunc.shared.switchAppLoader(value: true)
        var settinges = Settinges()
        var ntfSet = Settinges.notificationSettings()
        settinges.lastModificationTime = c_Time
        ntfSet.hindi = true
        ntfSet.english = true
        ntfSet.bengali = true
        settinges.notification = ntfSet
        Settinges.updateUserSettings(setting: settinges)
       // FRManager.shared.subscribeAll(isSubscribe: true)
        self.userSettinges = settinges
        self.tblSettinges.reloadData()
        //CommonFunc.shared.switchAppLoader(value: true)
        
        
    }
    @IBAction func updateSettinges(_ sender: UISwitch) {
        DispatchQueue.main.async {
            
            
            self.userSettinges?.lastModificationTime = c_Time
            var noti = Settinges.notificationSettings()
            noti = self.userSettinges?.notification ?? Settinges.notificationSettings()
            switch sender.tag {
            case 0:
                noti.english = sender.isOn
               // self.userSettinges?.notification?.english = sender.isOn
            case 1:
                noti.hindi = sender.isOn
               // self.userSettinges?.notification?.hindi = sender.isOn
            case 2:
                noti.bengali = sender.isOn
               // self.userSettinges?.notification?.bengali = sender.isOn
            default:
                return
            }
            self.userSettinges?.notification = noti
            print("------->",self.userSettinges?.lastModificationTime)
            print("USER SETTINGES ARE CHANGE BY USER",sender.isOn)
            guard let setting = self.userSettinges else {return}
            Settinges.updateUserSettings(setting: setting)
        }
    }
    
    @IBAction func backToHome(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension SettingVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionItems.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return notificationSetting.count
            
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionItems[section]
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = (view as? UITableViewHeaderFooterView)?.textLabel?.text
        (view as? UITableViewHeaderFooterView)?.textLabel?.text = title?.capitalized
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NottificationSettingCell")as! NottificationSettingCell
            let name = notificationSetting[indexPath.row]
            cell.setingState.tag = indexPath.row
            cell.titlelbl.text = name
            var value : Bool = false
            switch name {
            case "Hindi":
                value = userSettinges?.notification?.hindi ?? false
            case "English":
                value = userSettinges?.notification?.english ?? false
            case "Bengali":
                value = userSettinges?.notification?.bengali ?? false
            default:
                value = false
            }
            cell.setingState.setOn(value, animated: true)
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell")as! SideMenuCell
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
        
    }
    @objc func sectionTap(_ sender: UIButton){
        didselect(section: sender.tag)
    }
    func didselect(section Index:Int){
        
    }
}
