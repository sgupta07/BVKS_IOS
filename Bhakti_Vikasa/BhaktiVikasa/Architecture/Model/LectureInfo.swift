//
//  LectureInfo.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 30/12/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation

struct LectureInfo:Codable {
    var documentId:String?
    var documentPath:String?
    var id: Int?
    var creationTimestamp: Int?
    var lastModifiedTimestamp: Int?
    var totallength: Float?
    var lastPlayedPoint: Float?
    var totalPlayedNo: Int?
    var totalplayedTime: Int?
    var downloadPlace: Int?
    var favouritePlace: Int?
    var android:FIRResources?
    var ios:FIRResources?
    var isCompleted: Bool?
    var isFavourite: Bool?
    var isDownloded: Bool?
    var isInPrivateList:Bool?
    var isInPublicList:Bool?
    var privateListIDs: [String]?
    var publicListIDs: [String]?
    var searchId : String?
    
}

extension LectureInfo{
    struct FIRResources : Codable{
        var audios: FIRMedia?
        var videos: FIRMedia?
    }
    struct FIRMedia : Codable{
        var downloads: Int?
        var url: String?
    }
}
//MARK: L_INFO FIR ACTIONS
import Firebase
import CodableFirebase
import Toaster
extension LectureInfo{
    
    static func getCurrentSnapshot(with Id:Int,completion:@escaping(_ leactersInfo:LectureInfo?)-> Void){
        
//        if let lecture = GlobleDB.rawGloble.first(where: {$0.info?.id == Id}){
//            completion(lecture.info)
//        }else{
            Firestore.firestore().collection(UserPath.lectureInfo.str)
                .whereField("searchId", isEqualTo:"\(Id)")
                .getDocuments(completion: { (snapshot, error) in
                    if let err = error {
                        
                        print(err.localizedDescription)
                        Toast(text:err.localizedDescription,duration: Delay.long).show()
                        completion(nil)
                        return
                    }
                    
                    if snapshot?.documents.count ?? 0 > 1 {
                        
                        snapshot?.documents.last?.reference.delete()
                    }
                    
                    guard let dbRecodes = snapshot?.documents.first?.data()  else {
                        completion(nil)
                        return
                    }
                    
                    
                    let model = try! FirestoreDecoder().decode(LectureInfo.self, from: dbRecodes)
                    completion(model)
                    
                })
     //   }
        
        
    }
    
    static func setLectureInfo(with lectureInfo : LectureInfo,isNew:Bool){
        DispatchQueue.main.async {
            
            
            guard Auth.auth().currentUser != nil else{return}
            guard let id = lectureInfo.id, id > 0 else{return}
            let collectionPath = Firestore.firestore().collection(UserPath.lectureInfo.str)
            // var nInfo = LectureInfo()
            var nInfo = lectureInfo
            if isNew{
                nInfo.searchId = "\(id)"
                nInfo.lastModifiedTimestamp = c_Time
                nInfo.creationTimestamp = c_Time
                nInfo.documentId = collectionPath.document().documentID
                nInfo.documentPath = UserPath.lectureInfo.str+"/\(String(describing: nInfo.documentId!))"
                print(nInfo.documentPath)
                print(nInfo.id)
                let dataModal = try! FirebaseEncoder().encode(nInfo)
                print(dataModal as! [String : Any])
                Firestore.firestore().document(nInfo.documentPath!).setData(dataModal as! [String : Any], merge: true)
                print("NEW NODE:\(nInfo.documentPath)")
            }else{
                nInfo.lastModifiedTimestamp = c_Time
                let dataModal = try! FirebaseEncoder().encode(nInfo)
                Firestore.firestore().document(nInfo.documentPath!).setData(dataModal as! [String : Any], merge: true)
                print("OLD NODE:\(nInfo.documentPath)")
                
            }
        }
        
        
        
        
        //        guard Auth.auth().currentUser != nil else{return}
        //        guard let id = lectureInfo.id, id > 0 else{return}
        //        let collectionPath = Firestore.firestore().collection(UserPath.lectureInfo.str)
        //        if isNew{
        //            lectureInfo.lastModifiedTimestamp = c_Time
        //            lectureInfo.creationTimestamp = c_Time
        //            lectureInfo.documentId = collectionPath.document().documentID
        //            lectureInfo.documentPath = UserPath.lectureInfo.str+"/\(String(describing: lectureInfo.documentId!))"
        //            let dataModal = try! FirebaseEncoder().encode(lectureInfo)
        //            Firestore.firestore().document(lectureInfo.documentPath!).setData(dataModal as! [String : Any], merge: true)
        //        }else{
        //            lectureInfo.lastModifiedTimestamp = c_Time
        //            let dataModal = try! FirebaseEncoder().encode(lectureInfo)
        //            Firestore.firestore().document(lectureInfo.documentPath!).setData(dataModal as! [String : Any], merge: true)
        //        }
        
    }
    
