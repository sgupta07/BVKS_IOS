//
//  VideoView.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 26/11/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import UIKit
import MarqueeLabel
import AVKit
import XCDYouTubeKit
import DropDown
import Alamofire
class VideoView:UIView{
    private var playerLayer : AVPlayerLayer?
    @IBOutlet var contentView: UIView!
    //player outlet
    @IBOutlet weak var imgMainPlayer: UIImageView!
    
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var btnPlayBackSpeed: UIButton!
    @IBOutlet weak var btnShuffle: UIButton!
    @IBOutlet weak var btnRapet: UIButton!
    @IBOutlet weak var btnAudioOnly: UIButton!
    @IBOutlet weak var lblTitle:MarqueeLabel!
    
    //BUFFER OVSERVER START//
    private var playerItemBufferEmptyObserver: NSKeyValueObservation?
    private var playerItemBufferKeepUpObserver: NSKeyValueObservation?
    private var playerItemBufferFullObserver: NSKeyValueObservation?
    @IBOutlet weak var bufferLoader:UIActivityIndicatorView!
    //BUFFER OVSERVER END//
    
    
    //NAVIGATION BUTTON
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var navViewHeight: NSLayoutConstraint!
    @IBOutlet weak var plyerControlsHeight: NSLayoutConstraint!
    
    
    private let playBackSpeed = ["0.25X","0.50X","0.75X","1.0X","1.15X", "1.25X", "1.5X","1.75X", "2.0X"]
    
    
    @IBOutlet weak var pogressBar: UISlider!
    var onDoneBlock : (()->())?
    var updater: CADisplayLink! = nil
    var timer: Timer?{
        willSet{
            guard timer != nil else { return }
            timer?.invalidate()
        }
    }
    var videoUrl : String = ""{
        willSet{
            self.removeBufferOvserver()
            self.pogressBar.value = 0
            self.lblTitle.text = ""
            self.lblEndTime.text = ""
            self.lblStartTime.text = ""
            if GlobleVAR.isFirstPlay || !CommonPlayerFunc.shared.isPlaying{
                btnPlayPause.setImage(#imageLiteral(resourceName: "play_arrow-24px"), for: .normal)
            }else{
                btnPlayPause.setImage(#imageLiteral(resourceName: "pauseP-24px"), for: .normal)
            }
        }
        didSet{
            self.bufferLoader.startAnimating()
            self.pogressBar.value = 0
            self.setNavigationButtonApparance()
            print("videoUrl :",self.videoUrl)
            self.playWithVideoURL()
            
            
        }
    }
    var maxDuartion = Double() {
        didSet{
            self.bufferManagment()
            CommonPlayerFunc.shared.audioLength = maxDuartion
            self.lblTitle.text = GlobleVAR.currentPlay?.title?.joined(separator: " ")
            
            let normalizedTime = Float(CommonPlayerFunc.shared.currentTime/maxDuartion)
            print("Progres bar value ->",normalizedTime)
            pogressBar.value = normalizedTime
            var startTime = CommonPlayerFunc.shared.currentTime.secToMintasString(style: .positional)
            if startTime.count<=2{
                startTime = "00:00:\(startTime)"
            }else if startTime.count<=4{
                startTime = "00:0\(startTime)"
            }else if startTime.count<=5{
                startTime = "00:\(startTime)"
            }
            lblStartTime.text = "\(startTime)"
            
            var endTime = maxDuartion.secToMintasString(style: .positional)
            if endTime.count<=2{
                endTime = "00:00:\(endTime)"
            }else if endTime.count<=4{
                endTime = "00:0\(endTime)"
            }else if endTime.count<=5{
                endTime = "00:\(endTime)"
            }
            lblEndTime.text = endTime
            
            
            //self.pogressBar.value = Float(maxDuartion/CommonPlayerFunc.shared.currentTime)
        }
    }
    let kCONTENT_XIB_NAME = "VideoView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        self.contentView.addShadow()
        self.pogressBar.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        
    }
    
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        setrapetSuffalApparance()
        self.contentView.bringSubviewToFront(self.bufferLoader)
    }
    
