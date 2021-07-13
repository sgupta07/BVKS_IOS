//
//  DownloadsVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 09/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
import LongPressReorder
import Firebase
import CodableFirebase
import Toaster
class DownloadsVC: UIViewController {
    private var selectedFilters : [Filter] = []
    private var selectedSortType:Sortkind = .none
    private var reorderTableView: LongPressReorderTableView!
    private var timer : Timer? = nil{
        willSet{
            guard timer != nil else { return }
            timer?.invalidate()
        }
    }
    
    private var oprationalDB : lectures? = nil {
        didSet{
            GlobleDB.rawPalyable = oprationalDB ?? []
            tblPlaylist.reloadData()
        }
    }
    
    
    @IBOutlet weak var tblPlaylist: UITableView!
    @IBOutlet weak var navView:navigationControlView!
    @IBOutlet weak var playerSpace: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.initview()
        self.initialLoad()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navView.switchVideo.setOn(GlobleVAR.isVideoMode, animated: false)
        navView.lblLecturType.text = GlobleVAR.isVideoMode ? "Video" : "Audio"
        GlobleVAR.selectedTab = .download
        GlobleVAR.filterModel = self.selectedFilters
        GlobleVAR.searchfilterDeligate = self
        GlobleVAR.filterDeligate = self
        getFreshLecture()
        
        
        
    }
    private func configureTableView(){
        tblPlaylist.delegate = self
        tblPlaylist.dataSource = self
        tblPlaylist.register(UINib(nibName: "V2lectureCell", bundle: nil), forCellReuseIdentifier: "V2lectureCell")
    }
    
    private func initialLoad(){
        oprationalDB = []
        FilterHandler.shared.setPlayerSpace(spaceObj: self.playerSpace)
        navView.topVC = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedSetPlayerModel(notification:)), name: Notification.Name(AppNotification.setPlayerModel), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPlayerState(notification:)), name: Notification.Name(AppNotification.setPlayerState), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationLectureInfoUpdate(notification:)), name: Notification.Name(AppNotification.lectureInfoUpadte), object: nil)
        
        reorderTableView = LongPressReorderTableView(self.tblPlaylist, scrollBehaviour: .early)
        reorderTableView.delegate = self
        reorderTableView.enableLongPressReorder()
        configureTableView()
        // dbDownlodLectureList()
    }
    
    @objc func notificationPlayerState(notification: Notification) {
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            if GlobleVAR.selectedTab == .download{
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
    
    @objc func notificationLectureInfoUpdate(notification: Notification) {
        if GlobleVAR.selectedTab == .download{
            print("DOWNLOAD OVSERVER CALL +++++++")
            getFreshLecture()
        }
    }
    
    private func getFreshLecture(){
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            let lect  = GlobleDB.rawGloble.filter({$0.info?.isDownloded == true})
            self.oprationalDB = lect
            GlobleDB.rawDownload = lect
        }
    }
    
    
    
    
    
    
    
}

extension DownloadsVC: UITableViewDelegate, UITableViewDataSource{
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
        cell.section = .download
        cell.lecture = oprationalDB?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lect = oprationalDB![indexPath.row]
        NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerModel), object: ["playerModel":lect])
        
    }
}
// MARK: - Long press drag and drop reorder

//extension FavoritesVC {
//
//    override func positionChanged(currentIndex: IndexPath, newIndex: IndexPath) {
//        print("\(currentIndex)**********************\(newIndex)")
//    }
//    override  func reorderFinished(initialIndex: IndexPath, finalIndex: IndexPath) {
//        print("\(initialIndex)*********reorderFinished*************\(finalIndex)")
//        self.oprationalDB!.swapAt(initialIndex.row, finalIndex.row)
//        GlobleDB.rawFavourite.swapAt(initialIndex.row, finalIndex.row)
//        updatePlaceCounting()
//    }
//    private func updatePlaceCounting(){
//        DispatchQueue.main.async {
//            LectureInfo.setPlaceValue(ofLecters: self.oprationalDB ?? [], favourite:true)
//            if let currentIndex =  GlobleDB.rawFavourite.firstIndex(where: {$0.id == GlobleVAR.currentPlay?.id})
//            {
//                GlobleVAR.currentIndex = currentIndex
//            }
//        }
//    }
//}
extension DownloadsVC {
    
