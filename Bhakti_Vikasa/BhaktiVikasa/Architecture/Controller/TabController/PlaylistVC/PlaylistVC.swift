//
//  PlaylistVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 23/11/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit

class PlaylistVC: UIViewController {
    @IBOutlet weak var navView:navigationControlView!
    @IBOutlet weak var playerSpace: NSLayoutConstraint!
    @IBOutlet weak var listSegment:UISegmentedControl!
    @IBOutlet weak var tblPlaylist:UITableView!

    
//    var dbLecture: lectures?
//    var mainDBRawLectures: lectures?
    private var selectedSortType:Sortkind = .none

    private var isScrolling = false
    private var mainPlaylist: [PlayList] = []
    private var oprationalPlaylist: [PlayList] = []{
        didSet{
            self.tblPlaylist.reloadData()
        }
    }



    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FilterHandler.shared.setPlayerSpace(spaceObj: self.playerSpace)

        navView.topVC = self

        // Do any additional setup after loading the view.
        configureTableView()
        initSetupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        GlobleVAR.selectedTab  = .playList
        GlobleVAR.searchfilterDeligate = self
        GlobleVAR.filterDeligate = self
    }
    
    @IBAction func selectionOflistType(_ sender: UISegmentedControl) {
        initSetupView(selectedIndex: sender.selectedSegmentIndex)
    }
    
   
    func configureTableView(){
        tblPlaylist.delegate = self
        tblPlaylist.dataSource = self
        tblPlaylist.register(UINib(nibName: "V2lectureCell", bundle: nil), forCellReuseIdentifier: "V2lectureCell")
    }
    func initSetupView(selectedIndex : Int = 0){
        if selectedIndex == 0{
            //Private
            if GlobleDB.rawPrivateList.count == 0{
                PlayList.getPrivatePlayList(completion:{ (UpdatedPlaylist) in
                    GlobleDB.rawPrivateList = UpdatedPlaylist ?? []
                    self.oprationalPlaylist = UpdatedPlaylist ?? []
                    self.mainPlaylist = UpdatedPlaylist ?? []
                })
            }else{
                self.mainPlaylist = GlobleDB.rawPrivateList
                self.oprationalPlaylist = GlobleDB.rawPrivateList
            }
        }else{
            //Public
            if GlobleDB.rawPubliclist.count == 0{
                PlayList.getPublicPlayList(completion:{ (UpdatedPlaylist) in
                    GlobleDB.rawPubliclist = UpdatedPlaylist ?? []
                    self.oprationalPlaylist = UpdatedPlaylist ?? []
                    self.mainPlaylist = UpdatedPlaylist ?? []
                })
            }else{
                self.mainPlaylist = GlobleDB.rawPubliclist
                self.oprationalPlaylist = GlobleDB.rawPubliclist
            }
        }
    }

}
//MARK:- UITableViewDelegate
extension PlaylistVC: UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate{
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
        let vc = AppStorybords.home.instantiateViewController(withIdentifier: "SelectedPlaylistVC")as! SelectedPlaylistVC
        if self.listSegment.selectedSegmentIndex == 0{
            vc.vType = .privateList
            
        }else{
            vc.vType = .publicList
        }
        vc.playlist = self.oprationalPlaylist[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isScrolling = true
        print("true")

    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isScrolling = false
        print("FALIS")

    }
    
}


extension PlaylistVC:FilterApplyProtocoal,lectureSearchProtocol{
    func filterWithString(search :String,isActiveString:Bool){
          guard GlobleVAR.selectedTab == .playList else {return}
          print("Home lecture Search ------->\(search)")
        getPlaylistWithCombineOprations()
      }
    
    func lectureList(sortBy: Sortkind) {
        guard GlobleVAR.selectedTab == .playList else {return}
        self.selectedSortType = sortBy
        getPlaylistWithCombineOprations()
    }

    func filterApply(with selecter: Int, filters: [Filter]) {
        print("no funtionality apply")
        }
    func videoFileter(with status: Bool) {
        print("no funtionality apply")
    }
    func getPlaylistWithCombineOprations(){
        self.oprationalPlaylist = PlayList.getPlaylist(with: self.navView.txtSearch.text, sortBy: self.selectedSortType, rawPlaylist: self.mainPlaylist)
    }
}
