//
//  Settinges.swift
//  Bhakti_Vikasa
//
//  Created by gagandeepmishra on 12/01/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import Foundation
import CodableFirebase
import Firebase
import Toaster


struct Settinges:Codable,Hashable {
    var notification:notificationSettings?
    var lastModificationTime:Int?
    var date:Date{
        guard let timeStamp = lastModificationTime else { return Date() }
        return Date(milliseconds: Int64(timeStamp))
    }
}
extension Settinges{
    struct notificationSettings:Codable,Hashable{
        var hindi: Bool = false {
            didSet{
                print("NOTIFICATION ON FOR HINDI LECTURES")
                FRManager.shared.subscribe(with: .BVKS_HINDI, isSubscribe: hindi)
            }
           
        }
        var english: Bool = false {
            didSet{
                print("NOTIFICATION ON FOR ENGLISH LECTURES")
                FRManager.shared.subscribe(with: .BVKS_ENGLISH, isSubscribe: english )
            }
           
        }
        var bengali: Bool? = false {
            didSet{
                print("NOTIFICATION ON FOR BENGALI LECTURES")
                FRManager.shared.subscribe(with: .BVKS_BENGALI, isSubscribe: bengali!)
            }
        }
    }
}

extension Settinges{
    static func setTodefaultSetting() -> Settinges?{
        var userSettinges = Settinges()
        var ntfSet = notificationSettings()
        userSettinges.lastModificationTime = c_Time

        ntfSet.hindi = true
        ntfSet.english = true
        ntfSet.bengali = true
        userSettinges.notification = ntfSet
        Settinges.updateUserSettings(setting: userSettinges)
        if GlobleVAR.appUser.uuid.count>0{
            FRManager.shared.subscribeAll(isSubscribe: true)
        }
        return userSettinges
    }
    static func updateUserSettings(setting:Settinges){
        guard let userUUid = Auth.auth().currentUser?.uid else{return}
        let doc = Firestore.firestore().collection("users").document("\(userUUid)/Settings/userSettings")
        
        let dataModal = try! FirebaseEncoder().encode(setting)
        
        doc.setData(dataModal as! [String : Any], merge: true)
        
        
    }
    static func getUserSettings(completion:@escaping(_ setting:Settinges?)->Void){
        // let doc = Firestore.firestore().collection("users").document("\(GlobleVAR.appUser.uuid)/Settings/userSettings")
        guard let id = Auth.auth().currentUser?.uid else{return}
        let doc = Firestore.firestore().collection("users").document("\(id)/Settings/userSettings")
        
        doc.getDocument(source: .server, completion: { (snapshot, error) in
        
            
            if let err = error {
                print(err.localizedDescription)
                Toast(text:err.localizedDescription,duration: Delay.long).show()
                return completion(Settinges())
            }else if let topData = snapshot?.data(){
                print(topData)
                let dataModal = try! FirestoreDecoder().decode(Settinges.self, from: topData)
                print(dataModal)
                completion(dataModal)
            }else{
                
                
                completion(nil)
            }
        })
    }
    
    
}
