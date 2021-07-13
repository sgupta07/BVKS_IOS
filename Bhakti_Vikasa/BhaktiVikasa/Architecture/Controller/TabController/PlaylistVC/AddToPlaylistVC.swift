//
//  AddToPlaylistVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 05/12/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
import DropDown
class AddToPlaylistVC: UIViewController {
    @IBOutlet weak var tblPlaylist:UITableView!

    @IBOutlet weak var btnDismis:UIButton!
    @IBOutlet weak var btnSortBy:UIButton!
    @IBOutlet weak var btnSearch:UIButton!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblListType:UILabel!
    @IBOutlet weak var txtSearch:UITextField!
    private var selectedSortType:Sortkind = .none
    var listType: PlayList.listType = .privateList
    var searcTime : Timer? = nil
    var search:String=""
    var opratedlecture: Lecture? = nil
   private var mainPlaylist: [PlayList] = []
   private var oprationalPlaylist: [PlayList] = []{
           didSet{
               self.tblPlaylist.reloadData()
           }
       }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtSearch.delegate = self
        initSetupView()
        configureTableView()
    }
  
    func configureTableView(){
        tblPlaylist.delegate = self
        tblPlaylist.dataSource = self
        tblPlaylist.register(UINib(nibName: "V2lectureCell", bundle: nil), forCellReuseIdentifier: "V2lectureCell")
    }
    func initSetupView(){
        self.lblListType.text = listType.str
        if self.listType == .privateList{
            
            if GlobleDB.rawPrivateList.count == 0{
                PlayList.getPrivatePlayList(completion:{ (UpdatedPlaylist) in
                    GlobleDB.rawPrivateList = UpdatedPlaylist ?? []
                    self.mainPlaylist = UpdatedPlaylist ?? []
                    self.oprationalPlaylist = UpdatedPlaylist ?? []
                })
            }else{
                self.oprationalPlaylist = GlobleDB.rawPrivateList
            }
        }else{
            if GlobleDB.rawPubliclist.count == 0{
                PlayList.getPublicPlayList(completion:{ (UpdatedPlaylist) in
                    GlobleDB.rawPubliclist = UpdatedPlaylist ?? []
                    self.mainPlaylist = UpdatedPlaylist ?? []
                    self.oprationalPlaylist = UpdatedPlaylist ?? []                })
            }else{
                self.oprationalPlaylist = GlobleDB.rawPubliclist
            }
        }
    }


}
//MARK:-NAVIGATION ITEM ACTION
extension AddToPlaylistVC{
    @IBAction func dismisVC(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
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

           }
           
       }
    @IBAction func sortbyAction(_ sender: UIButton){
        let sortOptions:[Sortkind] = [.none,
                                      .alphabeticallyAscending,
                                      .alphabeticallyDescending,
                                     ]
        let dropDown = DropDown()
        dropDown.anchorView = sender
        dropDown.dataSource = sortOptions.compactMap({$0.rawValue})
        dropDown.selectRow(sender.tag)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            sender.tag = index
            guard let sortAction = Sortkind(rawValue: item) else {return}
            self.selectedSortType = sortAction
            self.oprationalPlaylist = PlayList.getPlaylist(with: self.search, sortBy:self.selectedSortType ,rawPlaylist: self.mainPlaylist)

        }
        dropDown.show()
    }
}
extension AddToPlaylistVC:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.searcTime?.invalidate()
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
            self.oprationalPlaylist = PlayList.getPlaylist(with: self.search, sortBy:self.selectedSortType ,rawPlaylist: self.mainPlaylist)
//            if self.search == ""{
//                self.oprationalPlaylist = self.mainPlaylist
//
//            }else{
//                self.oprationalPlaylist = []
//                func removeDuplicateElements(playList: [PlayList]) -> [PlayList] {
//                    var uniquePosts : [PlayList] = []
//                    for item in playList {
//                        if !uniquePosts.contains(where: {$0.listID == item.listID })  {
//                            uniquePosts.append(item)
//                        }
//                    }
//                    return uniquePosts
//                }
//                let filter1 = self.mainPlaylist.filter({ (item) -> Bool in
//                    return item.title?.range(of: self.search.replacingOccurrences(of: " ", with: ""), options: .caseInsensitive) != nil
//                })
//                let filter2 = self.mainPlaylist.filter({ (item) -> Bool in
//                    return item.lecturesCategory?.range(of: self.search, options: .caseInsensitive) != nil
//                })
//                let filter3 = self.mainPlaylist.filter({ (item) -> Bool in
//                    return item.discription?.range(of: self.search, options: .caseInsensitive) != nil
//                })
//                var tempList : [PlayList] = []
//                tempList.append(contentsOf: filter1 )
//                tempList.append(contentsOf: filter2 )
//                tempList.append(contentsOf: filter3 )
//
//                self.oprationalPlaylist = removeDuplicateElements(playList: tempList )
//
//
//            }
        })
        return true
    }
}
//MARK:- UITableViewDelegate, UITableViewDataSource
extension AddToPlaylistVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if oprationalPlaylist.count == 0 {
            tableView.setEmptyMessage("Empty")
        } else {
            tableView.restore()
        }
        return self.oprationalPlaylist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblPlaylist.dequeueReusableCell(withIdentifier: "V2lectureCell", for: indexPath) as! V2lectureCell
        cell.tag = indexPath.row
        cell.section = .playList
       
        cell.playList = self.oprationalPlaylist[indexPath.row]
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            var playList : PlayList? = nil
            if self.listType == .privateList {
                playList = GlobleDB.rawPrivateList[indexPath.row]
            }else{
                playList = GlobleDB.rawPubliclist[indexPath.row]
            }
        playList?.updatePlaylist(with: playList!, lectID: opratedlecture?.id ?? 0, addtolist: true)
        
        self.dismiss(animated: true, completion: nil)
        
    }

    
}



   