    override func startReorderingRow(atIndex indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func allowChangingRow(atIndex indexPath: IndexPath) -> Bool {
        if GlobleDB.rawDownload.count == self.oprationalDB?.count{
            return true
        }else{
            Toast(text: "Place adjustment is not possible with search result!",  duration: Delay.long).show()
        return false
        }
        
    }
    
    override func positionChanged(currentIndex: IndexPath, newIndex: IndexPath) {
        print("\(currentIndex)*********positionChanged*************(newIndexnotificationPlayerState)")

        // Simulate a change in model
//        self.timer = nil
//
//        self.oprationalDB!.swapAt(currentIndex.row, newIndex.row)
//        GlobleDB.rawDownload.swapAt(currentIndex.row, newIndex.row)
//        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updatePlaceCounting), userInfo: nil, repeats: true)
        
        
    }
        override  func reorderFinished(initialIndex: IndexPath, finalIndex: IndexPath) {
            self.timer = nil
            print("\(initialIndex)*********reorderFinished*************\(finalIndex)")
            self.oprationalDB!.swapAt(initialIndex.row, finalIndex.row)
            GlobleDB.rawDownload.swapAt(initialIndex.row, finalIndex.row)
            updatePlaceCounting()
        }
    @objc func updatePlaceCounting(){
        DispatchQueue.main.async {
            self.timer = nil
            
            //              QLightHendler.shared.setSortValue(download: true)
            if let currentIndex =  GlobleDB.rawDownload.firstIndex(where: {$0.id == GlobleVAR.currentPlay?.id})
            {
                GlobleVAR.currentIndex = currentIndex
            }
            
        }
    }
}
//MARK:- FILTER LOGIC
extension DownloadsVC:FilterApplyProtocoal{
    func lectureList(sortBy: Sortkind) {
        guard GlobleVAR.selectedTab == .download else {return}
        self.selectedSortType = sortBy
        let sortlist = Lecture.getLectures(sortBy: sortBy, rawLecture: self.oprationalDB ?? [])
        // GlobleDB.rawDownload = sortlist
        self.oprationalDB = sortlist
    }
    
    func filterApply(with selecter: Int, filters: [Filter]){
        guard GlobleVAR.selectedTab == .download else {return}
        func findInterSection (firstArray : [String], secondArray : [String]) -> [String]
        {
            return [String](Set<String>(firstArray).intersection(secondArray))
        }
        
        if selecter == 0{
            self.oprationalDB = GlobleDB.rawDownload
        }else{
            self.oprationalDB?.removeAll()
            self.oprationalDB = GlobleDB.rawDownload
            for (index,filter) in GlobleVAR.filterModel.enumerated(){
                let selectedOpt = filter.selected
                guard selectedOpt?.count ?? 0 > 0 else {
                    continue
                }
                switch index {
                case 0://Languages
                    
                    var filterLacture:lectures = []
                    filterLacture = self.oprationalDB?.filter({(selectedOpt?.contains($0.language?.main ?? "") ?? false)}) ?? []
                    if filterLacture.count > 0 {
                        self.oprationalDB = filterLacture
                    }else{
                        self.oprationalDB = []
                        
                    }
                    continue
                case 1://Countries
                    var filterLacture:lectures = []
                    filterLacture = self.oprationalDB?.filter({(selectedOpt?.contains($0.location?.country ?? "") ?? false)}) ?? []
                    if filterLacture.count > 0 {
                        self.oprationalDB = filterLacture
                    }else{
                        self.oprationalDB = []
                        
                    }
                    continue
                case 2://Place
                    var filterLacture:lectures = []
                    
                    filterLacture = self.oprationalDB?.filter({lectur in
                        let result = findInterSection(firstArray: lectur.place ?? [] , secondArray: selectedOpt ?? [])
                        if result.count > 0{
                            return true
                        }else{return false}
                    }) ?? []
                    
                    
                    if filterLacture.count > 0 {
                        self.oprationalDB = filterLacture
                    }else{
                        self.oprationalDB = []
                        
                    }
                    continue
                case 3://Years
                    var filterLacture:lectures = []
                    filterLacture = self.oprationalDB?.filter({(selectedOpt?.contains($0.dateOfRecording?.year ?? "") ?? false)}) ?? []
                    if filterLacture.count > 0 {
                        self.oprationalDB = filterLacture
                    }else{
                        self.oprationalDB = []
                        
                    }
                    continue
                case 4://Month
                    var filterLacture:lectures = []
                    filterLacture = self.oprationalDB?.filter({(selectedOpt?.contains($0.dateOfRecording?.month ?? "") ?? false)}) ?? []
                    if filterLacture.count > 0 {
                        self.oprationalDB = filterLacture
                    }else{
                        self.oprationalDB = []
                        
                    }
                    continue
                case 5://Categories
                    var filterLacture:lectures = []
                    
                    filterLacture = self.oprationalDB?.filter({lectur in
                        let result = findInterSection(firstArray: lectur.category ?? [] , secondArray: selectedOpt ?? [])
                        if result.count > 0{
                            return true
                        }else{return false}
                    }) ?? []
                    
                    
                    if filterLacture.count > 0 {
                        self.oprationalDB = filterLacture
                    }else{
                        self.oprationalDB = []
                        
                    }
                    continue
                case 6://Translation
                    var filterLacture:lectures = []
                    
                    filterLacture = self.oprationalDB?.filter({lectur in
                        let result = findInterSection(firstArray: lectur.language?.translations ?? [] , secondArray: selectedOpt ?? [])
                        if result.count > 0{
                            return true
                        }else{return false}
                    }) ?? []
                    
                    
                    if filterLacture.count > 0 {
                        self.oprationalDB = filterLacture
                    }else{
                        self.oprationalDB = []
                        
                    }
                    continue
                default:
                    break
                }
                
            }
        }
        if let indexOfPlayLecture = GlobleDB.rawDownload.firstIndex(where: {$0.id == GlobleVAR.currentPlay?.id})
        {
            GlobleVAR.currentIndex = indexOfPlayLecture
        }else{
            GlobleVAR.currentIndex = 0
        }
        
        self.tblPlaylist.reloadData()
        
        
    }
    
