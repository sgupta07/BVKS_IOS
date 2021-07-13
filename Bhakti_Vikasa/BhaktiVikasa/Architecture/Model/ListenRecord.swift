//
//  ListingRecord.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 10/01/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

struct ListenRecord:Codable {
    
    struct  listen:Codable{
        var BG: Int?
        var SB: Int?
        var VSN: Int?
        var CC: Int?
        var Seminars: Int?
        var others: Int?
    }
    struct  listenDate:Codable{
        var day: Int?
        var month: Int?
        var year: Int?
    }
    
    var documentId:String?
    var documentPath:String?
    var creationTimestamp: Int?
    var lastModifiedTimestamp: Int?
    var audioListen: Int?
    var videoListen: Int?
    var playedIds: [Int?]
    var dateOfRecord:listenDate?
    var listenDetails:listen?
    var date:Date{
        guard let timeStamp = creationTimestamp else { return Date() }
        return Date(milliseconds: Int64(timeStamp))
    }
}

extension ListenRecord{
    //MARK:- ***** SAVE USER LISTENING PROGRESS ****
    static func updateUserListeningOnFireStore(with progressValue:Int){
        guard !GlobleVAR.isFirstPlay else {return}
        guard let lectureId = GlobleVAR.currentPlay?.id else {return}
        guard GlobleVAR.appUser.uuid.count > 0 else {return}
        
        let currentDate = Date().get(.day, .month, .year)
        let docpath = "\(String(describing: currentDate.day!))-\(String(describing: currentDate.month!))-\(String(describing: currentDate.year!))"
        let doc = Firestore.firestore().collection("users").document("\(GlobleVAR.appUser.uuid)/listenInfo/\(docpath)")
        print(".......",doc.path)
        func getDailyTopLectures(){
            print("***** SAVE USER LISTENING PROGRESS ****")
            doc.getDocument { (snapshot, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                if let topData = snapshot?.data(){
                    //update existing Node
                    var dataModal = try! FirestoreDecoder().decode(ListenRecord.self, from: topData)
                    dataModal.lastModifiedTimestamp = c_Time
                    if GlobleVAR.isVideoMode{
                        dataModal.videoListen = progressValue + (dataModal.videoListen ?? 0)
                    }else{
                        dataModal.audioListen = progressValue + (dataModal.audioListen ?? 0)
                    }
                   
                    if !dataModal.playedIds.contains(lectureId){
                        dataModal.playedIds.append(lectureId)
                    }
                    if dataModal.listenDetails != nil{
                        if GlobleVAR.currentPlay?.search?.advanced?.first?.contains("Bg") ?? false{
                            dataModal.listenDetails!.BG = progressValue + (dataModal.listenDetails?.BG ?? 0)
                        }
                        else if GlobleVAR.currentPlay?.search?.advanced?.first?.contains("SB") ?? false{
                            dataModal.listenDetails!.SB = progressValue + (dataModal.listenDetails?.SB ?? 0)
                        }
                        else if GlobleVAR.currentPlay?.search?.advanced?.first?.contains("VSN") ?? false{
                            dataModal.listenDetails!.VSN = progressValue + (dataModal.listenDetails?.VSN ?? 0)
                        }
                        else if GlobleVAR.currentPlay?.search?.advanced?.first?.contains("cc") ?? false{
                            dataModal.listenDetails!.CC = progressValue + (dataModal.listenDetails?.CC ?? 0)
                        }else if GlobleVAR.currentPlay?.search?.advanced?.first?.contains("Seminars") ?? false{
                            dataModal.listenDetails!.Seminars = progressValue + (dataModal.listenDetails?.Seminars ?? 0)
                        }
                        else{
                            dataModal.listenDetails!.others = progressValue + (dataModal.listenDetails?.others ?? 0)
                        }
                    }
                    let modelData = try! FirebaseEncoder().encode(dataModal)
                    doc.setData(modelData as! [String : Any], merge: true)
                }else{
                    //CREATE NEW NODE
                    let dateModel = listenDate(day: Date().get(.day),
                                               month: Date().get(.month),
                                               year: Date().get(.year)
                    )
                    let listenModel = listen(BG:0, SB:0,VSN:0, CC:0,Seminars:0,others:0)
                    let detailsModel = ListenRecord(documentId: docpath,
                                                    documentPath: doc.path,
                                                    creationTimestamp: c_Time,
                                                    lastModifiedTimestamp: c_Time,
                                                    audioListen: 0,
                                                    videoListen: 0,
                                                    playedIds: [lectureId],
                                                    dateOfRecord: dateModel,
                                                    listenDetails: listenModel)
                    
                    let dataModal = try! FirebaseEncoder().encode(detailsModel)
                    doc.setData(dataModal as! [String : Any], merge: true)
                }
            }
        }
        getDailyTopLectures()
    }
  
    //MARK:- ***** GET USER LISTENING PROGRESS ****
    static func getUserListenDetails(by style:RetriveBy,startDate:Date? = nil  ,EndeDate:Date? = nil ,completion:@escaping(_ leactersDetails:[ListenRecord]?)-> Void){
        
        
        guard GlobleVAR.appUser.uuid.count > 0 else {return}
        
        let doc = Firestore.firestore().collection("users").document(GlobleVAR.appUser.uuid).collection("listenInfo")
        var ref : Query? = nil
        switch style{
        case .day:
            print(Timestamp(date: Date()))
            let currentDate = Date().get(.day, .month, .year)
            let docpath = "\(String(describing: currentDate.day!))-\(String(describing: currentDate.month!))-\(String(describing: currentDate.year!))"
            
            ref = doc.whereField("documentId", isEqualTo: docpath)
        case .week:
            ref = doc.order(by: "creationTimestamp", descending: true).limit(to: 7)
        case .month:
            ref = doc.order(by: "creationTimestamp", descending: true).limit(to: 30)
            
        case .year:
            ref = doc.order(by: "creationTimestamp", descending: true).limit(to: 365)
        case .all:
            ref = doc.order(by: "creationTimestamp", descending: true)
        case .other:
            ref = doc.order(by: "creationTimestamp", descending: true)
        case .custome:
            guard let start = startDate?.timeIntervalSince1970  else {return}
            guard let end = EndeDate?.timeIntervalSince1970  else {return}
            
            ref = doc.order(by: "creationTimestamp", descending: true).whereField("creationTimestamp", isLessThan: end).whereField("creationTimestamp", isGreaterThan: start)
        case .thisWeek:
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: Date())
            ref = doc.order(by: "creationTimestamp", descending: true).limit(to: weekday)
            
        case .lastMonth:
            let calendar = Calendar.current
            let monthDay = calendar.component(.day, from: Date())
            ref = doc.order(by: "creationTimestamp", descending: true).limit(to: monthDay+30)
            
        case .lastweek:
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: Date())
            ref = doc.order(by: "creationTimestamp", descending: true).limit(to: weekday+7)
        }
        ref!.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var lectures:[ListenRecord?] = []
                
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let dataModal = try! FirestoreDecoder().decode(ListenRecord.self, from: document.data())
                    lectures.append(dataModal)
                    
                }
                guard let lect = lectures as? [ListenRecord] else {return}
                completion(lect)
            }
        }
    }
    
}


