//
//  PlayerVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 10/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import DropDown
import XCDYouTubeKit
class PlayerVC: UIViewController {

    @IBOutlet weak var imgMainPlayer: UIImageView!

    @IBOutlet weak var lblAudioLenth: UILabel!
    @IBOutlet weak var lblAudioCurrentPoint: UILabel!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var btnPlayBack: UIButton!
    @IBOutlet weak var btnVideoPlay: UIButton!
    @IBOutlet weak var btnSuffal: UIButton!
    @IBOutlet weak var btnRapet: UIButton!

    private let playBackSpeed = ["0.25X","0.50X","0.75X","1.0X","1.15X", "1.25X", "1.5X","1.75X", "2.0X"]
    @IBOutlet weak var pogressBar: UISlider!
    var onDoneBlock : (()->())?
    var updater: CADisplayLink! = nil
    var timer: Timer!
    var videoUrl : String = ""
    // DETAILS
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblRecordingPlace:UILabel!
    @IBOutlet weak var lblCategory:UILabel!
    @IBOutlet weak var lblLanguage:UILabel!
    @IBOutlet weak var lblCountry:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        initialLoad()
        // Do any additional setup after loading the view.
    }
    
    
    func initialLoad(){
        guard let lecture =  GlobleVAR.currentPlay else{return}

        setrapetSuffalApparance()
        self.btnPlayBack.setTitle(playBackSpeed[GlobleVAR.speedIndex], for: .normal)
        if GlobleVAR.currentPlay?.info?.isDownloded == true{
            
            let localData =  CommonFunc.shared.isFileinLocaleDB(lectureRaw: lecture)
                   if localData.status == true{
                       self.btnDownload.setImage(#imageLiteral(resourceName: "oringDownload"), for: .normal)
                   }else{
                       self.btnDownload.setImage(#imageLiteral(resourceName: "oringalerts"), for: .normal)
                   }
        }else{
            
            self.btnDownload.setImage(#imageLiteral(resourceName: "ic_download"), for: .normal)

        }
        self.imgMainPlayer.kf.setImage(with: URL(string: lecture.thumbnail ?? ""), placeholder: #imageLiteral(resourceName: "bvks_thumbnail"))
              self.pogressBar.value = Float(CommonPlayerFunc.shared.currentTime/CommonPlayerFunc.shared.audioLength)

        self.pogressBar.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationSetPlayerModel(notification:)), name: Notification.Name(AppNotification.setPlayerModel), object: nil)
          NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPlayerState(notification:)), name: Notification.Name(AppNotification.setPlayerState), object: nil)
        self.notificationPlayerState(notification: Notification(name: Notification.Name(rawValue: AppNotification.setPlayerState)))
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: (#selector(self.trackAudio)), userInfo: nil, repeats: true)
        setLectureDetails()
    }

    func setLectureDetails(){
        guard let lect = GlobleVAR.currentPlay else {
            return
        }
        self.lblTitle.text = "Lecture Title: " + lect.title!.joined(separator: " ")
        let day = lect.dateOfRecording?.day ?? ""
        let month = lect.dateOfRecording?.month ?? ""
        let year = lect.dateOfRecording?.year ?? ""
        
        self.lblDate.text = "Recording Date: "+day+"/"+month+"/"+year
        if let place = lect.place?.joined(separator: ","){
            self.lblRecordingPlace.text = "Place of Recording: "+place
        }else{
            self.lblRecordingPlace.text = "Place of Recording: "
        }
        if let category = lect.category?.joined(separator: ",") {
            self.lblCategory.text = "Category: "+category
            
        }else{
            self.lblCategory.text = "Category: "
        }
        if let language = lect.language?.main{
            self.lblLanguage.text = "Language: "+language
        }
        if let country = lect.location?.country{
            self.lblCountry.text = "Country: "+country
        }

        var startTime = CommonPlayerFunc.shared.currentTime.secToMintasString(style: .positional)
        if startTime.count<=2{
            startTime = "00:00:\(startTime)"
        }else if startTime.count<=4{
            startTime = "00:0\(startTime)"
        }else if startTime.count<=5{
            startTime = "00:\(startTime)"
        }
        lblAudioCurrentPoint.text = startTime
        
        var endTime = CommonPlayerFunc.shared.audioLength.secToMintasString(style: .positional)
        if endTime.count<=2{
            endTime = "00:00:\(endTime)"
        }else if endTime.count<=4{
            endTime = "00:0\(endTime)"
        }else if endTime.count<=5{
            endTime = "00:\(endTime)"
        }
        lblAudioLenth.text = endTime
    }
    
    private func setrapetSuffalApparance(){
        pogressBar[thumImage: .normal] = #imageLiteral(resourceName: "slider_thumb").resize(to: .init(width: 15, height: 15))
        pogressBar[thumImage: .selected] = #imageLiteral(resourceName: "slider_thumb").resize(to: .init(width: 15, height: 15))
        self.btnRapet.tintColor = GlobleVAR.isRepeatMode == true ? AppColors.primaryOring :.white
        self.btnSuffal.tintColor = GlobleVAR.isShuffleMode == true ? AppColors.primaryOring :.white
        self.btnRapet.tintColor = GlobleVAR.isRepeatMode == true ? AppColors.primaryOring :.white
        self.btnSuffal.tintColor = GlobleVAR.isShuffleMode == true ? AppColors.primaryOring :.white
    }
   
    
    override func viewWillDisappear(_ animated: Bool) {
        onDoneBlock?()
    }
    
    @IBAction func back(_ sender: UIButton)-> Void{
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.removeObserver(self)
    }
     @IBAction func addToPlayList(_ sender: UIButton)-> Void{
        self.dismiss(animated: true) {
            PlayList.addToPlayListAlert(lect: GlobleVAR.currentPlay!)
        }
    }
    
    @IBAction func setFavouriteVisibility(_ sender: UIButton)-> Void{
        
        sender.setImage(sender.currentImage == #imageLiteral(resourceName: "star-1") ? #imageLiteral(resourceName: "favoriteTab") : #imageLiteral(resourceName: "star-1"), for: .normal)
        var rawInfo = LectureInfo()
        
        LectureInfo.getCurrentSnapshot(with: (GlobleVAR.currentPlay?.id!)!) { (lInfo) in
            if let nInfo = lInfo{
                    rawInfo = nInfo
                    rawInfo.isFavourite = sender.currentImage == #imageLiteral(resourceName: "star-1") ? true : false
                    rawInfo.lastModifiedTimestamp = c_Time
                    rawInfo.favouritePlace = 0
                    LectureInfo.setLectureInfo(with: rawInfo, isNew: false)
                }else{
                    rawInfo.id = GlobleVAR.currentPlay!.id
                    rawInfo.favouritePlace = 0
                    rawInfo.isFavourite = sender.currentImage == #imageLiteral(resourceName: "star-1") ? true : false
                    rawInfo.lastModifiedTimestamp = c_Time
                    LectureInfo.setLectureInfo(with: rawInfo,isNew: true)
                }
                
            }

    }
    
    @IBAction func shareCurrentPlayItem(_ sender: UIButton)-> Void{
        //GlobleVAR.currentPlay?.resources?.audios?.first?.url ?? ""
        guard let lecture = GlobleVAR.currentPlay else {return}
        UnivarsalLinkHandler.shared.shareLecture(lecture: lecture)

        
    }
    @IBAction func downloadCurrentPlayItem(_ sender: UIButton)-> Void{
       
        
        guard sender.currentImage != #imageLiteral(resourceName: "oringDownload") else{return}
        guard let lecture =  GlobleVAR.currentPlay else{return}
        sender.setImage(UIImage.gif(name: "blueLoader"), for: .normal)
        CommonFunc.shared.saveAudioFileLocalDB(with:lecture,competion: {[unowned self] (downloading,proLecture)   in
            if let progress = downloading{
                if progress < 100.0{
                    //self.downloadProgress.value = CGFloat(progress)
                }else{
                    sender.setImage(#imageLiteral(resourceName: "oringDownload"), for: .normal)
                }
            }else{
                sender.setImage(#imageLiteral(resourceName: "ic_download"), for: .normal)
            }
        })

    }
    @IBAction func playWithVideo(sender:UIButton){

       
        func playVideo(with Id: String) {

            let playerViewController = AVPlayerViewController()
            self.present(playerViewController, animated: true, completion: nil)
            XCDYouTubeClient.default().getVideoWithIdentifier(Id) { (video, error) in
                if let streamURL = video?.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue] {
                    playerViewController.player = AVPlayer(url: streamURL)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }

//            XCDYouTubeClient.default().getVideoWithIdentifier(Id) { (video: XCDYouTubeVideo?, error: Error?) in
//                if let streamURL = video?.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue] {
//                    playerViewController.player = AVPlayer(url: streamURL)
//                } else {
//                    self.dismiss(animated: true, completion: nil)
//                }
//            }
        }
        
        guard let youtubVID = videoUrl.split(separator: "/").last else { return }
        
        playVideo(with: String(youtubVID))



    }
    
   
}
//MARK: PLAYER OBJERVER
extension PlayerVC{
    
    @objc func trackAudio() {
        
        guard UIApplication.shared.applicationState != .background || UIApplication.shared.applicationState != .inactive || !pogressBar.isContinuous else{ return }
        let normalizedTime = Float(CommonPlayerFunc.shared.currentTime/CommonPlayerFunc.shared.audioLength)
        pogressBar.value = normalizedTime
        var startTime = CommonPlayerFunc.shared.currentTime.secToMintasString(style: .positional)
        if startTime.count<=2{
            startTime = "00:00:\(startTime)"
        }else if startTime.count<=4{
            startTime = "00:0\(startTime)"
        }else if startTime.count<=5{
            startTime = "00:\(startTime)"
        }
        lblAudioCurrentPoint.text = startTime
    }
    @objc func notificationPlayerState(notification: Notification) {
        if CommonPlayerFunc.shared.isPlaying{
            btnPlayPause.setImage(#imageLiteral(resourceName: "pauseP-24px"), for: .normal)
        }else{
            btnPlayPause.setImage(#imageLiteral(resourceName: "play_arrow-24px"), for: .normal)
        }
    }
    
    @objc func notificationSetPlayerModel(notification: Notification) {
        DispatchQueue.main.async {
            self.initialLoad()
        }
    }
}
//MARK: PLAYER FUNCTION
extension PlayerVC{
    @IBAction func nextPlay(_ sender: UIButton)-> Void{
        CommonPlayerFunc.shared.playNextLectureFromList()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.initialLoad()
        }
    }
    
    @IBAction func previousPlay(_ sender: UIButton)-> Void{
        CommonPlayerFunc.shared.playPreviousLectureFromList()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.initialLoad()
        }
    }
    @IBAction func addPlaybackSpeedDropDown(_ sender: UIButton)-> Void{
        let dropDown = DropDown()
        dropDown.anchorView = sender
        dropDown.dataSource = playBackSpeed
        dropDown.selectRow(GlobleVAR.speedIndex)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            GlobleVAR.speedIndex = index
            let newRate = Float(item.replacingOccurrences(of: "X", with: ""))!
            CommonPlayerFunc.shared.playWithCustomeSpeed(speed: newRate)
            sender.setTitle(item, for: .normal)
        }
        dropDown.show()
        return
    }
    @IBAction func suffalPlay(_ sender: UIButton)-> Void{
        // 0 off
        // 1 active
        GlobleVAR.isShuffleMode.toggle()
        sender.tintColor = GlobleVAR.isShuffleMode ? AppColors.primaryOring : .white
        
        
    }
    @IBAction func rapetPlay(_ sender: UIButton)-> Void{
        GlobleVAR.isRepeatMode.toggle()
        sender.tintColor = GlobleVAR.isRepeatMode ? AppColors.primaryOring : .white
    }
    
    
    @IBAction func playAndPause(_ sender: UIButton)-> Void{
        NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerState), object: nil)
        if sender.currentImage ==  #imageLiteral(resourceName: "pauseP-24px"){
            CommonPlayerFunc.shared.pause()
            sender.setImage(#imageLiteral(resourceName: "play_arrow-24px"), for: .normal)
        }else{
            CommonPlayerFunc.shared.play()
            sender.setImage(#imageLiteral(resourceName: "pauseP-24px"), for: .normal)
            
        }
    }
    @IBAction func backWordPlay(_ sender: UIButton)-> Void{
        CommonPlayerFunc.shared.currentTime -= 15.0
        if CommonPlayerFunc.shared.currentTime < 0{
            let time2 = CMTimeMake(value: Int64(0.0 * 1000 as Float64), timescale: 1000)
            CommonPlayerFunc.shared.player.seek(to: time2)
            //  CommonPlayerFunc.shared.pause()
        }else{
            let time2 = CMTimeMake(value: Int64(CommonPlayerFunc.shared.currentTime * 1000 as Float64), timescale: 1000)
            CommonPlayerFunc.shared.player.seek(to: time2)
        }
    }
    @IBAction func forwardPaly(_ sender: UIButton)-> Void{
        CommonPlayerFunc.shared.currentTime += 15.0
        if CommonPlayerFunc.shared.currentTime > CommonPlayerFunc.shared.audioLength{
            let time2 = CMTimeMake(value: Int64(CommonPlayerFunc.shared.audioLength * 1000 as Float64), timescale: 1000)
            CommonPlayerFunc.shared.player.seek(to: time2)
            // CommonPlayerFunc.shared.pause()
        }else{
            let time2 = CMTimeMake(value: Int64(CommonPlayerFunc.shared.currentTime * 1000 as Float64), timescale: 1000)
            CommonPlayerFunc.shared.player.seek(to: time2)
        }
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            self.timer.invalidate()
            self.timer.invalidate()
            switch touchEvent.phase {
            case .began:
                self.timer.invalidate()
                
                print("handle drag began")
            case .moved:
                self.timer.invalidate()
                CommonPlayerFunc.shared.currentTime = Double(self.pogressBar.value) * CommonPlayerFunc.shared.audioLength
                var startTime = CommonPlayerFunc.shared.currentTime.secToMintasString(style: .positional)
                if startTime.count<=2{
                    startTime = "00:00:\(startTime)"
                }else if startTime.count<=4{
                    startTime = "00:0\(startTime)"
                }else if startTime.count<=5{
                    startTime = "00:\(startTime)"
                }
                lblAudioCurrentPoint.text = startTime
            case .ended:
                print("handle drag ended")
                let currentTime =  Double(self.pogressBar.value) * CommonPlayerFunc.shared.audioLength
                
                CommonPlayerFunc.shared.playWithCurrent(Possition: currentTime)
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: (#selector(self.trackAudio)), userInfo: nil, repeats: true)
                
            default:
                break
            }
            
        }
        
    }
}
