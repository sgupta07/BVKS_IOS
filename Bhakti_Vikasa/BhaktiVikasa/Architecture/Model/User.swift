//
//  Person.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 13/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase
import Toaster
class User
{
    
    var name: String = ""
    var uuid: String = ""
    var email: String = ""
    var favouriteIDs: [Int] = []
    var playHistoryIds: [Int] = []
    var dailyVideoListion : NSDictionary = [:]
    var dailyAudioListion : NSDictionary = [:]
    var totalAudioListion : [NSDictionary] = []
    var totalVideoListion : [NSDictionary] = []

    

    enum FirNodes:String {
        case users
        case recentPlay
        case recentPlayIDs
        case favoriteIds
        case audioListen
        case videoListen
        case totalAudioListen
        case totalVideoListen
    }


    
}
extension User{
    static func addToHistoryPlaylist(){
        guard !GlobleVAR.isFirstPlay else {return}
        let authUser = Auth.auth().currentUser
        if GlobleVAR.appUser.playHistoryIds.contains(GlobleVAR.currentPlay!.id ?? 0){
            GlobleVAR.appUser.playHistoryIds.removeAll(where:{$0 == GlobleVAR.currentPlay?.id})
        }
        GlobleVAR.appUser.playHistoryIds.insert(GlobleVAR.currentPlay!.id ?? 0, at: 0)
        let dataModal = [User.FirNodes.recentPlayIDs.rawValue:GlobleVAR.appUser.playHistoryIds]
        let doc = Firestore.firestore().collection(User.FirNodes.users.rawValue).document(authUser!.uid)
        doc.setData(dataModal as [String : Any], merge: true, completion: { (error) in
            if error != nil{
                Toast(text:error?.localizedDescription,duration: Delay.long).show()
            }else{
                //Toast(text:"HISTORY LIST UPDATE",duration: Delay.long).show()
            }
        })
    }
    static func getUserPlayHistory(){
        let authUser = Auth.auth().currentUser
        let doc = Firestore.firestore().collection(User.FirNodes.users.rawValue).document(authUser!.uid)
        
        doc.addSnapshotListener { (snapshot, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            if let historyIds = snapshot?.data()?[User.FirNodes.recentPlayIDs.rawValue] as? [Int]{
                GlobleVAR.appUser.playHistoryIds = historyIds
            }
            if let favoritesIds = snapshot?.data()?[User.FirNodes.favoriteIds.rawValue] as? [Int]{
                GlobleVAR.appUser.favouriteIDs = favoritesIds
            }
            let data = snapshot?.data()
            print(data)
        }
    }
}
