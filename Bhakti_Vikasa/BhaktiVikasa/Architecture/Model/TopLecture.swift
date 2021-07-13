//
//  TopLecture.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 10/01/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

struct TopLecture:Codable {
    struct Day:Codable{
        var day: Int?
        var month: Int?
        var year: Int?
    }
    var documentId:String?
    var documentPath:String?
    var creationTimestamp: Int?
    var lastModifiedTimestamp: Int?
    var audioPlayedTime: Int?
    var videoPlayedTime: Int?
    var playedBy: [String?]
    var playedIds: [Int?]
    var createdDay: Day?
    
    
    
}

extension TopLecture{
    // app all played track APP TOP 10
    static func updateTopPlayDetailsOnFireStore(){
        guard !GlobleVAR.isFirstPlay else {return}
        guard let lectureId = GlobleVAR.currentPlay?.id else {return}
        guard GlobleVAR.appUser.uuid.count > 0 else {return}
        
        let currentDate = Date().get(.day, .month, .year)
        let docpath = "\(String(describing: currentDate.day!))-\(String(describing: currentDate.month!))-\(String(describing: currentDate.year!))"
        let doc = Firestore.firestore().collection(FirFolder.TopLectures.rawValue).document(docpath)
     //   print(".......",doc.path)
        func getDailyTopLectures(){
            
            doc.getDocument { (snapshot, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                if let topData = snapshot?.data(){
                    var dataModal = try! FirestoreDecoder().decode(TopLecture.self, from: topData)
                    dataModal.lastModifiedTimestamp = c_Time
                    dataModal.audioPlayedTime = 0
                    dataModal.videoPlayedTime = 0
                    dataModal.playedIds.append(lectureId)
                    if !dataModal.playedBy.contains(GlobleVAR.appUser.uuid){
                        dataModal.playedBy.append(GlobleVAR.appUser.uuid)
                    }
                    let modelData = try! FirebaseEncoder().encode(dataModal)
                    doc.setData(modelData as! [String : Any], merge: true)
                }else{
                    //CREATE NEW NODE
                    let day = Day(day: Date().get(.day),
                    month: Date().get(.month),
                    year: Date().get(.year)
                    )
                    let details = TopLecture(documentId: docpath,
                                             documentPath: doc.path,
                                             creationTimestamp: c_Time,
                                             lastModifiedTimestamp: c_Time,
                                             audioPlayedTime: 0,
                                             videoPlayedTime: 0,
                                             playedBy: [GlobleVAR.appUser.uuid],
                                             playedIds: [lectureId],
                                             createdDay:day
                                             
                    )
                    let dataModal = try! FirebaseEncoder().encode(details)
                    doc.setData(dataModal as! [String : Any], merge: true)
                    
                }
            }
        }
        getDailyTopLectures()
    }
    
    static func getTopLectur(by style:RetriveBy,completion:@escaping(_ leactersDetails:[TopLecture]?)-> Void){
       // guard !GlobleVAR.isFirstPlay else {return}
        
        
        let doc = Firestore.firestore().collection(FirFolder.TopLectures.rawValue)
        var ref : Query? = nil
        switch style{
        case .day:
          //  print(Timestamp(date: Date()))
            let currentDate = Date().get(.day, .month, .year)
            let docpath = "\(String(describing: currentDate.day!))-\(String(describing: currentDate.month!))-\(String(describing: currentDate.year!))"
            ref = doc.whereField("documentId", isEqualTo: docpath)
        case .week:
            //last 7 days
             ref = doc.order(by: "creationTimestamp", descending: true).limit(to: 7)
        case .month:
            //last 30 days
            ref = doc.order(by: "creationTimestamp", descending: true).limit(to: 30) //as? CollectionReference
           
        case .year:
            //last 365 days
            ref = doc.order(by: "creationTimestamp", descending: true).limit(to: 365)
        case .custome:
            ref = doc.order(by: "creationTimestamp", descending: true).limit(to: 31)
        case .other:
            ref = doc.order(by: "creationTimestamp", descending: true).limit(to: 31)
        case .all:
            ref = doc.order(by: "creationTimestamp", descending: true)
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
                var lectures:[TopLecture?] = []

                for document in querySnapshot!.documents {
       //             print("\(document.documentID) => \(document.data())")

                    let dataModal = try! FirestoreDecoder().decode(TopLecture.self, from: document.data())
                    lectures.append(dataModal)

                }
                guard let lect = lectures as? [TopLecture] else {return}
                completion(lect)
            }
        }
    }
    
}
