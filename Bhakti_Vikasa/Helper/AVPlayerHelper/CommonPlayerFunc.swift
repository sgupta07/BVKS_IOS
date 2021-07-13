//
//  CommonPlayerFunc.swift
//  Bhakti_Vikasa
//
//  Created by MAC on 15/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import  Toaster

class CommonPlayerFunc : NSObject{
    static let shared = CommonPlayerFunc()
    private override init() {
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    var player : AVPlayer = AVPlayer()
    
    var audioLength = 0.00
    var isPlaying = false
    var currentTime = Double()
    var timer: Timer? = nil{
        willSet{
            guard timer != nil else { return }
            timer?.invalidate()
        }
    }
    var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
    //["0.25X","0.50X","0.75X","1.0X","1.15X", "1.25X", "1.5X","1.75X", "2.0X"]
    private let playBackSpeed : [Float] = [0.25,0.50,0.75,1.0,1.15,1.25, 1.5,1.75, 2.0]
    private var endOfplayItem = 0
    
    func setInitialPlayer(){
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, options: [])
            // try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay,.allowBluetooth])
            try audioSession.setActive(true)
            self.setupNotifications()
            self.setupRemoteTransportControls()
        } catch let error as NSError {
            print("Setting category to AVAudioSessionCategoryPlayback failed: \(error)")
        }
    }
    
    
    func setUpPlayer(PlaybackUrl: String) {
        
        var webUrl : String = ""
        if let urlDecoder = PlaybackUrl.decodeUrl(){
            webUrl = urlDecoder.encodeUrl() ?? ""
        }else{
            webUrl = PlaybackUrl
        }
        if let fileUrl = URL(string: webUrl){
            player = AVPlayer(playerItem: AVPlayerItem(url: fileUrl))
            player.automaticallyWaitsToMinimizeStalling = false
            if GlobleVAR.isFirstPlay{
                self.pause()
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    GlobleVAR.isFirstPlay = false
                }
            }else{
                isPlaying = true
                timer = nil
                self.play()
            }
        }
    }
    
    func setUpPlayerWithLocalUrl(PlaybackUrl: String) {
        let localFilePath =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path + "/\(URL(fileURLWithPath:PlaybackUrl).lastPathComponent)"
        
        player = AVPlayer(url:URL(fileURLWithPath:localFilePath))
        player.volume = 0.5
        if GlobleVAR.isFirstPlay{
            self.pause()
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                GlobleVAR.isFirstPlay = false
                
            }
        }else{
            isPlaying = true
            timer = nil
            self.play()
        }
    }
    func playWithCustomeSpeed(speed:Float){
        player.playImmediately(atRate: speed)
        if self.isPlaying == false {
            player.pause()
        }
        
    }
    func playWith(VideoUrl:String)->AVPlayerLayer?{
        var webUrl : String = ""
        if let urlDecoder = VideoUrl.decodeUrl(){
            webUrl = urlDecoder.encodeUrl() ?? ""
        }else{
            webUrl = VideoUrl
        }
        if let fileUrl = URL(string: webUrl){
            player = AVPlayer(url: fileUrl)
            player.automaticallyWaitsToMinimizeStalling = false
            let playerLayer = AVPlayerLayer(player: player)
            
            if GlobleVAR.isFirstPlay{
                self.pause()
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    GlobleVAR.isFirstPlay = false
                    
                }
            }else{
                isPlaying = true
                timer = nil
                self.play()
            }
            
            
            
            return playerLayer
        }
        return nil
        
    }
    
    
    
    
    
    fileprivate var saveDefult = 0
    @objc func updateTimer() {
        print("updateTimer common player Time TTTTTTTTT:",saveDefult)
        if isPlaying == false{
            timer = nil
        }
        if let time = player.currentItem?.currentTime(){
            currentTime = CMTimeGetSeconds(time)
            // readyToPlay = true
        }
        guard GlobleVAR.currentPlay?.id != nil && currentTime != 0 else {
            return
        }
        guard saveDefult == 10  else {
            saveDefult += 1
            return
        }
        self.saveCurrentPlayPoint()
        
    }
    
    //SAVE Currrent palyed poin in UserDefault and FireStore
    func saveCurrentPlayPoint(){
        let lTime = GlobleVAR.currentPlay?.info?.lastModifiedTimestamp ?? 0
        guard let clect = GlobleVAR.currentPlay, !GlobleVAR.isFirstPlay, lTime+5000  < c_Time else {
            return
        }
        let currentDic = ["ID":clect.id!,
                          "timePlay":currentTime ,
                          "creationTimestamp":clect.creationTimestamp!] as [String : Any]
        
        UserDefaults.standard.set(currentDic, forKey: "lastPlay")
        guard self.currentTime > 0 else {
            return
        }
        print("*SAVE LASTPLAY TIME*")
        print("*SAVE LASTPLAY TIME FOR LECTUER ID*",clect.id)
        LectureInfo.getCurrentSnapshot(with: clect.id!) { (lInfo) in
            var currentInfo = LectureInfo()
            if let info = lInfo {
                guard !(info.isCompleted ?? false)  else {return}
                currentInfo = info
                currentInfo.lastModifiedTimestamp = c_Time
                currentInfo.lastPlayedPoint = Int(self.currentTime)
                currentInfo.totallength = Int(self.audioLength)
                LectureInfo.setLectureInfo(with: currentInfo, isNew: false)
            }else{
                currentInfo.id = GlobleVAR.currentPlay?.id
                currentInfo.totallength = Int(self.audioLength)
                currentInfo.lastPlayedPoint = Int(self.currentTime)
                LectureInfo.setLectureInfo(with: currentInfo, isNew: true)
            }
        }
        
        if currentTime > 0 && !GlobleVAR.isFirstPlay && saveDefult > 0{
            ListenRecord.updateUserListeningOnFireStore(with: saveDefult)
            saveDefult = 0
        }
    }
}

