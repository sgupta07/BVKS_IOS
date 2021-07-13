//
//  appEnums.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 15/12/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import UIKit
enum LType {
    case home
    case playList
    case topLacture
    case download
    case favourite
    case selectedList
    case history
    
}
enum RetriveBy{
    case day
    case week
    case month
    case year
    case thisWeek
    case lastMonth
    case lastweek
    case all
    case custome
    case other
}
enum FirFolder:String{
    case PrivatePlaylists
    case PublicPlaylists
    case lectures
    case restaurants
    case TopLectures
    
}

enum UserPath:String{
    case lectureInfo
    case appLectures
    case listenInfo
    var str:String{
        switch self {
        case .lectureInfo: return "users/\(GlobleVAR.appUser.uuid)/lectureInfo"
        case .appLectures: return "lectures"
        case .listenInfo: return "users/\(GlobleVAR.appUser.uuid)/listenInfo"
            
            
            
        }
    }
}

enum Sortkind : String{
    case durationAscending = "Duration: Low to High"
    case durationDescending = "Duration: High to Low"
    case recordingDateAscending = "Recording date: oldest first"
    case recordingDateDescending = "Recording date: latest first"
    case alphabeticallyAscending = "Alphabetically: A -> Z"
    case alphabeticallyDescending = "Alphabetically: Z -> A"
    case popularuty = "Popularity"
    case verseNumber = "Verse Number (developing)"
    case none = "Default"
    
}

enum LecturteDropdown:String {
    case download
    case favorites
    case addToPlaylist
    case completed
    case share
    case delete
    case unfavorites
    case reset
    case create_playlist
    case unknow
    case deletePlaylist
    case removeFormPlaylist
    var raw: String{
        switch self {
        case .download: return "Download"
        case .favorites: return "Add to Favorites"
        case .addToPlaylist: return "Add to playlist"
        case .completed: return  "Mark as Heard"
            
        case .share: return "Share"
        case .delete: return "Delete from Downloads"
        case .unfavorites: return "Remove from Favorites"
        case .reset: return "Reset progress"
            
        case .create_playlist: return "create playlist"
        case .unknow: return "unknow"
            
        case .deletePlaylist: return "Delete playlist"
        case .removeFormPlaylist: return "Remove from playlist" 
        }
    }
    static func initialize(stringValue: String)-> LecturteDropdown? {
        switch stringValue {
        case LecturteDropdown.download.raw:
            return LecturteDropdown.download
            
        case LecturteDropdown.favorites.raw:
            return LecturteDropdown.favorites
            
        case LecturteDropdown.addToPlaylist.raw:
            return LecturteDropdown.addToPlaylist
            
        case LecturteDropdown.completed.raw:
            return LecturteDropdown.completed
            
        case LecturteDropdown.share.raw:
            return LecturteDropdown.share
            
        case LecturteDropdown.delete.raw:
            return LecturteDropdown.delete
            
        case LecturteDropdown.unfavorites.raw:
            return LecturteDropdown.unfavorites
            
        case LecturteDropdown.reset.raw:
            return LecturteDropdown.reset
            
        case LecturteDropdown.create_playlist.raw:
            return LecturteDropdown.create_playlist
        case LecturteDropdown.removeFormPlaylist.raw:
            return LecturteDropdown.removeFormPlaylist
        case LecturteDropdown.deletePlaylist.raw:
            return LecturteDropdown.deletePlaylist
        default:
            return LecturteDropdown.unknow
        }
    }
}

public struct Platform {
    
    static public var isSimulator: Bool{
        var isSim = false
        #if arch(i386) || arch(x86_64)
        isSim = true
        #endif
        return isSim
        
    }
    static public var isPhone:Bool {UIDevice.current.userInterfaceIdiom == .phone}
    static public var isPad:Bool{UIDevice.current.userInterfaceIdiom == .pad}
    static public var isLandscape:Bool{return UIDevice.current.orientation.isLandscape }
    static public var isPortrait:Bool{return UIDevice.current.orientation.isPortrait}
    
}

