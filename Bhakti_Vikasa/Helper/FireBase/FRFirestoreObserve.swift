//
//  FRFirestoreObserve.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 11/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase
import FirebaseFirestore
import Toaster
class FRFirestoreObserve: NSObject {
    static let shared = FRFirestoreObserve()
    var loadFirstTime = true
    var rawLecture : [[String:Any]] = []
    var lectureData = lectures()
    var updateLocalDBTime : Timer? = nil



    private override init() {
        
    }
    func fetchFireLesters(limet:Bool = false,completion:@escaping(_ leacters:lectures?)->Void){
        
        let lectures =  Firestore.firestore().collection("lectures")
        
        if !limet{
            
            lectures.getDocuments { (snapshot, error) in
                if let err = error{
                    print(err.localizedDescription)
                    completion(nil)
                }else{
                    guard let documents = snapshot?.documents else{return}
                    for d in documents {
                        let model = try! FirestoreDecoder().decode(Lecture.self, from: d.data())
                        self.lectureData.append(model)
                    }
                    completion(self.lectureData)
                }
            }
        }else{
            lectures.limit(to: 50).getDocuments { (snapshot, error) in
                if let err = error{
                    print(err.localizedDescription)
                    completion(nil)
                }else{
                    guard let documents = snapshot?.documents else{return}
                    for d in documents {
                        let model = try! FirestoreDecoder().decode(Lecture.self, from: d.data())
                        self.lectureData.append(model)
                    }
                    completion(self.lectureData)
                }
            }
        }
        
    }
    func fetchLecture(by id:Int,completion:@escaping(_ leacters:lectures?)->Void){
        Firestore.firestore().collection("lectures").whereField("id", isEqualTo: id).getDocuments()
            {
                (querySnapshot, err) in
                
                if let err = err
                {
                    print("Error getting documents: \(err)");
                }
                else
                {
                    //  var agencyNumber = 0
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let agencyy = data["id"] as? Int ?? 0
                        let title = data["creationTimestamp"] as? String ?? ""
                        let agencyId = document.documentID
                        print(title)
                        print(agencyy)
                        print(agencyId)
                        let model = try! FirestoreDecoder().decode(Lecture.self, from: data)
                        self.lectureData.append(model)
                    }
                    completion(self.lectureData)
                }
        }
        
    }
    
    //MARK :SAVE IN LOACL DB
    func saveFireLesters(completion:@escaping(_ leacters:lectures?)->Void){
        
        let lecturesRef =  Firestore.firestore().collection("lectures")
        
        
        lecturesRef.getDocuments { (snapshot, error) in
            if let err = error{
                print(err.localizedDescription)
                completion(nil)
            }else{
                var commmentData = lectures()
                guard let documents = snapshot?.documents else{return}
                for d in documents {
                    guard d.data()["id"] != nil else {
                        print("+++NILLLLLL+")
                        continue
                    }
                    let model = try! FirestoreDecoder().decode(Lecture.self, from: d.data())
                    commmentData.append(model)
                    self.rawLecture.append(d.data())
                }
                
                do {
                    let result = try JSONSerialization.save(jsonObject: self.rawLecture, toFilename: "BVDB")
                    print(result)
                }catch let e {
                    print("\(e.localizedDescription)")
                }
                
                
                completion(commmentData)
                
            }
        }
    }
}
//MARK:- FireBase DB Updates & changes
extension FRFirestoreObserve{
    
    func didChangeLecturInfo(completion:@escaping(_ leacters:lectures?)-> Void){
        self.lectureData.removeAll()
        self.rawLecture.removeAll()
        func postUpdateNotification(lectur:Lecture,event:DocumentChangeType){
            NotificationCenter.default.post(name: Notification.Name(AppNotification.lectureDidChange), object: ["lecture":lectur,"event":event])
        }
       
        func saveInLocalDB(){
            do {
                let result = try JSONSerialization.save(jsonObject: self.rawLecture, toFilename: "BVDB")
                print(result)
            }catch let e {
                print("\(e.localizedDescription)")
            }
        }
        
        Firestore.firestore().collection("lectures").addSnapshotListener { (snapshot, error) in
            self.updateLocalDBTime?.invalidate()
            
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            for data in snapshot?.documentChanges ?? []{
                guard data.document.data()["id"] != nil else {
                    print("+++NILLLLLL+")
                    continue
                }
                print("----->",data.document.data())
                var model = try! FirestoreDecoder().decode(Lecture.self, from: data.document.data())
                switch data.type {
                case .added:
                    print("DataEventType---->added \(String(describing: model.id))")
                    if self.loadFirstTime{
                        self.lectureData.append(model)
                        self.rawLecture.append(data.document.data())
                        // newLecturAdd(newl:model)
                    }else{
                        GlobleDB.rawGloble.append(model)
                        self.rawLecture.append(data.document.data())
                        self.updateLocalDBTime = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (t) in
                            saveInLocalDB()
                        })
                        postUpdateNotification(lectur: model, event: .added)
                        return
                    }
                    
                case .modified:
                    print("DataEventType---->modified \(String(describing: model.id))")
                    //updateLecture(updatel: model)
                    if let existModel = GlobleDB.rawGloble.first(where: {$0.id == model.id}){
                        model.info = existModel.info
                        GlobleDB.rawGloble.append(model)
                    }else{
                       GlobleDB.rawGloble.append(model)
                    }
                    self.updateLocalDBTime = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (t) in
                        saveInLocalDB()
                    })
                    postUpdateNotification(lectur: model, event: .modified)