    func videoFileter(with status: Bool) {
        guard GlobleVAR.selectedTab == .download else {return}
        
        if status{
            let videoLect = Lecture.getLecture(withVideo: status, rawLectures: self.oprationalDB ?? [])
            self.oprationalDB = videoLect
        }else{
            self.oprationalDB = GlobleDB.rawDownload
            
        }
        self.tblPlaylist.reloadData()
        
    }
    
}
//MARK:- SEARCH LOGIC
extension DownloadsVC:lectureSearchProtocol{
    
    
    func filterWithString(search :String, isActiveString:Bool){
        guard GlobleVAR.selectedTab == .download else {return}
        if isActiveString{
            self.oprationalDB?.removeAll()
            func removeDuplicateElements(lectures: [Lecture]) -> [Lecture] {
                var uniquePosts : lectures = []
                for lect in lectures {
                    if !uniquePosts.contains(where: {$0.id == lect.id })  {
                        uniquePosts.append(lect)
                    }
                }
                return uniquePosts
            }
            let filter1 = GlobleDB.rawDownload.filter({ (lect) -> Bool in
                return lect.title?.joined().range(of: search.replacingOccurrences(of: " ", with: ""), options: .caseInsensitive) != nil
            })
            let filter2 = GlobleDB.rawDownload.filter({ (lect) -> Bool in
                return lect.search?.advanced?.joined().range(of: search, options: .caseInsensitive) != nil
            })
            let filter3 = GlobleDB.rawDownload.filter({ (lect) -> Bool in
                return lect.search?.simple?.joined().range(of: search, options: .caseInsensitive) != nil
            })
            
            self.oprationalDB?.append(contentsOf: filter1 )
            self.oprationalDB?.append(contentsOf: filter2 )
            self.oprationalDB?.append(contentsOf: filter3 )
            
            self.oprationalDB = removeDuplicateElements(lectures: self.oprationalDB ?? [])
            
        }else{
            self.oprationalDB = GlobleDB.rawDownload
        }
        
        if let indexOfPlayLecture = GlobleDB.rawDownload.firstIndex(where: {$0.id == GlobleVAR.currentPlay?.id})
        {
            GlobleVAR.currentIndex = indexOfPlayLecture
        }else{
            GlobleVAR.currentIndex = 0
        }
        
        tblPlaylist.reloadData()
        print("=====\(search)")
    }
    
}