    private func setPlayerTimer(){
        if CommonPlayerFunc.shared.isPlaying{
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: (#selector(self.trackAudio)), userInfo: nil, repeats: true)
        }else{
            timer = nil
        }
    }
    
    private func setrapetSuffalApparance(){
        pogressBar[thumImage: .normal] = #imageLiteral(resourceName: "slider_thumb").resize(to: .init(width: 15, height: 15))
        pogressBar[thumImage: .selected] = #imageLiteral(resourceName: "slider_thumb").resize(to: .init(width: 15, height: 15))
        self.btnRapet.tintColor = GlobleVAR.isRepeatMode == true ? AppColors.primaryOring :.white
        self.btnShuffle.tintColor = GlobleVAR.isShuffleMode == true ? AppColors.primaryOring :.white
    }
    
    private func setNavigationButtonApparance(){
        self.btnPlayBackSpeed.setTitle(playBackSpeed[GlobleVAR.speedIndex], for: .normal)
        
        if GlobleVAR.currentPlay?.info?.isDownloded == true{
            // self.btnDownload.setImage(#imageLiteral(resourceName: "ic_download_done"), for: .normal)
            let localData =  CommonFunc.shared.isFileinLocaleDB(lectureRaw: GlobleVAR.currentPlay!)
            if localData.status == true{
                self.btnDownload.setImage(#imageLiteral(resourceName: "oringDownload"), for: .normal)
            }else{
                self.btnDownload.setImage(#imageLiteral(resourceName: "oringalerts"), for: .normal)
            }
        }else{
            self.btnDownload.setImage(#imageLiteral(resourceName: "ic_download"), for: .normal)
        }
        if GlobleVAR.currentPlay?.info?.isFavourite == true{
            self.btnFavorite.setImage(#imageLiteral(resourceName: "star-1"), for: .normal)
        }else{
            self.btnFavorite.setImage(#imageLiteral(resourceName: "favoriteTab"), for: .normal)
        }
    }
    
    
}

//MARK:- NAVIGATIONBAR BUTTON ACTIONS
extension VideoView {
    @IBAction func AddToPlayLis(_ sender:UIButton){
        if let lect = GlobleVAR.currentPlay {
            PlayList.addToPlayListAlert(lect: lect)
        }else{
            print("lecture is not available ")
        }
    }
    @IBAction func moveToAudioOnly(_ sender:UIButton){
        timer = nil
        guard let lect = GlobleVAR.currentPlay else{return}
        GlobleVAR.mustAudio = true
        NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerModel), object: ["playerModel":lect])
        
    }
    
    @IBAction func AddToFavourites(_ sender:UIButton){
        // #imageLiteral(resourceName: "ic_download_done")
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
    @IBAction func makeDownLoad(_ sender:UIButton){
        guard sender.currentImage != #imageLiteral(resourceName: "oringDownload") else{return}
        guard let lecture =  GlobleVAR.currentPlay else{return}
        sender.setImage(UIImage.gif(name: "blueLoader"), for: .normal)
        CommonFunc.shared.saveAudioFileLocalDB(with:lecture, competion: {[unowned self] (downloading,proLecture)  in
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
    @IBAction func sharewithFriends(_ sender:UIButton){
        if let lect = GlobleVAR.currentPlay {
            UnivarsalLinkHandler.shared.shareLecture(lecture: lect)
        }else{
            print("lecture is not available ")
        }
    }
    
    @IBAction func expandAndCollapsa(_ sender:UIButton){
        if let vc = CommonFunc.shared.currentController{
            if sender.isSelected == false{
                // make big
                //EXPANDED VIEW
                UIView.animate(withDuration: 0.5, delay: 0,  options: .curveEaseIn, animations: {
                    //THIS BLOCK FOR EXPAND VIDEO ON LANDESCAP MODE
                    //self.navViewHeight.constant = 0.0
                    // self.plyerControlsHeight.constant = 0.0
                    // self.chnageViewOriantation(currentAnimation: 2)
                    
                    self.frame = vc.view.frame
                    self.center = vc.view.center
                    self.btnAudioOnly.isHidden = true
                    
                }){_ in
                    sender.isSelected = true
                    self.updatePlayerSize()
                    
                }
            }else{
                //MINI VIDEO VIEW
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    //THIS BLOCK PUSH BACK EXPANDED LANDESCAPE TO MINI VIDEO VIEW
                    //self.navViewHeight.constant = 80.0
                    //self.plyerControlsHeight.constant = 80.0
                    //self.chnageViewOriantation(currentAnimation: 4)
                    
                    self.btnAudioOnly.isHidden = false
                    let yaxes = GlobleVAR.bottomSafeAreaHeight+350
                    
                    
                    let tabFream = UITabBarController().tabBar.frame
                    self.frame = CGRect(x: 0.0, y: tabFream.minY-yaxes, width: tabFream.width, height: 350.0)

                   
                    
                }){_ in
                    sender.isSelected = false
                    self.updatePlayerSize()
                    
                    
                }
                
            }
        }
    }
    
    
    
}
//MARK: VIDEO PLAYER OBSERVER
extension VideoView{
    private func removeBufferOvserver(){
        playerItemBufferEmptyObserver?.invalidate()
        playerItemBufferEmptyObserver = nil
        
        playerItemBufferKeepUpObserver?.invalidate()
        playerItemBufferKeepUpObserver = nil
        
        playerItemBufferFullObserver?.invalidate()
        playerItemBufferFullObserver = nil
    }
    
    private func bufferManagment(){
        
        playerItemBufferEmptyObserver = CommonPlayerFunc.shared.player.currentItem?.observe(\AVPlayerItem.isPlaybackBufferEmpty, options: [.new]) { [weak self] (_, _) in
            guard let self = self else { return }
            self.bufferLoader.startAnimating()
            print("++++++++++++++++VEDIO IS LOADING ++++++++++++++")
            
        }
        
        playerItemBufferKeepUpObserver = CommonPlayerFunc.shared.player.currentItem?.observe(\AVPlayerItem.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] (_, _) in
            guard let self = self else { return }
            self.bufferLoader.stopAnimating()
            print("-------------End Video Loading---------------")
        }
        
        playerItemBufferFullObserver = CommonPlayerFunc.shared.player.currentItem?.observe(\AVPlayerItem.isPlaybackBufferFull, options: [.new]) { [weak self] (_, _) in
            guard let self = self else { return }
            self.bufferLoader.stopAnimating()
        }
    }
    
    @objc func trackAudio() {
        guard CommonPlayerFunc.shared.isPlaying else{return}
        guard UIApplication.shared.applicationState != .background && UIApplication.shared.applicationState != .inactive && pogressBar.isContinuous else{ return }
        let normalizedTime = Float(CommonPlayerFunc.shared.currentTime/maxDuartion)
        print("Progres bar value for video ->",normalizedTime)
        pogressBar.value = normalizedTime
        var startTime = CommonPlayerFunc.shared.currentTime.secToMintasString(style: .positional)
        if startTime.count<=2{
            startTime = "00:00:\(startTime)"
        }else if startTime.count<=4{
            startTime = "00:0\(startTime)"
        }else if startTime.count<=5{
            startTime = "00:\(startTime)"
        }
        lblStartTime.text = "\(startTime)"
        
    }
}

//MARK: VIDEO PLAYER BOTTOM FUNCTION
extension VideoView{
    
    private func playWithVideoURL(){
        
        
        func playVideo(with Id: String) {
            
            XCDYouTubeClient.default().getVideoWithIdentifier(Id) { (video: XCDYouTubeVideo?, error: Error?) in
                
                var videoStrem : URL? = nil
                if let streamURL = video?.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] {
                    print("*URL RECIVED small240*")
                    
                    videoStrem = streamURL
                }else if let streamURL = video?.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue]{
                    print("*URL RECIVED medium360*")
                    videoStrem = streamURL
                }else if let streamURL = video?.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue]{
                    print("*URL RECIVED HD720*")
                    videoStrem = streamURL
                }
                else if let e = error{
                    print(error?.localizedDescription)
                    UIApplication.getTopViewController()?.popupAlert(title: "YouTub Link Failer ", message: e.localizedDescription, actionTitles: ["Play Audio"], actions: [{action in
                        //                        self.btnAudioOnly.actions(forTarget: self, forControlEvent: .touchUpInside)
                        self.moveToAudioOnly(self.btnAudioOnly)
                        }])
                    return
                }else{
                    print("video is not Avilabel")
                    return
                }
                if let playerLayer = CommonPlayerFunc.shared.playWith(VideoUrl: videoStrem!.absoluteString){
                    
                    if let currentPlay = GlobleVAR.currentPlay?.info?.lastPlayedPoint, currentPlay > 0,!GlobleVAR.isRepeatMode{
                        CommonPlayerFunc.shared.playWithCurrent(Possition: Double(currentPlay))
                    }else{
                        CommonPlayerFunc.shared.play()
                    }
                    if let duration = video?.duration{
                        self.maxDuartion = duration
                    }else{
                        self.maxDuartion = 0
                    }
                    self.playerLayer?.removeFromSuperlayer()
                    self.playerLayer = playerLayer
                    self.updatePlayerSize()
                    self.imgMainPlayer.layer.addSublayer(playerLayer)
                    self.setPlayerTimer()
                }
                
                
            }
        }
        var youtubVID = ""
        if self.videoUrl.contains("="){
            guard let vid = self.videoUrl.split(separator: "=").last else { return }
            youtubVID = String(vid)
        }else{
            guard let vid = self.videoUrl.split(separator: "/").last else { return }
            youtubVID = String(vid)
            
        }
        print("youtubVID:",youtubVID)
        playVideo(with: youtubVID)
    }
    func updatePlayerSize(){
            self.playerLayer?.frame = self.imgMainPlayer.bounds
            self.playerLayer?.videoGravity = .resizeAspect
    }
    
    @IBAction func suffalPlay(_ sender: UIButton)-> Void{
        // 0 off
        // 1 active
        GlobleVAR.isShuffleMode.toggle()
        sender.tintColor = GlobleVAR.isShuffleMode == false ? .white : AppColors.primaryOring
        
    }
    @IBAction func rapetPlay(_ sender: UIButton)-> Void{
        GlobleVAR.isRepeatMode.toggle()
        sender.tintColor = GlobleVAR.isRepeatMode == false ? .white : AppColors.primaryOring
    }
    @IBAction func nextPlay(_ sender: UIButton)-> Void{
        
        CommonPlayerFunc.shared.playNextLectureFromList()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            if let url = GlobleVAR.currentPlay?.resources?.videos?.first?.url{
                self.videoUrl = url
            }
        }
    }
    
    @IBAction func previousPlay(_ sender: UIButton)-> Void{
        CommonPlayerFunc.shared.playPreviousLectureFromList()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            if let url = GlobleVAR.currentPlay?.resources?.videos?.first?.url{
                self.videoUrl = url
            }
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
    }
    
    
    
    @IBAction func playAndPause(_ sender: UIButton)-> Void{
        if sender.currentImage ==  #imageLiteral(resourceName: "pauseP-24px"){
            
            CommonPlayerFunc.shared.pause()
            
        }else{
            
            CommonPlayerFunc.shared.play()
        }
        NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerState), object: nil)
        self.setPlayerTimer()
        
        
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
            self.timer = nil
            switch touchEvent.phase {
            case .began:
                print("handle drag began")
            case .moved:
                CommonPlayerFunc.shared.currentTime = Double(self.pogressBar.value) * self.maxDuartion
                var startTime = CommonPlayerFunc.shared.currentTime.secToMintasString(style: .positional)
                if startTime.count<=2{
                    startTime = "00:00:\(startTime)"
                }else if startTime.count<=4{
                    startTime = "00:0\(startTime)"
                }else if startTime.count<=5{
                    startTime = "00:\(startTime)"
                }
                lblStartTime.text = "\(startTime)"
            case .ended:
                print("handle drag ended")
                let currentTime =  Double(self.pogressBar.value) * self.maxDuartion
                CommonPlayerFunc.shared.playWithCurrent(Possition: currentTime)
                self.setPlayerTimer()
                
            default:
                break
            }
        }
    }
    
    
    func chnageViewOriantation(currentAnimation : Int = 0){
        switch currentAnimation {
        case 0:
            self.transform = CGAffineTransform(scaleX: 2, y: 2)
        case 1:
            self.transform = CGAffineTransform(translationX: -256, y: -256)
        case 2:
            self.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        case 3:
            self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        case 4:
            self.transform = .identity
        default:
            break
        }
        
        //        switch currentAnimation {
        //        case 0:
        //            self.imgMainPlayer.transform = CGAffineTransform(scaleX: 2, y: 2)
        //        case 1:
        //            self.imgMainPlayer.transform = CGAffineTransform(translationX: -256, y: -256)
        //        case 2:
        //            self.imgMainPlayer.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        //        case 3:
        //            self.imgMainPlayer.transform = .identity
        //        default:
        //            break
        //        }
    }
}