                case .removed:
                    print("DataEventType---->removed \(String(describing: model.id))")
                    GlobleDB.rawGloble.removeAll(where: {$0.id == model.id})
                    self.updateLocalDBTime = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (t) in
                        saveInLocalDB()
                    })
                    postUpdateNotification(lectur: model, event: .removed)

                }
            }
            guard self.loadFirstTime else{
                return
            }
            saveInLocalDB()
            self.loadFirstTime = false
            guard UserDefaults.standard.dictionary(forKey: "lastPlay") == nil else{return}
            completion(self.lectureData)
        }
    }
    //ADD VALUE IN FIR
    func updateIsFavouriteList(){
       let uuid =  Auth.auth().currentUser?.uid ?? ""
        Firestore.firestore().collection("users").document(uuid).setData(["favoriteIds" : GlobleVAR.appUser.favouriteIDs], merge: true)
    }
    func getIsfavouriteList(){
      
        
        let uuid =  Auth.auth().currentUser?.uid ?? ""
        Firestore.firestore().collection("users").document(uuid).getDocument { (snapshot, erro) in
            if erro == nil {
                if let  fav = snapshot?.data()?["favoriteIds"] as? Array<Int>{
                    GlobleVAR.appUser.favouriteIDs = fav

                    
                }
            }else{
                print(erro as Any)
            }
        }
    }
}


//MARK:- create new Node And Update {}
extension FRFirestoreObserve{
    //user recent played track
//    func updateUserListenActivityTime(listenTime:Double){
//        guard !GlobleVAR.isFirstPlay else {return}
//
//        guard !GlobleVAR.isFirstPlay else {
//            return
//        }
//        func updateLastDateModel(with dataModal:NSDictionary){
//            let doc = Firestore.firestore().collection(User.FirNodes.users.rawValue).document(GlobleVAR.appUser.uuid)
//            doc.updateData(dataModal as! [AnyHashable : Any])
//        }
//        
//        func updateOnFirStore(with dataModal:NSDictionary){
//            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
//                let doc = Firestore.firestore().collection(User.FirNodes.users.rawValue).document(GlobleVAR.appUser.uuid)
//                 doc.setData(dataModal as! [String : Any], merge: true)
//
//                
//            }
//        }
//        
//        
//        print("***************",listenTime)
//        
//        if UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive   {
//            setDataModel(isVideo: false)
//        }else{
//            if let url = GlobleVAR.currentPlay?.resources?.videos?.first?.url, url != ""{
//                setDataModel(isVideo: true)
//            }else{
//                setDataModel(isVideo: false)
//            }
//        }
//        
//        
//        
//
//    }
    // app all played track APP TOP 10
//    func updateFirStoreWithPlayedIDs(){
//        guard !GlobleVAR.isFirstPlay else {return}
//
//        let doc = Firestore.firestore().collection("playedLectures").document("BVKS")
//
//           func setFRActions(){
//
//            func createApptopeIdsNode(){
//                if let id = GlobleVAR.currentPlay?.id{
//                    doc.updateData(["playedIds":[id]])
//                }else{
//                    let lId = GlobleDB.rawGloble[0].id
//                    doc.updateData(["playedIds":[lId]])
//                }
//            }
//             func getAppTopLectures(){
//                
//                doc.addSnapshotListener { (snapshot, error) in
//                    
//                    if let err = error {
//                        print(err.localizedDescription)
//                        return
//                    }
//                    if let historyIds = snapshot?.data()?["playedIds"] as? [Int]{
//                        GlobleVAR.topLecture = historyIds
//                        
//                    }else{
//                        createApptopeIdsNode()
//                    }
//                    
//                    let data = snapshot?.data()
//                    print(data)
//                    
//                    
//                }
//            }
//            getAppTopLectures()
//        }
//
//        if GlobleVAR.topLecture.count > 0{
//            GlobleVAR.topLecture.append(GlobleVAR.currentPlay!.id ?? 0)
//            doc.setData(["playedIds":GlobleVAR.topLecture], merge: true)
//        }else{
//            setFRActions()
//        }
//        
//    }

}
