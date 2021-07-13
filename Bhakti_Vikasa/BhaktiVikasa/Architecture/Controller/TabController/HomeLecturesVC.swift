//
//  LecturesVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 09/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import Toaster
import CodableFirebase
import FirebaseFirestore


class HomeLecturesVC: UIViewController {
    /// If user enter in app by taping on UnivarsalLink than this callBack is perform
    static var univarsalLinkRecived:((_ linkID:Int)->Void)?
    @IBOutlet weak var navView:navigationControlView!
    @IBOutlet weak var playerSpace: NSLayoutConstraint!
    @IBOutlet weak var tblPlaylist: UITableView!
    
    private var selectedSortType:Sortkind = .none
    private var selectedFilters : [Filter] = []
    private var oprationalDB: lectures? = nil {
        didSet{
            GlobleDB.rawPalyable = oprationalDB ?? []
            tblPlaylist.reloadData()
        }
    }
    private var isScrolling = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialLoad()
    }
   
  
    override func viewWillAppear(_ animated: Bool) {
        navView.switchVideo.setOn(GlobleVAR.isVideoMode, animated: false)
        navView.lblLecturType.text = GlobleVAR.isVideoMode ? "Video" : "Audio"
              
        GlobleVAR.selectedTab  = .home
        GlobleVAR.filterModel = self.selectedFilters
        GlobleVAR.searchfilterDeligate = self
        GlobleVAR.filterDeligate = self
        applyWithAllFilterCheckes()
    }
  
    func initialLoad(){
        

        FilterHandler.shared.setPlayerSpace(spaceObj: self.playerSpace)
        navView.topVC = self
        oprationalDB = GlobleDB.rawGloble
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedSetPlayerModel(notification:)), name: Notification.Name(AppNotification.setPlayerModel), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.dbDidChange(notification:)), name: Notification.Name(AppNotification.lectureDidChange), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPlayerState(notification:)), name: Notification.Name(AppNotification.setPlayerState), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationLectureInfoUpdate(notification:)), name: Notification.Name(AppNotification.lectureInfoUpadte), object: nil)
        self.configureTableView()
      //  self.addUnivarsalLinkHandler()
        initPlay()
    }
    private func addUnivarsalLinkHandler(){
        MainTabVC.tabBarControllerOnUnivarsalLink = { (id) -> Void in
            self.moveToLacter(with: id)
        }
    }

    private func initPlay(){
        if self.oprationalDB?.count ?? 0 > 0{
            if GlobleVAR.currentPlay?.id == nil{
                let playedLecture = self.oprationalDB![0]
                GlobleVAR.selectedTab = .home
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerModel), object: ["playerModel":playedLecture])
                }
            }else{
                if let index = self.oprationalDB?.firstIndex(where: {$0.id == GlobleVAR.currentPlay?.id}){
                    let playedLecture = self.oprationalDB![index]
                    GlobleVAR.selectedTab = .home
                    self.tblPlaylist.scrollToRow(at: IndexPath(item: index, section: 0), at: .middle, animated: true)
                }
            }
            GlobleDB.rawPalyable = self.oprationalDB ?? []
        }else{
            return
        }
    }
    @objc func notificationLectureInfoUpdate(notification: Notification) {
        if GlobleVAR.selectedTab == .home{
            print("HOME OVSERVER CALL +++++++")
            self.applyWithAllFilterCheckes()
        }
       }

  

    @objc func notificationPlayerState(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            if GlobleVAR.selectedTab == .home{
                let currentIndex = IndexPath(row: GlobleVAR.currentIndex, section: 0)
                self.tblPlaylist.reloadRows(at: [currentIndex], with: .none)
            }
        }
    }

    
  @objc func receivedSetPlayerModel(notification: Notification) {
       DispatchQueue.main.async {
           self.tblPlaylist.reloadData()
       }
    }
    /// get called while chnage is made on FIRE DB
    /// - Parameter notification: contain modifyed LectureModel and ModificationType
    @objc func dbDidChange(notification: Notification) {
        DispatchQueue.main.async {
            if let object = notification.object as? NSDictionary{
                let model = object.value(forKey: "lecture") as! Lecture
                let event = object.value(forKey: "event") as! DocumentChangeType
                    self.applyWithAllFilterCheckes()
//                switch event {
//                case .added:
//                    GlobleDB.rawGloble.append(model)
//                case .modified:
//                    if let index = GlobleDB.rawGloble.firstIndex(where: {$0.id == model.id}){
//                        GlobleDB.rawGloble.remove(at: index)
//                        GlobleDB.rawGloble.insert(model, at: index)
//                    }
//                    if let index = self.oprationalDB?.firstIndex(where: {$0.id == model.id}){
//                        self.oprationalDB?.remove(at: index)
//                        self.oprationalDB?.insert(model, at: index)
//                    }
//                    guard !self.isScrolling else {return}
//                    guard let visibleRows = self.tblPlaylist.indexPathsForVisibleRows else { return }
//                    self.tblPlaylist.beginUpdates()
//                    self.tblPlaylist.reloadRows(at: visibleRows, with: .none)
//                    self.tblPlaylist.endUpdates()
//                case .removed:
//                    if let index = self.oprationalDB?.firstIndex(where: {$0.id == model.id}){
//                        self.oprationalDB?.removeAll(where: {$0.id == model.id})
//                        GlobleDB.rawGloble.removeAll(where: {$0.id == model.id})
//                        let indexPath = IndexPath(row: index, section: 0)
//                        self.tblPlaylist.deleteRows(at: [indexPath], with: .none)
//                        return
//                    }
//                    self.oprationalDB?.removeAll(where: {$0.id == model.id})
//                    GlobleDB.rawGloble.removeAll(where: {$0.id == model.id})
//                    return
//                }
            }
        }
    }
    
 
   
   private func configureTableView(){
       tblPlaylist.delegate = self
       tblPlaylist.dataSource = self
        tblPlaylist.register(UINib(nibName: "V2lectureCell", bundle: nil), forCellReuseIdentifier: "V2lectureCell")
   }
    func moveToLacter(with lectureId:Int){
        if let lectureIndex = self.oprationalDB?.firstIndex(where: {$0.id == lectureId}){
            self.tblPlaylist.scrollToRow(at: IndexPath(row: lectureIndex, section: 0), at: .top, animated: true)
        }else{
            if let lecture = GlobleDB.rawGloble.first(where: {$0.id == lectureId}){
                self.oprationalDB?.append(lecture)
                DispatchQueue.main.asyncAfter(wallDeadline: .now()+1) {
                     self.moveToLacter(with: lectureId)
                }
            }else{
                print("LECTURE IS NOT IN DB")
            }
        }
    }

   
}
//MARK:- UITableViewDelegate
extension HomeLecturesVC: UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if oprationalDB?.count == 0 {
            if navView.txtSearch.isHidden{
                tableView.setEmptyMessage("Loading...")
            }else{
                tableView.setEmptyMessage("No result")
            }
        } else {
            tableView.restore()
        }
        return oprationalDB?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblPlaylist.dequeueReusableCell(withIdentifier: "V2lectureCell", for: indexPath) as! V2lectureCell
        cell.tag = indexPath.row
        cell.section = .home
        cell.lecture = oprationalDB?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lect = oprationalDB![indexPath.row]
        GlobleVAR.selectedTab = .home
        NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerModel), object: ["playerModel":lect])
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isScrolling = true

    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isScrolling = false

    }
    
}

