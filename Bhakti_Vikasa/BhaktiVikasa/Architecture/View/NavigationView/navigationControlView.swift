//
//  navigationControlView.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 23/11/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
import Foundation
import SWRevealViewController
import DropDown
class navigationControlView: UIView {
    @IBOutlet weak var btnSideMenu:UIButton!
    @IBOutlet weak var btnSortBy:UIButton!
    @IBOutlet weak var btnSearch:UIButton!
    @IBOutlet weak var btnFilter:UIButton!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblLecturType:UILabel!
    @IBOutlet weak var switchVideo:UISwitch!
    @IBOutlet weak var txtSearch:UITextField!
    
    
    var searcTime : Timer? = nil{
        willSet{
            guard searcTime != nil else { return }
            searcTime?.invalidate()
        }
    }
    var search:String=""
    var topVC : UIViewController?{
        didSet{
            addSWrevealViewController()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //custom logic goes here
        initViewSetUp()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initViewSetUp(){
        self.lblLecturType.text = "Audio"
        txtSearch.delegate = self
    }
    
    
    
    func addSWrevealViewController(){
        if topVC?.revealViewController() != nil {
            self.backgroundColor = AppColors.primaryOring
            topVC?.view.backgroundColor =  AppColors.primaryOring
            topVC?.revealViewController()?.rearViewRevealWidth = topVC!.view.frame.width/1.5
            btnSideMenu.addTarget(topVC?.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
            topVC!.view.addGestureRecognizer(topVC!.revealViewController().panGestureRecognizer())
            topVC?.revealViewController().rearViewRevealWidth = 255.0
        }
    }
    
    
}

//MARK:- Protocoals
extension navigationControlView:FilterApplyProtocoal{
    func lectureList(sortBy: Sortkind) {
        print("not reqierd")
    }
    
    func videoFileter(with status: Bool) {
        print("not reqierd")

    }
 
    func filterApply(with selecter: Int, filters: [Filter]) {
        if selecter == 0{
            print("No filter Apply")
            self.btnFilter.setImage(#imageLiteral(resourceName: "filter_list-24px"), for: .normal)
            self.btnFilter.setTitle("", for: .normal)
        }else{
            print(" filter Apply -> \(selecter)")
            self.btnFilter.setImage(nil, for: .normal)
            self.btnFilter.setTitle("\(selecter)", for: .normal)
        }
    }
    
}
//MARK:- Buttion Action
extension navigationControlView{
    @IBAction private func sortbyAction(_ sender: UIButton){
        
        var sortOptions:[Sortkind] = []
        if GlobleVAR.selectedTab == .playList{
            sortOptions = [.none,
                          .alphabeticallyAscending,
                          .alphabeticallyDescending,
            ]
        }else{
            
            sortOptions = [.none,
                           .durationAscending,
                           .durationDescending,
                           .recordingDateAscending,
                           .recordingDateDescending,
                           .alphabeticallyAscending,
                           .alphabeticallyDescending,
                           .popularuty,
                           .verseNumber]
        }
        
        let dropDown = DropDown()
        dropDown.anchorView = sender
        dropDown.dataSource = sortOptions.compactMap({$0.rawValue})
        dropDown.selectRow(sender.tag)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            sender.tag = index
            guard let sortAction = Sortkind(rawValue:item) else{return}
            GlobleVAR.filterDeligate?.lectureList(sortBy: sortAction)
        }
        dropDown.show()
        
    }
    
   @IBAction func activeVideoOnly(_ sender: UISwitch) {
    GlobleVAR.isVideoMode.toggle()
       if sender.isOn{
           self.lblLecturType.text = "Video"
       }else{
           self.lblLecturType.text = "Audio"
       }
        GlobleVAR.filterDeligate?.videoFileter(with:sender.isOn)
    }
    @IBAction func filterAction(_ sender: UIButton)-> Void{
         if GlobleVAR.filterModel.count <= 0  {
                GlobleVAR.filterModel = Filter.createFilterObject()
            }
        guard GlobleVAR.filterModel.count > 0 else{ return}
         let vc = AppStorybords.home.instantiateViewController(withIdentifier: "FilterVC")as! FilterVC
         vc.homeDeligate = self
            topVC?.present(vc, animated: true, completion: nil)
     }
    @IBAction func searchAction(_ sender: UIButton)-> Void{
        if sender.tag == 0 {
            sender.setImage(#imageLiteral(resourceName: "Cross"), for: .normal)
            sender.tag = 1
            txtSearch.isHidden = false
            lblTitle.isHidden = true
            txtSearch.text = ""
            txtSearch.becomeFirstResponder()
        }else{
            sender.setImage(#imageLiteral(resourceName: "search-24px"), for: .normal)
            sender.tag = 0
            txtSearch.isHidden = true
            lblTitle.isHidden = false
            txtSearch.text = ""
            txtSearch.resignFirstResponder()
            GlobleVAR.searchfilterDeligate?.filterWithString(search: search, isActiveString: false)
        }
    }
}
extension navigationControlView:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.searcTime = nil
        if string == "\n"{
            textField.resignFirstResponder()
            return false
            
        }
        else if string.isEmpty
        {
            search = String(search.dropLast())
        }
        else
        {
            search=textField.text!+string
        }
        self.searcTime = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (t) in
            t.invalidate()
            print("real------>\(self.search)")

            if self.search == ""{
                
                GlobleVAR.searchfilterDeligate?.filterWithString(search: self.search, isActiveString: false)

                
            }else{
                GlobleVAR.searchfilterDeligate?.filterWithString(search: self.search, isActiveString: true)

            }
        })
        return true
    }
}