//MARK:PLAYER BASIC FUNCTIONS
extension CommonPlayerFunc{
    func playWithCurrent(Possition: Double){
        currentTime = Possition
        let time2 = CMTimeMake(value: Int64(currentTime * 1000 as Float64), timescale: 1000)
        player.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)//.seek(to: time2)
        guard isPlaying else{
            return}
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.updateNowPlaying()
        }
    }
    
    func play() {
        timer = nil
        player.play()
        player.playImmediately(atRate: playBackSpeed[GlobleVAR.speedIndex])
        timer = nil
        print("Play - current time: \(String(describing: player.currentTime)) - is playing: \(self.player.rate)")
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
        isPlaying = true
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.updateNowPlaying()
            
        }
    }
    func pause() {
        guard isPlaying else {return}
        timer = nil
        player.pause()
        print("Pause - current time: \(String(describing: player.currentTime)) - is playing: \(self.player.rate)")
        currentTime = CMTimeGetSeconds((player.currentItem?.currentTime() ?? CMTime()))
        isPlaying = false
        self.updateNowPlaying()
    }
    func playNextLectureFromList(){
        var lect : Lecture? = nil
        var wantToplayIndex = GlobleVAR.currentIndex
        
        if GlobleVAR.isRepeatMode{
            lect = GlobleVAR.currentPlay
        }else if GlobleVAR.isShuffleMode{
            let randomIndex = Int.random(in: 0..<GlobleDB.rawPalyable.count)
            wantToplayIndex =  randomIndex
            lect = GlobleDB.rawPalyable[randomIndex]
        }else{
            
            wantToplayIndex =  GlobleVAR.currentIndex + 1
            if GlobleDB.rawPalyable.count >= wantToplayIndex+1 {
                lect = GlobleDB.rawPalyable[wantToplayIndex]
            }else{
                self.toastlastLectur(isValue: 1)
                return
            }
            
        }
        guard lect != nil else {return}
        GlobleVAR.currentIndex = wantToplayIndex
        NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerModel), object: ["playerModel":lect])
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.endOfplayItem = 0
        }
        
    }
    func playPreviousLectureFromList(){
        let wantToplayIndex =  GlobleVAR.currentIndex - 1
        guard wantToplayIndex >= 0 else {
            self.toastlastLectur(isValue: 0)
            return
        }
        var lect = Lecture()
        if GlobleDB.rawPalyable.count > 0{
            lect = GlobleDB.rawPalyable[wantToplayIndex]
            
        }else{
            self.toastlastLectur(isValue: 0)
            return
        }
        
        NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerModel), object: ["playerModel":lect])
        
        
    }
    private func toastlastLectur(isValue:Int)
    {
        if isValue == 1{//next
            Toast(text: "We are at last Lecture in list, Next Lecture is not Available").show()
        }else if isValue == 0{//back
            Toast(text: "We are at Top Lecture in list, Previous Lecture is not Available").show()
            
        }
    }
}
//MARK: PLAYER NOTIFICATION CENTER
extension CommonPlayerFunc{
    private func setupNotifications() {
        NotificationCenter.default.removeObserver(self)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleInterruption),
                                       name: AVAudioSession.interruptionNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(handleRouteChange),
                                       name: AVAudioSession.routeChangeNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(handleEndofItem),
                                       name: .AVPlayerItemDidPlayToEndTime,
                                       object: nil)
        
    }
    
    private func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.togglePlayPauseCommand.addTarget{ [unowned self] event in
            print("Play command - 'togglePlayPauseCommand' ")
            if self.player.rate != 0 {
                self.pause()
            }else{
                self.play()
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerState), object: nil)
            }
            return .success
            
        }
        
        
        
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self](remoteEvent) -> MPRemoteCommandHandlerStatus in
            print("Play command - 'changePlaybackPositionCommand'")
            guard let self = self else {return .commandFailed}
            let playerRate = self.player.rate
            if let event = remoteEvent as? MPChangePlaybackPositionCommandEvent {
                self.player.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(1000)), completionHandler: { [weak self](success) in
                    guard let self = self else {return}
                    if success {
                        self.player.rate = playerRate
                        if self.isPlaying{
                            self.play()
                        }else{
                            self.pause()
                        }
                    }
                })
                return .success
            }
            return .commandFailed
        }
        
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            print("Play command - 'playCommand' ")
            if self.player.rate == 0 {
                self.play()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerState), object: nil)
                }
                return .success
            }
            return .commandFailed
        }
        
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            print("Pause command - 'pauseCommand' ")
            if self.player.rate != 0 {
                self.pause()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerState), object: nil)
                }
                return .success
            }
            return .commandFailed
        }
        
        
        commandCenter.previousTrackCommand.addTarget{[unowned self] event in
            print("Play command - 'previousTrackCommand' ")
            
            self.playPreviousLectureFromList()
            return .success
            
        }
        
        commandCenter.nextTrackCommand.addTarget{ [unowned self] event in
            print("Play command - 'nextTrackCommand' ")
            
            self.playNextLectureFromList()
            return .success
            
        }
    }
    
    
    func setupNowPlaying(lecture:Lecture,playerIcon:UIImage) {
        // Define Now Playing Info
        
        
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Bhakti Vikasa Swami"
        nowPlayingInfo[MPMediaItemPropertyArtist] = lecture.title?.joined(separator: " ")
        
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: playerIcon.size) { size in
            return playerIcon
        }
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentItem?.currentTime().seconds
        
        // Set the metadata
        self.nowPlayingInfo = nowPlayingInfo
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
    }
    
    
    private func updateNowPlaying() {
        // Define Now Playing Info
        if  let currentItem = self.player.currentItem {
            
            self.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(currentItem.currentTime())
            self.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = currentItem.asset.duration.seconds
            self.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
            self.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentItem?.currentTime().seconds
        }
        // Set the metadata
        self.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1 : 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
        
        //Save current possitionn
        self.saveCurrentPlayPoint()
    }
    
    
    // MARK: Handle Notifications
    @objc func handleEndofItem(notification: Notification){
        print("==========LECTUER ENDED===========")
        if self.endOfplayItem == 0{
            self.endOfplayItem += 1
            guard self.isPlaying else {return}
            guard let lect = GlobleVAR.currentPlay else{return}
            LectureInfo.makeLactureCompleted(lecture: lect, isComplet: true)
            self.playNextLectureFromList()
            if GlobleVAR.isRepeatMode{
                self.play()
            }
            
        }
    }
    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                return
        }
        switch reason {
        case .newDeviceAvailable:
            let session = AVAudioSession.sharedInstance()
            for output in session.currentRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                print("headphones connected")
                DispatchQueue.main.sync {
                    self.play()
                }
                break
            }
        case .oldDeviceUnavailable:
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                    print("headphones disconnected")
                    DispatchQueue.main.sync {
                        self.pause()
                    }
                    break
                }
            }
        default: ()
        }
    }
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        
        if type == .began {
            print("Interruption began")
            // Interruption began, take appropriate actions
        }
        else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Interruption Ended - playback should resume
                    print("Interruption Ended - playback should resume")
                    play()
                } else {
                    // Interruption Ended - playback should NOT resume
                    print("Interruption Ended - playback should NOT resume")
                }
            }
        }
    }
    
}
