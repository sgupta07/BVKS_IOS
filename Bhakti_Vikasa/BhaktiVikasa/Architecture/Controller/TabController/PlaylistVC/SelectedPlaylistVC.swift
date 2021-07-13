//
//  SelectedPlaylistVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 14/12/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit

class SelectedPlaylistVC: UIViewController {
    
    @IBOutlet weak var navView:navigationControlView!
    @IBOutlet weak var playerSpace: NSLayoutConstraint!
    @IBOutlet weak var tblPlaylist: UITableView!
    
    var playlist : PlayList? = nil
    var vType : PlayList.listType? = .popular
    var isBackViewActive:Bool = false
    private var lastTabselection:LType = GlobleVAR.selectedTab
    private var dbLecture: lectures? = nil{
        didSet{
            GlobleDB.rawPalyable = dbLecture ?? []
            tblPlaylist.reloadData()
        }
    }
    private var selectedSortType:Sortkind = .none
    private var selectedFilters : [Filter] = []
    private var mainDBRawLectures: lectures?
    private var isScrolling = false
    override func viewDidLoad() {
        super.viewDidLoad()
        GlobleVAR.selectedTab = .selectedList
        GlobleVAR.filterModel = self.selectedFilters

        FilterHandler.shared.setPlayerSpace(spaceObj: self.playerSpace)
        navView.topVC = self
        configureTableView()
        initSetupView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navView.switchVideo.setOn(GlobleVAR.isVideoMode, animated: false)
        navView.lblLecturType.text = GlobleVAR.isVideoMode ? "Video" : "Audio"
        navView.btnSideMenu.removeTarget(nil, action: nil, for: .allEvents)
        navView.btnSideMenu.addTarget(self, action: #selector(backToplayList), for: .touchUpInside)
        GlobleVAR.searchfilterDeligate = self
        GlobleVAR.filterDeligate = self
    }
    override func viewWillDisappear(_ animated: Bool) {
        selectedPlayListListener?.remove()

    }
    private func initSetupView(){
        switch vType {
        case .history:
            navView.lblTitle.text = "History"
        case .popular:
             navView.lblTitle.text = "Popular"
        case .privateList,.publicList:
            navView.lblTitle.text = playlist?.title ?? ""
        case .none:
            navView.lblTitle.text = "Lecture library"
        }
        
        
        self.dbLecture = []
        self.lastTabselection = GlobleVAR.selectedTab
        GlobleVAR.selectedTab = .selectedList
        switch self.vType {
        case .publicList,.privateList:
//            guard let lIds = playlist?.lectureIds else {return}
//            let lectures = GlobleDB.rawGloble.filter({lIds.contains($0.id!)})
//            self.mainDBRawLectures = lectures
//            self.dbLecture = lectures
            print(playlist)
            guard let docPath = playlist?.docPath else{return}
            print(playlist)
            PlayList.getPlaylist(with: docPath) { (playlist) in
                
                guard let lIds = playlist?.lectureIds else {return}
                 self.mainDBRawLectures = GlobleDB.rawGloble.filter({lIds.contains($0.id!)})
                self.applyWithAllFilterCheckes()
            }
            
        case .history:
            playerSpace.constant = 0
            var lectures:lectures = []
            for item in GlobleVAR.appUser.playHistoryIds{
                if let lect = GlobleDB.rawGloble.first(where: {$0.id == item}){
                    lectures.append(lect)
                }
            }
            self.mainDBRawLectures = lectures
            self.dbLecture = lectures
        case .popular:
             playerSpace.constant = 0
            self.getTopLecture()
        case .none:
            break
        }
    }
    func configureTableView(){
        tblPlaylist.delegate = self
        tblPlaylist.dataSource = self
        tblPlaylist.register(UINib(nibName: "V2lectureCell", bundle: nil), forCellReuseIdentifier: "V2lectureCell")
    }
    @objc func backToplayList(){
        GlobleVAR.selectedTab = self.lastTabselection
        self.navigationController?.popViewController(animated: true)
    }
    
    
}


//MARK:- UITableViewDelegate
extension SelectedPlaylistVC: UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dbLecture?.count == 0 {
            tableView.setEmptyMessage("Empty")
        } else {
            tableView.restore()
        }
        return dbLecture?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblPlaylist.dequeueReusableCell(withIdentifier: "V2lectureCell", for: indexPath) as! V2lectureCell
        cell.tag = indexPath.row
        switch self.vType {
        case .history:
            cell.section = .history
        case .popular:
            cell.section = .topLacture
        default:
            cell.section = .selectedList
        }
     
        
        cell.lecture = dbLecture?[indexPath.row]
        cell.playList = self.playlist
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lect = dbLecture![indexPath.row]
        NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerModel), object: ["playerModel":lect])
        guard isBackViewActive  else { return }
        self.navigationController?.popViewController(animated: true)
        
        
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




extension SelectedPlaylistVC:FilterApplyProtocoal,lectureSearchProtocol{
    
    func filterWithString(search :String,isActiveString:Bool){
        guard GlobleVAR.selectedTab == .selectedList else {return}
        print("Home lecture Search ------->\(search)")
        //  oprationalDB = Lecture.getLecture(with: search, rawLecture: self.oprationalDB ?? [])
        applyWithAllFilterCheckes()
    }
    
    func lectureList(sortBy: Sortkind) {
        guard GlobleVAR.selectedTab == .selectedList else {return}
        self.selectedSortType = sortBy
        //self.oprationalDB = Lecture.getLectures(sortBy: sortBy, rawLecture: self.oprationalDB ?? [])
        applyWithAllFilterCheckes()
    }
    
    func filterApply(with selecter: Int, filters: [Filter]) {
        guard GlobleVAR.selectedTab == .selectedList else {return}
        self.selectedFilters = GlobleVAR.filterModel
        // oprationalDB = Lecture.getLecturs(with: filters, rawlectures: self.oprationalDB ?? [])
        applyWithAllFilterCheckes()
    }
    func videoFileter(with status: Bool) {
        guard GlobleVAR.selectedTab == .selectedList else {return}
        // oprationalDB = Lecture.getLecture(withVideo: status, rawLectures: self.oprationalDB ?? [])
        applyWithAllFilterCheckes()
    }
    
    func applyWithAllFilterCheckes(){
        let searchstr = navView.txtSearch.text
        let isVideo =  navView.switchVideo.isOn
        guard let lecture = self.mainDBRawLectures else {
            
            return
        }
        self.dbLecture = Lecture.getProccessedLecters(with:lecture , searchStr: searchstr, isVideos: isVideo, sortBy: self.selectedSortType, filterPoints: self.selectedFilters)
    }
    
    
}
//MARK:- TOP LECTURELIST ACTIONS
import Firebase
extension SelectedPlaylistVC{

    func getTopLecture(retriveBy: RetriveBy = .week){
        TopLecture.getTopLectur(by: retriveBy) { (topPlayed) in
            if let topObj = topPlayed, topObj.count > 0{
                let playedList  = topObj.flatMap({ $0.playedIds })
                
                let sortDetails =  playedList.frequency
                
                var toplecture:lectures = []
                for (key, value) in sortDetails {
                    if  let first = GlobleDB.rawGloble.first(where: {$0.id == key}){
                        var raw = first
                        raw.globlePlayCount = value
                        toplecture.append(raw)
                    }
                }
                
                let lectur = toplecture.sorted(by: { $0.globlePlayCount ?? 0 > $1.globlePlayCount ?? 0 })
                
                self.mainDBRawLectures = lectur
                self.dbLecture = self.mainDBRawLectures
            }
        }
    }
}