    //MARK:- FIR OBSERVER GET ALL INFO AND LISTEN UPDATE AND CHANGE
    static func addSnapsotListinerOnLectureinfo(completion:@escaping(_ leactersInfo:Lecture?)-> Void){
        
        Firestore.firestore().collection(UserPath.lectureInfo.str).addSnapshotListener{  (snapshot, error) in
            guard Auth.auth().currentUser != nil else{return}
            if let err = error {
                print(err.localizedDescription)
                Toast(text:err.localizedDescription,duration: Delay.long).show()
                // completion(nil)
                return
            }
            defer{
                if GlobleVAR.isFirstPlay{
                    print("FIRST_PLAY")
                    completion(nil)
                }
            }
            guard let dataArray  = snapshot?.documentChanges else{return}
            let changesCount = dataArray.count
            let isFirst : Bool = changesCount > 0 ? true : false
            for (ItemIndex,data) in dataArray.enumerated(){
                guard data.document.data()["id"] != nil else {
                    print("+++NILLLLLL+")
                    continue
                }
                
                print(LectureInfo.self)
                
                let model = try! FirestoreDecoder().decode(LectureInfo.self, from: data.document.data())
                switch data.type {
                case .added,.modified:
                    // print("PublicLectureInfo---->added \(String(describing: model.id))")
                    if GlobleVAR.currentPlay?.id == model.id{
                        print("RECIVED CURRENT VARIABLE")
                        GlobleVAR.currentPlay?.info = model
                    }
                    if let index = GlobleDB.rawGloble.firstIndex(where: {$0.id == model.id}){
                        let oldModel = GlobleDB.rawGloble[index].info
                        
                        GlobleDB.rawGloble[index].info = model
                        
                        //change and update happen during the app life cycle
                        if changesCount-1 == ItemIndex{
                            
                            
                            if  oldModel?.isFavourite == model.isFavourite ,oldModel?.isDownloded == model.isDownloded , !isFirst{
                                print("l_infoUpdate : ",model.id!)
                            }
                            else{
                                let dataModal = try! FirebaseEncoder().encode(GlobleDB.rawGloble[index])
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppNotification.lectureInfoUpadte), object: nil, userInfo: dataModal as? [AnyHashable : Any])
                                return
                            }
                            
                        }
                    }
                case .removed:
                    break
                }
            }
            completion(nil)
        }
    }
    
}
//MARK:- FAVOURITES & DOWNLOADS
extension LectureInfo{
    
    static func makeLactureCompleted(lecture:Lecture, isComplet:Bool){
        DispatchQueue.main.async {
            var lectInfo = LectureInfo()
            
            getCurrentSnapshot(with: lecture.id!) { (lInfo) in
                if let mainInfo = lInfo{
                    lectInfo = mainInfo
                    lectInfo.isCompleted = isComplet
                    lectInfo.lastPlayedPoint = 0
                    LectureInfo.setLectureInfo(with: lectInfo, isNew: false)
                }else{
                    lectInfo.isCompleted = isComplet
                    lectInfo.id = lecture.id!
                    lectInfo.lastPlayedPoint = 0
                    LectureInfo.setLectureInfo(with: lectInfo, isNew: true)
                }
            }
        }
    }
    static func setPlaceValue(ofLecters: lectures,favourite:Bool = false, download:Bool = false){
        GlobleVAR.isSortActive = true
        
        for (index,lecture) in ofLecters.enumerated(){
            
            var info = LectureInfo()
            info = lecture.info!
            
            
            getCurrentSnapshot(with: lecture.id!) { (lInfo) in
                if let mainInfo = lInfo{
                    info = mainInfo
                    if favourite{
                        info.favouritePlace = index
                    }else if download{
                        info.downloadPlace = index
                    }
                    self.setLectureInfo(with: info, isNew: false)
                }else{
                    if favourite{
                        info.favouritePlace = index
                    }else if download{
                        info.downloadPlace = index
                    }
                    self.setLectureInfo(with: info, isNew: true)
                }
                
            }
            
            guard GlobleDB.rawFavourite.count-1 == index else{continue}
            GlobleVAR.isSortActive = false
        }
        
    }
}
