//
//  V2lectureCell.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 30/11/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
import  DropDown
import Kingfisher
import MBCircularProgressBar
import FirebaseAuth
var inProsess : [Int] = []
class V2lectureCell: UITableViewCell {
    
    
    
    var section : LType = .home
    
    @IBOutlet private weak var downloadSheadView: UIView!
    
    @IBOutlet private weak var lblTitle: UILabel!
    @IBOutlet private weak var lblTime: UILabel!
    @IBOutlet private weak var lblLocation: UILabel!
    @IBOutlet private weak var lblDate: UILabel!
    @IBOutlet private weak var imgThumbnial: UIImageView!
    @IBOutlet private weak var btnIsFav: UIButton!
    @IBOutlet private weak var btnIsDownloaded: UIButton!
    @IBOutlet private weak var listenProgress: MBCircularProgressBarView!
    @IBOutlet private weak var downloadProgress: MBCircularProgressBarView!
    @IBOutlet private weak var btnDot: UIButton!
    @IBOutlet private weak var btnIsComplet: UIButton!
    @IBOutlet  weak var category:UILabel!
    
    
    var playList : PlayList? = nil{
        didSet{
            guard playList  != nil else { return }
            guard lecture == nil else{ return }
            self.listenProgress.isHidden = true
            self.btnIsFav.isHidden = true
            self.btnIsDownloaded.isHidden = true
            self.lblTitle.text = playList?.title
            self.category.text = playList?.lecturesCategory ?? ""
            
            if Auth.auth().currentUser?.email ?? "" == playList?.authorEmail{
                self.btnDot.isHidden = false
                self.btnDot.tag = self.tag
                self.btnDot.addTarget(self, action: #selector(dortActionForPlaylist(_:)), for: .touchUpInside)
                
            }else{
                self.btnDot.isHidden = true
                self.downloadProgress.isHidden = true
                self.downloadSheadView.isHidden = true
                
            }
            let createdTime = "•" + "\(String(describing: playList!.creationTime!.getDateStringFromUnixTime(dateStyle: .short, timeStyle: .none)))"
            self.lblTime.text = createdTime
            self.lblLocation.text = "Lectures :\(playList?.lectureCount ?? 0),"
            
            self.lblDate.text = self.playList?.authorEmail
            let url = URL(string: self.playList?.thumbnail ?? "")
            self.imgThumbnial.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "bvks_thumbnail"))
            self.downloadSheadView.isHidden = true
        }
    }
    
    
    var lecture : Lecture? = nil {
        didSet{
            let info = lecture?.info
            if info?.isDownloded == true{
           // if info?.isDownloded == true, GlobleVAR.currentPlay?.id != lecture?.id{
                let localData =  CommonFunc.shared.isFileinLocaleDB(lectureRaw: self.lecture!)
                if localData.status == true{
                    self.btnIsDownloaded.setImage(#imageLiteral(resourceName: "oringDownload"), for: .normal)
                }else{
                    self.btnIsDownloaded.setImage(#imageLiteral(resourceName: "oringalerts"), for: .normal)
                }
                self.btnIsDownloaded.isHidden = false
                self.contentView.bringSubviewToFront(self.btnIsDownloaded)
            }else{
                self.btnIsDownloaded.isHidden = true
            }
            
            
            if info?.isFavourite == true{
                self.btnIsFav.isHidden = false
            }else{
                self.btnIsFav.isHidden = true
            }
            self.tag = lecture?.id ?? 0
            self.btnDot.tag = self.tag
            var  duration =  Double(lecture?.length ?? 0).secToMintasString(style: .positional)
            if duration.count<=2{
                duration = "• 00:00:\(duration)"
            }else if duration.count<=4{
                duration = "• 00:0\(duration)"
            }else if duration.count<=5{
                duration = "• 00:\(duration)"
            }else{
                duration = "• \(duration)"
            }
            self.lblTime.text = duration
            let location = (lecture?.place?.randomElement() ?? "")
            self.lblLocation.text = location
            self.lblTitle.text = lecture?.title?.joined(separator: " ")
            let time = " \(lecture?.dateOfRecording?.day ?? "")/\(lecture?.dateOfRecording?.month ?? "")/\(lecture?.dateOfRecording?.year ?? "")"
            self.lblDate.text = "•" + time
            self.category.text = lecture?.legacyData?.verse ?? ""
            if GlobleVAR.currentPlay?.id == lecture?.id && section == GlobleVAR.selectedTab{
                if CommonPlayerFunc.shared.isPlaying{
                    self.imgThumbnial.image = UIImage.gif(name: "music")
                }else{
                    self.imgThumbnial.image = #imageLiteral(resourceName: "stilMusic")
                }
            }else{
                let url = URL(string: self.lecture?.thumbnail ?? "")
                self.imgThumbnial.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "bvks_thumbnail"))
            }
            if section == .topLacture{
                category.text = "Total play(s): \(String(describing: lecture?.globlePlayCount ?? 0))"
            }
            
            
            self.btnDot.addTarget(self, action: #selector(dortActionForLecture(_:)), for: .touchUpInside)
            if info?.isCompleted != true{
                btnIsComplet.isHidden = true
                listenProgress.isHidden = false
                if let lastPoint = info?.lastPlayedPoint, let finalPoint = self.lecture?.info?.totallength, lastPoint > 0 , finalPoint > 0
                {
                    let fileProgreass = CGFloat((lastPoint*100)/finalPoint)
                    print(">>>",fileProgreass)
                    
                    print("last",lastPoint)
                    print("finalPoint",finalPoint)
                    self.listenProgress.value  = fileProgreass
                    
                }else{
                    self.listenProgress.value = 0.0
                }
            }else{
                btnIsComplet.isHidden = false
                listenProgress.isHidden = true
            }
//            if inProsess.contains(lecture!.id ?? 0){
//                downloadSheadView.isHidden = false
//                downloadProgress.isHidden = false
//                btnDot.isHidden = true
//            }else{
//                downloadSheadView.isHidden = true
//                downloadProgress.isHidden = true
//                btnDot.isHidden = false
//
//            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func reDownloadActio(sender: UIButton){
        guard self.btnIsDownloaded.currentImage != #imageLiteral(resourceName: "oringDownload") else{return}
        guard let lect = self.lecture else {return}
        self.handelDropDownSelectAction(selctedAction: .download,selectedLect: lect)
    }
    
}
//MARK:- Cell Actions
extension V2lectureCell{
    
    private func handelDropDownSelectAction(selctedAction:LecturteDropdown,selectedLect:Lecture){
        print("handelDropDownSelectAction --------->",self.lblTitle.text)
        var rawInfo = LectureInfo()
        switch selctedAction {
        case .download:
            print(">>>>>DOWNLOADS")
            DispatchQueue.main.async {
                inProsess.append(selectedLect.id ?? 0)
                self.downloadProgress.isHidden = false
                self.downloadSheadView.isHidden = false
                self.btnDot.isHidden = true
                CommonFunc.shared.saveAudioFileLocalDB(with: self.lecture!, competion: {[unowned self] (downloading,proLecture)  in
                    if let progress = downloading{
                        if progress < 100.0{
                            self.downloadProgress.value = CGFloat(progress)
                        }else{
                            self.downloadProgress.isHidden = true
                            self.downloadSheadView.isHidden = true
                            inProsess.removeAll(where: {$0 == proLecture.id})
                            self.btnDot.isHidden = false
                            self.reloadInputViews()
                        }
                    }else{
                        self.downloadProgress.isHidden = true
                        self.downloadSheadView.isHidden = true
                        inProsess.removeAll(where: {$0 == proLecture.id})
                        self.btnDot.isHidden = false
                        self.reloadInputViews()
                    }
                    
                })
            }
            // QLightHendler.shared.makeLectureFavourite(lecture: lecture!)
            
        case .unfavorites,.favorites:
            
            LectureInfo.getCurrentSnapshot(with: selectedLect.id!) { (lInfo) in
                if let nInfo = lInfo{
                    rawInfo = nInfo
                    rawInfo.isFavourite = selctedAction == .favorites ? true : false
                    rawInfo.lastModifiedTimestamp = c_Time
                    rawInfo.favouritePlace = 0
                    LectureInfo.setLectureInfo(with: rawInfo, isNew: false)
                }else{
                    rawInfo.favouritePlace = 0
                    rawInfo.isFavourite = selctedAction == .favorites ? true : false
                    rawInfo.id = selectedLect.id
                    rawInfo.lastModifiedTimestamp = c_Time
                    LectureInfo.setLectureInfo(with: rawInfo,isNew: true)
                }
            }

        case .delete:
            print(">>>>>delete")
            if let info = selectedLect.info{
                var updateInfo = info
                updateInfo.isDownloded = false
                LectureInfo.setLectureInfo(with: updateInfo ,isNew: false)
            }else{
                print("lecture INFO is not available ")
                
            }
        case .addToPlaylist:
            PlayList.addToPlayListAlert(lect: selectedLect)
        case .completed:
            LectureInfo.makeLactureCompleted(lecture: selectedLect,isComplet: true)
        case .share:
            print(">>>>share")
            UnivarsalLinkHandler.shared.shareLecture(lecture: selectedLect)
        case .create_playlist:
            print(">>>>>create_playlist not requerd at now")
        case .reset:
            LectureInfo.makeLactureCompleted(lecture: selectedLect,isComplet: false)
        case .removeFormPlaylist:
            print("removeFormPlaylist")
            guard let lId = lecture?.id else{return}
             guard let plist = playList else{return}
            playList?.updatePlaylist(with: plist, lectID:lId , addtolist: false)
        case .unknow:
            print(">>>>>unknow")
        default:break
        }
        
    }
    
    @objc func dortActionForPlaylist(_ sender : UIButton){
        var menuOption:[String] = [LecturteDropdown.deletePlaylist.raw]
        let dropDown = DropDown()
        dropDown.anchorView = sender
        dropDown.dataSource = menuOption
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            PlayList.deletePlaylist(with: self.playList!)
        }
        dropDown.show()
    }
    
    @objc func dortActionForLecture(_ sender : UIButton){
        
        if let selectedLecture = GlobleDB.rawGloble.first(where: {$0.id == sender.tag}){
            var menuOption:[String] = []
            if selectedLecture.info?.isDownloded ?? false{
                menuOption.append(LecturteDropdown.delete.raw)
            }else{
                menuOption.append(LecturteDropdown.download.raw)
            }
            if selectedLecture.info?.isFavourite ?? false{
                menuOption.append(LecturteDropdown.unfavorites.raw)
            }else{
                menuOption.append(LecturteDropdown.favorites.raw)
            }
            menuOption.append(LecturteDropdown.addToPlaylist.raw)
            if selectedLecture.info?.isCompleted ?? false{
                menuOption.append(LecturteDropdown.reset.raw)
            }else{
                menuOption.append(LecturteDropdown.completed.raw)
            }
            //THIS CASE IS ONLY FOR PLAYLIST LECTURES
            if playList?.authorEmail == Auth.auth().currentUser?.email ?? "" && section == .selectedList{
                 menuOption.append(LecturteDropdown.removeFormPlaylist.raw)
            }
            menuOption.append(LecturteDropdown.share.raw)
            let dropDown = DropDown()
            dropDown.anchorView = sender
            dropDown.dataSource = menuOption
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                guard let action  = LecturteDropdown.initialize(stringValue: item) else{ return };                    self.handelDropDownSelectAction(selctedAction: action,selectedLect: selectedLecture)
            }
            dropDown.show()
        }else{
            print("Lecture Not available")
        }
    }
    @IBAction func unFavouritesAction(_ sender:UIButton){
        guard let lect = lecture else {
            return
        }
        var rawInfo = LectureInfo()
        LectureInfo.getCurrentSnapshot(with: lect.id!) { (lInfo) in
            if let nInfo = lInfo{
                rawInfo = nInfo
                rawInfo.isFavourite =  false
                rawInfo.lastModifiedTimestamp = c_Time
                rawInfo.favouritePlace = 0
                LectureInfo.setLectureInfo(with: rawInfo, isNew: false)
            }else{
                rawInfo.favouritePlace = 0
                rawInfo.isFavourite =  false
                rawInfo.id = lect.id
                rawInfo.lastModifiedTimestamp = c_Time
                LectureInfo.setLectureInfo(with: rawInfo,isNew: true)
            }
            
            
        }
        
    }
}