extension HomeLecturesVC:FilterApplyProtocoal,lectureSearchProtocol{
   
    func filterWithString(search :String,isActiveString:Bool){
         guard GlobleVAR.selectedTab == .home else {return}
         print("Home lecture Search ------->\(search)")
      //  oprationalDB = Lecture.getLecture(with: search, rawLecture: self.oprationalDB ?? [])
        applyWithAllFilterCheckes()
     }
    
    func lectureList(sortBy: Sortkind) {
      guard GlobleVAR.selectedTab == .home else {return}
        self.selectedSortType = sortBy
        //self.oprationalDB = Lecture.getLectures(sortBy: sortBy, rawLecture: self.oprationalDB ?? [])
        applyWithAllFilterCheckes()
    }
    
    func filterApply(with selecter: Int, filters: [Filter]) {
        guard GlobleVAR.selectedTab == .home else {return}
        self.selectedFilters = GlobleVAR.filterModel
       // oprationalDB = Lecture.getLecturs(with: filters, rawlectures: self.oprationalDB ?? [])
        applyWithAllFilterCheckes()
    }
    func videoFileter(with status: Bool) {
        guard GlobleVAR.selectedTab == .home else {return}
       // oprationalDB = Lecture.getLecture(withVideo: status, rawLectures: self.oprationalDB ?? [])
        applyWithAllFilterCheckes()
    }
    
    func applyWithAllFilterCheckes(){
        let searchstr = navView.txtSearch.text
        let isVideo =  navView.switchVideo.isOn
        oprationalDB = Lecture.getProccessedLecters(with: GlobleDB.rawGloble, searchStr: searchstr, isVideos: isVideo, sortBy: self.selectedSortType, filterPoints: self.selectedFilters)
    }
    
   
}


