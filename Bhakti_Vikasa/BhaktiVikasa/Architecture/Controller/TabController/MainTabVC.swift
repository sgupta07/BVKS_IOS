//
//  MainTabVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 23/11/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
//import SundeedQLite
import CodableFirebase
import Toaster
import AVFoundation
class MainTabVC: UITabBarController {
    static var tabBarController:((_ selectedIndex:Int)->Void)?
    static var tabBarControllerOnUnivarsalLink:((_ selectedIndex:Int)->Void)?
    private var toast = Toast(text: "")
    
    @IBOutlet weak var audioPlayer:AudioView!
    @IBOutlet weak var videoPlayer:VideoView!
    var temGloble: lectures? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabApparance()
        initViewSetup()
        addMiniPlayer()
    }
    
    func initViewSetup(){
        self.delegate = self
        toast.cancel()
        toast=Toast(text:"Loading lecture library...",duration: Delay.long)
        toast.show()
        CommonFunc.shared.switchAppLoader(value: true)
        
        if (self.isPreviousePlayID() != nil){
            self.checkLocalStatuse()
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                self.getFirelectureList()
            })
        }
        User.getUserPlayHistory()
        MainTabVC.tabBarController = { (id) -> Void in
            if id == 2{
                GlobleVAR.selectedTab  = .topLacture
                self.selectedIndex = 2
            }else{
                GlobleVAR.selectedTab  = .home
                self.selectedIndex = 0
            }
        }
        
        
    }
    
    func setTabApparance(){
        UITabBar.appearance().barTintColor = AppColors.primaryOring
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().tintColor  = .white
        UITabBar.appearance().unselectedItemTintColor = UIColor.darkGray
    }
    
}
extension MainTabVC:UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let viewControllers = tabBarController.viewControllers else { return }
        print("--------- TAB CHANGE -------")
        let tappedIndex = viewControllers.firstIndex(of: viewController)!
        switch tappedIndex {
        case 0:
            GlobleVAR.selectedTab  = .home
            break
        case 1:
            GlobleVAR.selectedTab  = .playList
            break
        case 2:
            GlobleVAR.selectedTab  = .topLacture
            break
        case 3:
            GlobleVAR.selectedTab  = .download
            break
        case 4:
            GlobleVAR.selectedTab  = .favourite
            
            break
        default:
            GlobleVAR.selectedTab = GlobleVAR.selectedTab
            break
        }
        
    }
    
    
}
//MARK: GET LECTURES
extension MainTabVC{
    func isPreviousePlayID() -> Int?{
        if let recode = UserDefaults.standard.dictionary(forKey: "lastPlay"){
            print("+++++++PREVIOUSE RECORD FOUND AT HOME++++++++\(recode)")
            let id = recode["ID"] as! Int
            
            return id
            
        }else{
            return nil
        }
    }
    
    
    fileprivate func checkLocalStatuse(){
        self.getLocalJson { (jsonArray) in
            DispatchQueue.global(qos: .background).async {
                FRFirestoreObserve.shared.didChangeLecturInfo(completion: {_ in })
            }
            if let dbLectures = jsonArray,dbLectures.count>0{
                var fLect = lectures()
                
                for lect in dbLectures {
                    let model = try! FirestoreDecoder().decode(Lecture.self, from: lect as! [String : Any])
                    fLect.append(model)
                    //print("??????",model.search?.advanced)
                }
                //self.setCurrentPlayModel(rawLecture:fLect)
                self.basicProceduer(firLecters: fLect)
            }else{
                self.getFirelectureList()
            }
        }
    }
    
