//
//  GlobleVAR.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 18/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import UIKit
//import SundeedQLite
var isFirestLogin : Bool = false
var fireEmail = ""
var firePassword = ""
var c_Time:Int {
       return Int(Date().millisecondsSince1970)
}
struct GlobleVAR{
    
   
    //PROTOCOL
    static var searchfilterDeligate:lectureSearchProtocol?
    static var filterDeligate:FilterApplyProtocoal?
    
    //VARIABLE
    static var selectedTab:LType = .home
    static var filterModel:[Filter] = []
    static var currentPlay:Lecture? = nil
    {
        willSet{
            guard let oldID = currentPlay?.id, oldID != newValue?.id else{return}
            CommonPlayerFunc.shared.saveCurrentPlayPoint()
        }
        didSet{
            guard let current = self.currentPlay, oldValue?.id != current.id else{return}
//            if let  currentPlayUrl = current.resources?.videos?.first?.url, !currentPlayUrl.isEmpty{
//               //  isVideoMode = true
//            }else{
//
//               // isVideoMode = false
//            }
            mustAudio = false
            if let firstIndex = GlobleDB.rawPalyable.firstIndex(where: {$0.id == currentPlay?.id}){
                currentIndex = firstIndex
            }else{
                currentIndex = 0
            }
        }
    }
    static var currentIndex:Int = 0
    static var isSortActive:Bool = false
    static var isFirstPlay:Bool = true
    static var beingDownload: lectures? = []
    static var speedIndex : Int = 3
    //V2
    static var playerSpaceMargenOutlets : [NSLayoutConstraint] = []
    static var isVideoMode : Bool = false
    static var mustAudio : Bool = false
    static var appUser = User() 
    static var topLecture : [Int] = []
    static var isRepeatMode:Bool = false
    static var isShuffleMode:Bool = false
    static var topSafeAreaHeight: CGFloat = 0
    static var bottomSafeAreaHeight: CGFloat = 0
    static var backgroundTask: UIBackgroundTaskIdentifier = .invalid



    static func resetAllPreSets(){
        currentPlay = nil
        appUser = User()
        searchfilterDeligate = nil
        filterDeligate = nil
        selectedTab = .topLacture
        filterModel = []
        currentIndex = 0
        isSortActive = false
        isFirstPlay = true
        isVideoMode = false
        beingDownload = nil
        topLecture = []
        GlobleDB.resetStructer()
        UserDefaults.standard.removeObject(forKey: "lastPlay")
        FRFirestoreObserve.shared.loadFirstTime  = true
        CommonFunc.shared.switchAppLoader(value: false)
    }
    
}
struct GlobleDB {
    /// This Array hold List of lecter that are going to play One after another
    static var rawPalyable: lectures = []{
        didSet{
            if let firstIndex = rawPalyable.firstIndex(where: {$0.id == GlobleVAR.currentPlay?.id}){
                GlobleVAR.currentIndex = firstIndex
            }else{
                GlobleVAR.currentIndex = 0
            }
        }
    }
    /// This hold all fresh Recordes this Arry is not use for modification ,
    static var rawGloble: lectures = []
    static var rawToplist: lectures = []
    static var rawDownload: lectures = []
    static var rawFavourite: lectures = []
    static var rawPubliclist: [PlayList] = []
    static var rawPrivateList:  [PlayList] = []
    static func resetStructer(){
        rawGloble = []
        rawToplist = []
        rawDownload = []
        rawFavourite = []
        rawPubliclist = []
        rawPrivateList = []
        rawPalyable = []
        if let vcArray = UIApplication.getTopViewController()?.children{
            for vc in vcArray{
                NotificationCenter.default.removeObserver(vc)
            }
        }
    }

    

}
