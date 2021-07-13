//
//  FavoritesVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 09/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
//import SundeedQLite
import LongPressReorder
import Toaster
import Firebase
import CodableFirebase

class FavoritesVC: UIViewController {
    private var selectedFilters : [Filter] = []

   private var selectedSortType:Sortkind = .none
    var reorderTableView: LongPressReorderTableView!

    var oprationalDB : lectures? = nil {
        didSet{
             GlobleDB.rawPalyable = oprationalDB ?? []
            tblPlaylist.reloadData()
        }
    }
    static var maindbFavorites : lectures?
    @IBOutlet weak var playerSpace: NSLayoutConstraint!
    @IBOutlet weak var navView:navigationControlView!

      
    @IBOutlet weak var tblPlaylist: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

            self.initialLoad()
   
    }
    override func viewWillAppear(_ animated: Bool) {
        navView.switchVideo.setOn(GlobleVAR.isVideoMode, animated: false)
        navView.lblLecturType.text = GlobleVAR.isVideoMode ? "Video" : "Audio"
        GlobleVAR.selectedTab  = .favourite
        GlobleVAR.filterModel = self.selectedFilters
        GlobleVAR.searchfilterDeligate = self
        GlobleVAR.filterDeligate = self
        getFreshLecture()

    }

    func initialLoad(){
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
            getFreshLecture()
       }

          @objc func notificationPlayerState(notification: Notification) {
              
              DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                  if GlobleVAR.selectedTab == .favourite{
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
        if GlobleVAR.selectedTab == .favourite{
            print("FAVOURITE OVSERVER CALL +++++++")
            getFreshLecture()
        }
        
    }
    private func getFreshLecture(){
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            let lect  = GlobleDB.rawGloble.filter({$0.info?.isFavourite == true})
            let sortByPosition = lect.sorted(by: {$0.info!.favouritePlace! < $1.info!.favouritePlace!} )
            self.oprationalDB = sortByPosition
            GlobleDB.rawFavourite = sortByPosition
        }
    }
   

       
       func configureTableView(){
           tblPlaylist.delegate = self
           tblPlaylist.dataSource = self
            tblPlaylist.register(UINib(nibName: "V2lectureCell", bundle: nil), forCellReuseIdentifier: "V2lectureCell")
       }
    
  

}

extension FavoritesVC: UITableViewDelegate, UITableViewDataSource{
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
        cell.section = .favourite
        cell.lecture = oprationalDB![indexPath.row]
        
        
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

extension FavoritesVC {
    
    override func startReorderingRow(atIndex indexPath: IndexPath) -> Bool {
        print("********* startReorderingRow ************")

        return true
    }
    
    override func allowChangingRow(atIndex indexPath: IndexPath) -> Bool {
        
        if GlobleDB.rawFavourite.count == self.oprationalDB?.count{
            print("\(indexPath)********* allowChangingRow ************")

            return true
        }else{
            print("\(indexPath)********* Not allowChangingRow ************")

            Toast(text: "Place adjustment is not possible with search result!",  duration: Delay.long).show()
        return false
        }
    }
    
    override func positionChanged(currentIndex: IndexPath, newIndex: IndexPath) {
        print("\(currentIndex)********* positionChanged ************\(newIndex)")
    

    }
    
    override  func reorderFinished(initialIndex: IndexPath, finalIndex: IndexPath) {
        print("\(initialIndex)********* reorderFinished *************\(finalIndex)")
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            self.oprationalDB!.swapAt(initialIndex.row, finalIndex.row)
            GlobleDB.rawFavourite.swapAt(initialIndex.row, finalIndex.row)
            self.updatePlaceCounting()
        }
    }
    private func updatePlaceCounting(){
        DispatchQueue.main.async {
            LectureInfo.setPlaceValue(ofLecters: self.oprationalDB ?? [], favourite:true)
            if let currentIndex =  GlobleDB.rawFavourite.firstIndex(where: {$0.id == GlobleVAR.currentPlay?.id})
            {
                GlobleVAR.currentIndex = currentIndex
            }
        }
    }
}

extension FavoritesVC:FilterApplyProtocoal,lectureSearchProtocol{
   
    func filterWithString(search :String,isActiveString:Bool){
         guard GlobleVAR.selectedTab == .favourite else {return}
         print("Home lecture Search ------->\(search)")
        applyWithAllFilterCheckes()
     }
    
    func lectureList(sortBy: Sortkind) {
      guard GlobleVAR.selectedTab == .favourite else {return}
        self.selectedSortType = sortBy
        applyWithAllFilterCheckes()
    }
    
    func filterApply(with selecter: Int, filters: [Filter]) {
        guard GlobleVAR.selectedTab == .favourite else {return}
        self.selectedFilters = GlobleVAR.filterModel
        applyWithAllFilterCheckes()
    }
    func videoFileter(with status: Bool) {
        guard GlobleVAR.selectedTab == .favourite else {return}
        applyWithAllFilterCheckes()
    }
    
    func applyWithAllFilterCheckes(){
        let searchstr = navView.txtSearch.text
        let isVideo =  navView.switchVideo.isOn
        oprationalDB = Lecture.getProccessedLecters(with: GlobleDB.rawFavourite, searchStr: searchstr, isVideos: isVideo, sortBy: self.selectedSortType, filterPoints: self.selectedFilters)
    }
}