    fileprivate func getLocalJson(completion:@escaping(_ localDB:NSArray?) -> Void){
        
        do {
            let result = try JSONSerialization.loadJSON(withFilename: "BVDB")
            if let dbLectures = result as? NSArray,dbLectures.count>0{
                
                completion(dbLectures)
            }else{
                completion(nil)
            }
        }catch let e {
            print("\(e.localizedDescription)")
            completion(nil)
        }
        
    }
    
    
    fileprivate func getFirelectureList(){
        //get with listeners
        FRFirestoreObserve.shared.didChangeLecturInfo(completion: {(lecture) in
            if let fLecters = lecture{
                self.basicProceduer(firLecters: fLecters)
            }else{
                self.toast.cancel()
                self.toast=Toast(text:"'BHAKTI LECTURES' are not available right now,try later.",duration: Delay.long)
                self.toast.show()
                return
            }
        })
    }
    
    fileprivate func basicProceduer(firLecters:lectures){
        
        toast.cancel()
       // toast=Toast(text:"LECTURES INFO IS LOADING...",duration: Delay.long)
        toast=Toast(text:"Loading audio library",duration: Delay.long)
        toast.show()
        
        let sortMigrationArray = Lecture.getLectures(sortBy: .recordingDateDescending, rawLecture: firLecters)
        self.loadWithFresh(lectures: sortMigrationArray)
        GlobleVAR.filterModel.removeAll()
        Filter.createFilterObject(lectures: sortMigrationArray)
        self.onceRecivedSaveData()
        
        
    }
    fileprivate func onceRecivedSaveData(){
        
        func setCurrentPlayer(){
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                guard let id = self.isPreviousePlayID(),  id > 0 else {return}
                if let lecture = GlobleDB.rawGloble.first(where: {$0.id == id }){
                    GlobleVAR.currentPlay = lecture
                    self.setPlayerDetail(lecture: lecture)
                    print("---------PLAYWITH PREVIOUSE LECTURE------------")
                    guard let info =  GlobleVAR.currentPlay?.info else{return}
                    guard let currentPlayTime = info.lastPlayedPoint else {return}
                    CommonPlayerFunc.shared.playWithCurrent(Possition: Double(currentPlayTime))
                }else{
                    print("---------PLAYWITH PREVIOUSE LECTURE NOT AVAILABLE------------")
                }
            }
        }
        //Get all lecture info for perticuler User
        
        LectureInfo.addSnapsotListinerOnLectureinfo{ (lecture) in
            DispatchQueue.main.async {
                if GlobleVAR.isFirstPlay{
                    print("--------- LECTURE INFO GET ------------")
                    DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                        setCurrentPlayer()
                        CommonFunc.shared.switchAppLoader(value: false)
                        self.toast.cancel()
                       // self.toast=Toast(text:"'LECTURES ARE READY'",duration: Delay.long)
                        self.toast=Toast(text:"Ready",duration: Delay.long)
                        self.toast.show()
                    }
                    
                }
            }
        }
    }
    
    
    //    fileprivate func getSaveDate() -> lectures?{
    //        guard GlobleDB.rawDownload != nil else {
    //            return nil
    //
    //        }
    //        guard GlobleDB.rawFavourite != nil else {
    //            return GlobleDB.rawDownload
    //
    //        }
    //        let combinationLecture = GlobleDB.rawDownload + GlobleDB.rawFavourite
    //
    //        return combinationLecture
    //
    //    }
    
    fileprivate func loadWithFresh(lectures:lectures){
        DispatchQueue.main.async {
            self.temGloble = lectures
            GlobleDB.rawGloble = lectures
            GlobleVAR.searchfilterDeligate?.filterWithString(search: "", isActiveString: false)
            ToastCenter.default.cancelAll()
            //  Toast(text:"Library is now ready!",duration: Delay.long).show()
            //  CommonFunc.shared.switchAppLoader(value: false)
            
        }
        
    }
    fileprivate func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
