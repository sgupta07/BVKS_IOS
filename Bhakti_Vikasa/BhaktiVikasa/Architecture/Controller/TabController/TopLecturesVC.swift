//
//  HomeTabVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 23/11/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
import SWRevealViewController
import Firebase
class TopLecturesVC: UIViewController {
    
    
    @IBOutlet weak private var navView:navigationControlView!
    @IBOutlet weak private var playerSpace: NSLayoutConstraint!
    @IBOutlet weak private var tblPlaylist: UITableView!
   // private var countsDic : [Int?:Int] = [:]
    
    @IBOutlet weak private var lblWeekBottom: UILabel!
    @IBOutlet weak private var btnWeekList: UIButton!
    @IBOutlet weak private var lblMonthBottom: UILabel!
    @IBOutlet weak  private var btnMonthList: UIButton!
    private var selectedSortType:Sortkind = .none
    private var selectedFilters : [Filter] = []

    private  var listType:RetriveBy? = .week{
        
        didSet{
            switch listType! {
            case .week:
                //DISPLAY TOP 10 WEEKLY LECTURES
                self.btnWeekList.setTitleColor(.white, for: .normal)
                self.btnMonthList.setTitleColor(.lightGray, for: .normal)
                self.lblWeekBottom.isHidden = false
                self.lblMonthBottom.isHidden = true
                getTopLecture(retriveBy: .week)
            case .month:
                //DISPLAY TOP 10 MONTHLY LECTURES
                self.btnWeekList.setTitleColor(.lightGray, for: .normal)
                self.btnMonthList.setTitleColor(.white, for: .normal)
                self.lblWeekBottom.isHidden = true
                self.lblMonthBottom.isHidden = false
                getTopLecture(retriveBy: .month)
            default:
                break
            }
            
        }
    }
    private var oprationalDB: lectures? = nil{
        didSet{
            GlobleDB.rawPalyable = oprationalDB ?? []
            tblPlaylist.reloadData()
        }
    }
    private var mainDBRawLectures: lectures = []
    private var isScrolling = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.initview()
        FilterHandler.shared.setPlayerSpace(spaceObj: self.playerSpace)
        navView.topVC = self
        configureTableView()
        self.changeTopBarTab(self.btnWeekList)
        oprationalDB = []
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navView.switchVideo.setOn(GlobleVAR.isVideoMode, animated: false)
        navView.lblLecturType.text = GlobleVAR.isVideoMode ? "Video" : "Audio"
        GlobleVAR.selectedTab  = .topLacture
        GlobleVAR.searchfilterDeligate = self
        GlobleVAR.filterDeligate = self
        GlobleVAR.filterModel = self.selectedFilters

    }
    func configureTableView(){
        tblPlaylist.delegate = self
        tblPlaylist.dataSource = self
        tblPlaylist.register(UINib(nibName: "V2lectureCell", bundle: nil), forCellReuseIdentifier: "V2lectureCell")
    }
    
    
    func getTopLecture(retriveBy: RetriveBy){
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
               
                let lectur = toplecture.sorted(by: { $0.globlePlayCount ?? 0 < $1.globlePlayCount ?? 0 })

                self.mainDBRawLectures = lectur.reversed().suffix(10)
                self.oprationalDB = self.mainDBRawLectures
            }
        }
    }
    @IBAction func changeTopBarTab(_ sender: UIButton){
        DispatchQueue.main.async {
            if sender.currentTitle == "This week"{
                self.listType = .week
                
            }else{
                self.listType = .month
            }
        }
        
    }
    
}
//MARK:- UITableViewDelegate
extension TopLecturesVC: UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if oprationalDB?.count == 0 {
            tableView.setEmptyMessage("Empty")
        } else {
            tableView.restore()
        }
        return oprationalDB?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblPlaylist.dequeueReusableCell(withIdentifier: "V2lectureCell", for: indexPath) as! V2lectureCell
        cell.tag = indexPath.row
        cell.section = .topLacture
        let cLecture = oprationalDB?[indexPath.row]
        cell.lecture = cLecture
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lect = oprationalDB![indexPath.row]
        NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerModel), object: ["playerModel":lect])
        
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


extension TopLecturesVC:FilterApplyProtocoal,lectureSearchProtocol{
   
    func filterWithString(search :String,isActiveString:Bool){
         guard GlobleVAR.selectedTab == .topLacture else {return}
         print("Home lecture Search ------->\(search)")
      //  oprationalDB = Lecture.getLecture(with: search, rawLecture: self.oprationalDB ?? [])
        applyWithAllFilterCheckes()
     }
    
    func lectureList(sortBy: Sortkind) {
      guard GlobleVAR.selectedTab == .topLacture else {return}
        self.selectedSortType = sortBy
        //self.oprationalDB = Lecture.getLectures(sortBy: sortBy, rawLecture: self.oprationalDB ?? [])
        applyWithAllFilterCheckes()
    }
    
    func filterApply(with selecter: Int, filters: [Filter]) {
        guard GlobleVAR.selectedTab == .topLacture else {return}
        self.selectedFilters = GlobleVAR.filterModel
       // oprationalDB = Lecture.getLecturs(with: filters, rawlectures: self.oprationalDB ?? [])
        applyWithAllFilterCheckes()
    }
    func videoFileter(with status: Bool) {
        guard GlobleVAR.selectedTab == .topLacture else {return}
       // oprationalDB = Lecture.getLecture(withVideo: status, rawLectures: self.oprationalDB ?? [])
        applyWithAllFilterCheckes()
    }
    
    func applyWithAllFilterCheckes(){
        let searchstr = navView.txtSearch.text
        let isVideo =  navView.switchVideo.isOn
        oprationalDB = Lecture.getProccessedLecters(with: self.mainDBRawLectures, searchStr: searchstr, isVideos: isVideo, sortBy: self.selectedSortType, filterPoints: self.selectedFilters)
    }
    
   
}
