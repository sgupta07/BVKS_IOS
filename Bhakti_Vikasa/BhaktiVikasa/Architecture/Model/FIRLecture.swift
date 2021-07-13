//
//  FIRLecture.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 13/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import Firebase
import Toaster
import CodableFirebase

typealias lectures = [Lecture]

struct Lecture:Codable {
    var category: [String]?
    var creationTimestamp: String?
    var dateOfRecording: FIRDateOfRecording?
    var id: Int?
    var language: FIRLanguage?
    var lastModifiedTimestamp: String?
    var legacyData: FIRLegacyData?
    var length: Int?
    var lengthType: [String]?
    var location: FIRLocation?
    var place: [String]?
    var resources: FIRResources?
    var search: FIRSearch?
    var tag: [String]?
    var thumbnail: String?
    var title: [String]?
    //This variables are define for local use Only dont post this on FireBase
    var info: LectureInfo?
    var globlePlayCount:Int? = 0
   
    
}

extension Lecture{
internal struct FIRDateOfRecording : Codable{
    var day: String?
    var month: String?
    var year: String?
}
internal struct FIRLanguage : Codable{
    var main: String?
    var translations: [String]?
}

internal struct FIRLegacyData : Codable{
    var lectureCode: String?
    var slug: String?
    var verse: String?
    var wpId: Int?
}

internal struct FIRLocation : Codable{
    var city: String?
    var country: String?
    var state: String?
}

internal struct FIRResources : Codable{
    var audios: [FIRAudio]?
    var transcriptions: [String]?
    var videos: [FIRVideo]?
}

internal struct FIRAudio : Codable{
    var creationTimestamp: String?
    var downloads: Int?
    var lastModifiedTimestamp: String?
    var url: String?

}
internal struct FIRVideo : Codable{
    var creationTimestamp: String?
    var lastModifiedTimestamp: String?
    var type: String?
    var url: String?

}

internal struct FIRSearch : Codable{
    var advanced: [String]?
    var simple: [String]?

}


}
extension Lecture{
    static func getLecture(with l_id:Int = 0,completion:@escaping(_ leactersInfo:lectures?)-> Void){
        let collectionPath = Firestore.firestore().collection(UserPath.appLectures.str)

        collectionPath.whereField("id", isEqualTo: l_id).getDocuments(completion: { (snapshot, error) in
              if let err = error {

                  print(err.localizedDescription)
                  Toast(text:err.localizedDescription,duration: Delay.long).show()
                  completion(nil)
                  return
              }
            guard let dbRecodes = snapshot?.documents  else {
                completion(nil)
                return
            }
            var rawinfo : lectures = []
              for docData in dbRecodes{
                  guard docData.data()["id"] != nil else {
                      print("+++NILLLLLL+")
                      continue
                  }
                  let model = try! FirestoreDecoder().decode(Lecture.self, from: docData.data())
                rawinfo.append(model)
              }
              completion(rawinfo)
          })
      }
    
    
}
//MARK:- get sort lectures according selected filters and sort Optartions
extension Lecture{
     static func getLecture(with searchStr:String, rawLecture:lectures)->lectures{
        var oprationalDB : lectures = []
        if searchStr.count>0{
            oprationalDB.removeAll()
            func removeDuplicateElements(lectures: [Lecture]) -> [Lecture] {
                var uniquePosts : lectures = []
                for lect in lectures {
                    if !uniquePosts.contains(where: {$0.id == lect.id })  {
                        uniquePosts.append(lect)
                    }
                }
                return uniquePosts
            }
            //seach by Title
            var cSearchStr = searchStr
            cSearchStr.removeAll(where: {$0 == " "})
            let filter1 = rawLecture.filter({ (lect) -> Bool in
                var sTitle = lect.title?.joined()
                guard let sss = sTitle?.removeAll(where: {$0.isPunctuation}) else{return false}
                cSearchStr.removeAll(where: {$0.isPunctuation})
                
                 return sTitle!.range(of: cSearchStr, options: .caseInsensitive) != nil
            })
            //seach by advanced
            let filter2 = rawLecture.filter({ (lect) -> Bool in
                return lect.search?.advanced?.joined().range(of: searchStr, options: .caseInsensitive) != nil
            })
            //seach by simple
            let filter3 = rawLecture.filter({ (lect) -> Bool in
                return lect.search?.simple?.joined().range(of: searchStr, options: .caseInsensitive) != nil
            })
            
            oprationalDB.append(contentsOf: filter1)
            oprationalDB.append(contentsOf: filter2)
            oprationalDB.append(contentsOf: filter3)
            oprationalDB = removeDuplicateElements(lectures: oprationalDB)
        }else{
            oprationalDB = rawLecture
        }
        return oprationalDB
    }
    static func getLecturs(with filters:[Filter], rawlectures:lectures)->lectures{
        var oprationalDB : lectures = rawlectures
        var filterAdded = 0
        for filter in filters{
            let fCount = filter.selected?.count ?? 0
            filterAdded += fCount
        }
        func findIntersection (firstArray : [String], secondArray : [String]) -> [String]
        {
            return [String](Set<String>(firstArray).intersection(secondArray))
        }

        if filterAdded == 0{
            oprationalDB = rawlectures
        }else{
            oprationalDB = []
            oprationalDB = rawlectures
            for (index,filter) in filters.enumerated(){
                let selectedOpt = filter.selected
                guard selectedOpt?.count ?? 0 > 0 else {
                    continue
                }
                switch index {
                case 0://Languages

                    var filterLacture:lectures = []
                    filterLacture = oprationalDB.filter({(selectedOpt?.contains($0.language?.main ?? "") ?? false)})
                    if filterLacture.count > 0 {
                        oprationalDB = filterLacture
                    }else{
                        oprationalDB = []

                    }
                    continue
                case 1://Countries
                    var filterLacture:lectures = []
                    filterLacture = oprationalDB.filter({(selectedOpt?.contains($0.location?.country ?? "") ?? false)})
                    if filterLacture.count > 0 {
                        oprationalDB = filterLacture
                    }else{
                        oprationalDB = []

                    }
                    continue
                case 2://Place
                    var filterLacture:lectures = []

                    filterLacture = oprationalDB.filter({lectur in
                        let result = findIntersection(firstArray: lectur.place ?? [] , secondArray: selectedOpt ?? [])
                        if result.count > 0{
                            return true
                        }else{return false}
                    })


                    if filterLacture.count > 0 {
                        oprationalDB = filterLacture
                    }else{
                        oprationalDB = []

                    }
                    continue
                case 3://Years
                    var filterLacture:lectures = []
                    filterLacture = oprationalDB.filter({(selectedOpt?.contains($0.dateOfRecording?.year ?? "") ?? false)})
                    if filterLacture.count > 0 {
                        oprationalDB = filterLacture
                    }else{
                        oprationalDB = []

                    }
                    continue
                case 4://Month
                    var filterLacture:lectures = []
                    filterLacture = oprationalDB.filter({(selectedOpt?.contains($0.dateOfRecording?.month ?? "") ?? false)})
                    if filterLacture.count > 0 {
                        oprationalDB = filterLacture
                    }else{
                        oprationalDB = []

                    }
                    continue
                case 5://Categories
                    var filterLacture:lectures = []

                    filterLacture = oprationalDB.filter({lectur in
                        let result = findIntersection(firstArray: lectur.category ?? [] , secondArray: selectedOpt ?? [])
                        if result.count > 0{
                            return true
                        }else{return false}
                    })


                    if filterLacture.count > 0 {
                        oprationalDB = filterLacture
                    }else{
                        oprationalDB = []

                    }
                    continue
                case 6://Translation
                    var filterLacture:lectures = []

                    filterLacture = oprationalDB.filter({lectur in
                        let result = findIntersection(firstArray: lectur.language?.translations ?? [] , secondArray: selectedOpt ?? [])
                        if result.count > 0{
                            return true
                        }else{return false}
                    })


                    if filterLacture.count > 0 {
                        oprationalDB = filterLacture
                    }else{
                        oprationalDB = []

                    }
                    continue
                default:
                    break
                }

            }
        }
//        if let indexOfPlayLecture = GlobleDB.rawGloble.firstIndex(where: {$0.id == GlobleVAR.currentPlay?.id})
//        {
//            GlobleVAR.currentIndex = indexOfPlayLecture
//        }else{
//            GlobleVAR.currentIndex = 0
//        }
        return oprationalDB
        
    }
    static func getLecture(withVideo isVideo:Bool , rawLectures:lectures)->lectures{
        var oprationalDB : lectures = rawLectures
        if isVideo{
            let videoLect = rawLectures.filter({($0.resources?.videos?.count ?? 0>0)})
            oprationalDB = videoLect
        }else{
            oprationalDB = rawLectures
        }
        return oprationalDB
    }
    static func getLectures(sortBy sort:Sortkind ,rawLecture:lectures) -> lectures{
        switch sort {
        case .durationAscending:
            return  rawLecture.sorted(by: {$0.length ?? 0 < $1.length ?? 0})
        case .durationDescending:
            return rawLecture.sorted(by: {$0.length ?? 0 > $1.length ?? 0})
        case .recordingDateAscending:
            var sortMigrationArray = rawLecture.sorted(by: {String("\($0.dateOfRecording?.day)") < String("\($1.dateOfRecording?.day)")})
            sortMigrationArray = sortMigrationArray.sorted(by: {String("\($0.dateOfRecording?.month)") < String("\($1.dateOfRecording?.month)")})
            sortMigrationArray = sortMigrationArray.sorted(by: {String("\($0.dateOfRecording?.year)") < String("\($1.dateOfRecording?.year)")})
            return sortMigrationArray
        case .recordingDateDescending:
            var sortMigrationArray = rawLecture.sorted(by: {String("\($0.dateOfRecording?.day)") > String("\($1.dateOfRecording?.day)")})
            sortMigrationArray = sortMigrationArray.sorted(by: {String("\($0.dateOfRecording?.month)") > String("\($1.dateOfRecording?.month)")})
            sortMigrationArray = sortMigrationArray.sorted(by: {String("\($0.dateOfRecording?.year)") > String("\($1.dateOfRecording?.year)")})
            return sortMigrationArray
        case .alphabeticallyAscending:
            return rawLecture.sorted(by: { $0.title!.joined() < $1.title!.joined() })
        case .alphabeticallyDescending:
            return rawLecture.sorted(by: { $0.title!.joined() > $1.title!.joined() })
        case .popularuty:
            return rawLecture.sorted(by: { $0.globlePlayCount ?? 0 > $1.globlePlayCount ?? 0 })
        case  .verseNumber:
            return rawLecture.sorted(by: { $0.search?.advanced?.first ?? ""  < $1.search?.advanced?.first ?? ""})
        case .none:
            return rawLecture
        }
    }
    static func getProccessedLecters(with lectures:lectures,searchStr:String?,isVideos:Bool?,sortBy:Sortkind?,filterPoints:[Filter]?)->lectures{
        var oprationalDB : lectures = lectures
        guard oprationalDB.count>0 else {return oprationalDB}
        // sort with search String
        if let search = searchStr{
            oprationalDB = Lecture.getLecture(with: search, rawLecture: oprationalDB)
        }
        
        guard oprationalDB.count>0 else {return oprationalDB}
        //Sort with filter selection
        if let filters = filterPoints{
            oprationalDB = Lecture.getLecturs(with: filters, rawlectures: oprationalDB)
        }
        
        guard oprationalDB.count>0 else {return oprationalDB}
        // sort with Video filter
        if let video = isVideos{
            oprationalDB = Lecture.getLecture(withVideo: video, rawLectures: oprationalDB)
        }
        guard oprationalDB.count>0 else {return oprationalDB}
        // sort with sort kind eg:durationAscending
        if let sort = sortBy{
            oprationalDB = Lecture.getLectures(sortBy: sort, rawLecture: oprationalDB)
        }
        guard oprationalDB.count>0 else {return oprationalDB}
        
        
        return oprationalDB
    }
}