//MARK: MINI PLAYER VIEW
extension MainTabVC{
    private func addMiniPlayer(){
        CommonFunc.shared.getSafeAreaSize()
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            func addPlayerAtPosition(player:UIView){
                let tabFream = self.tabBar.frame
                let playerHeight = player.frame.height
              //  let yaxes = GlobleVAR.bottomSafeAreaHeight+playerHeight
                 let yaxes = playerHeight

                
                player.frame = CGRect(origin: CGPoint(x: 0.0, y: tabFream.origin.y-yaxes), size: CGSize(width: tabFream.width, height: playerHeight))
                self.view.addSubview(player)
                self.view.bringSubviewToFront(player)
            }
            addPlayerAtPosition(player: self.audioPlayer)
            addPlayerAtPosition(player: self.videoPlayer)
            self.audioPlayer.isHidden = true
            self.videoPlayer.isHidden = true
            self.AddPlayerNotificationObserver()
        }
    }
    private func setMiniPlayerVisibilty(){
        if GlobleVAR.currentPlay == nil{
            self.audioPlayer.isHidden = true
            self.videoPlayer.isHidden = true
        }else if GlobleVAR.currentPlay?.resources?.videos?.first?.url?.count ?? 0 > 0 && GlobleVAR.isVideoMode,!GlobleVAR.mustAudio{
            self.audioPlayer.isHidden = true
            self.videoPlayer.isHidden = false
            self.view.bringSubviewToFront(self.videoPlayer)
        }else{
            self.audioPlayer.isHidden = false
            self.videoPlayer.isHidden = true
            self.view.bringSubviewToFront(self.audioPlayer)
        }
        
        FilterHandler.shared.setPlayerSpace()
    }
    
    private func AddPlayerNotificationObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationSetPlayerModel(notification:)), name: Notification.Name(AppNotification.setPlayerModel), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPlayerState(notification:)), name: Notification.Name(AppNotification.setPlayerState), object: nil)
    }
    
    
    
    
    @objc func notificationPlayerState(notification: Notification) {
        
        if CommonPlayerFunc.shared.isPlaying{
            self.videoPlayer.btnPlayPause.setImage(#imageLiteral(resourceName: "pauseP-24px"), for: .normal)
            self.audioPlayer.btnPlay.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }else{
            self.videoPlayer.btnPlayPause.setImage(#imageLiteral(resourceName: "play_arrow-24px"), for: .normal)
            self.audioPlayer.btnPlay.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }
    @objc func notificationSetPlayerModel(notification: Notification) {
        print(notification)
        self.view.endEditing(true)
        if let lect = (notification.object as? NSDictionary)?.value(forKey: "playerModel") as? Lecture,isCurrentPlay(rawlecture:lect){
            GlobleVAR.currentPlay = lect
            self.setPlayerDetail(lecture: lect)
        }
    }
    
    //pause and play Current played lecter
    //if user tap on playe lecture twice player state Toggal
    private func isCurrentPlay(rawlecture:Lecture)->Bool{

        var playStatus :Bool = false
        if GlobleVAR.currentPlay?.id ==  rawlecture.id {
            if GlobleVAR.mustAudio,audioPlayer.isHidden{
                playStatus = true
            }else if GlobleVAR.isRepeatMode{
                playStatus = false
                CommonPlayerFunc.shared.playWithCurrent(Possition: 0.0)
            }else if CommonPlayerFunc.shared.isPlaying{
                CommonPlayerFunc.shared.pause()
                playStatus = false
            }else if !CommonPlayerFunc.shared.isPlaying{
                CommonPlayerFunc.shared.play()
                playStatus = false
            }
        }else{
            CommonPlayerFunc.shared.play()
            playStatus = true
        }
        NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerState), object: nil)
        return  playStatus
        
    }
    private func setPlayerDetail(lecture:Lecture){
        
        DispatchQueue.main.async {
            self.setMiniPlayerVisibilty()
            if let vUrl = GlobleVAR.currentPlay?.resources?.videos?.first?.url, GlobleVAR.isVideoMode,!GlobleVAR.mustAudio{
                self.videoPlayer.videoUrl = vUrl
            }else{
                self.audioPlayer.detailForAudioPlay(lect: lecture)
                CommonPlayerFunc.shared.audioLength = Double(lecture.length ?? 0)
            }
            
            
            if CommonPlayerFunc.shared.isPlaying{
                CommonPlayerFunc.shared.player.pause()
                CommonPlayerFunc.shared.player = AVPlayer()//.stop()
            }
            let tempImageForNotificationCenter = UIImageView(image:  #imageLiteral(resourceName: "bvks_thumbnail"))
            tempImageForNotificationCenter.kf.setImage(with: URL(string: lecture.thumbnail ?? ""), placeholder:  #imageLiteral(resourceName: "bvks_thumbnail"),completionHandler:{(result) in
                if GlobleVAR.isVideoMode == false || GlobleVAR.mustAudio == true{
                    if let localurl = lecture.info?.ios?.audios?.url, localurl != "" && lecture.info?.isDownloded == true {
                        let localData = CommonFunc.shared.isFileinLocaleDB(lectureRaw: lecture)
                        if localData.status == true{
                            //play with local url
                            CommonPlayerFunc.shared.setUpPlayerWithLocalUrl(PlaybackUrl: localData.Path)
                            if let currentPlay = lecture.info?.lastPlayedPoint, currentPlay > 0{
                                CommonPlayerFunc.shared.playWithCurrent(Possition: Double(currentPlay))
                            }
                        }else{
                            Toast(text:"Please download this audio again.",duration: Delay.long).show()
                            //Play with Live url
                            let liveurl =  lecture.resources?.audios?.first?.url ?? ""
                            CommonPlayerFunc.shared.setUpPlayer(PlaybackUrl: liveurl)
                            if let currentPlay = lecture.info?.lastPlayedPoint, currentPlay > 0{
                                CommonPlayerFunc.shared.playWithCurrent(Possition: Double(currentPlay))
                            }
                        }
                        //++++++++++++DONOT REMOB THIS COMMENT+++++++++++//
//                        if CommonFunc.shared.isDownloadFileExiset(path:localurl){
//                            //play with local url
//                            CommonPlayerFunc.shared.setUpPlayerWithLocalUrl(PlaybackUrl: localurl)
//                            if let currentPlay = lecture.info?.lastPlayedPoint, currentPlay > 0{
//                                CommonPlayerFunc.shared.playWithCurrent(Possition: Double(currentPlay))
//                            }
//                        }else{
//                            Toast(text:"Need to redownload This lecture",duration: Delay.long).show()
//                            //Play with Live url
//                            let liveurl =  lecture.resources?.audios?.first?.url ?? ""
//                            CommonPlayerFunc.shared.setUpPlayer(PlaybackUrl: liveurl)
//                            if let currentPlay = lecture.info?.lastPlayedPoint, currentPlay > 0{
//                                CommonPlayerFunc.shared.playWithCurrent(Possition: Double(currentPlay))
//                            }
//                        }
                    }else{
                        //Play with Live url
                        let liveurl =  lecture.resources?.audios?.first?.url ?? ""
                        CommonPlayerFunc.shared.setUpPlayer(PlaybackUrl: liveurl)
                        if let currentPlay = lecture.info?.lastPlayedPoint, currentPlay > 0{
                            CommonPlayerFunc.shared.playWithCurrent(Possition: Double(currentPlay))
                        }
                    }
                }
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                    CommonPlayerFunc.shared.setupNowPlaying(lecture: lecture,playerIcon: tempImageForNotificationCenter.image!)
                    
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                    CommonPlayerFunc.shared.setupNowPlaying(lecture: lecture,playerIcon: #imageLiteral(resourceName: "bvks_thumbnail"))
                    
                }
            } )
            //user for history
            User.addToHistoryPlaylist()
            //recored All Played lectures
            //FRFirestoreObserve.shared.updateFirStoreWithPlayedIDs()
            //Add on top Play lecturers
            TopLecture.updateTopPlayDetailsOnFireStore()
        }
    }
    
    
    
}



