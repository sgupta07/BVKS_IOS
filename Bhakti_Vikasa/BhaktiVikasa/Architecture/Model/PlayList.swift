//
//  PlayList.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 04/12/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import CodableFirebase
var selectedPlayListListener : ListenerRegistration? = nil

struct PlayList : Codable{
    // static var publicPlayList:[PlayList] = []
    // static var privatePlayList:[PlayList] = []
    
    enum listType:String {
        case publicList
        case privateList
        case history
        case popular
        var str:String{
            switch self {
            case .publicList: return "Public"
            case .privateList: return "Private"
            case .history : return "Recent Played"
            case .popular : return "Popular Lectures"
            }
        }
    }
    
    var title: String?,
        thumbnail:String?,
        listID: String?,
        lecturesCategory:String?,
        listType:String?,
        creationTime:Double?,
        lastUpdate:Double?,
        lectureCount:Int?,
        lectureIds: [Int]?,
        docPath:String?,
        discription:String?,
        authorEmail:String?
    
    
    
    init(name: String?,
         thumbnail:String?,
         listID: String?,
         lecturesCategory:String?,
         listType:String?,
         creationTime:Double?,
         lastUpdate:Double?,
         lectureCount:Int?,
         lectureIds:[Int]?,
         docPath:String?,
         discription:String?,
         email:String?){
        self.title = name
        self.thumbnail = thumbnail
        self.listID =  listID
        self.lecturesCategory = lecturesCategory
        self.listType = listType
        self.creationTime = creationTime
        self.lastUpdate = lastUpdate
        self.lectureCount = lectureCount
        self.lectureIds = lectureIds
        self.docPath = docPath
        self.discription = discription
        self.authorEmail = email
    }
    
    
    
}
//MARK:- FIR  PLAY LIST OPRATIONS
import Firebase
import Toaster

extension PlayList{
    static  func getPublicPlayList(loadFirstTime: Bool = false,completion:@escaping(_ leacters:[PlayList]?)-> Void){
        Firestore.firestore().collection("PublicPlaylists").addSnapshotListener { (snapshot, error) in
            if let err = error {
                
                print(err.localizedDescription)
                Toast(text:err.localizedDescription,duration: Delay.long).show()
                completion(nil)
                return
            }
            
            for data in snapshot?.documentChanges ?? []{
                guard data.document.data()["listID"] != nil else {
                    print("+++NILLLLLL+")
                    continue
                }
                let model = try! FirestoreDecoder().decode(PlayList.self, from: data.document.data())
                switch data.type {
                case .added:
                    print("PublicPlayList---->added \(String(describing: model.listID))")
                    GlobleDB.rawPubliclist.append(model)
                    
                    
                case .modified:
                    print("PublicPlayList---->modified \(String(describing: model.listID))")
                    
                    if let index = GlobleDB.rawPubliclist.firstIndex(where: {$0.listID == model.listID}){
                        
                        GlobleDB.rawPubliclist.remove(at: index)
                        GlobleDB.rawPubliclist.insert(model, at: index)
                    }
                    
                case .removed:
                    print("PublicPlayList---->removed \(String(describing: model.listID))")
                    if let index = GlobleDB.rawPubliclist.firstIndex(where: {$0.listID == model.listID}){
                        GlobleDB.rawPubliclist.remove(at: index)
                        print("item deleted")
                    }
                }
            }
            print("********************")
            guard !loadFirstTime else{
                return
            }
            completion(GlobleDB.rawPubliclist)
        }
    }
    
    static func getPrivatePlayList(loadFirstTime: Bool = false,completion:@escaping(_ leacters:[PlayList]?)-> Void){
        let auth = Auth.auth().currentUser!
        let privateCollection = Firestore.firestore().collection("PrivatePlaylists").document(auth.uid).collection(auth.email!)
        privateCollection.addSnapshotListener { (snapshot, error) in
            
            if let err = error {
                print(err.localizedDescription)
                Toast(text:err.localizedDescription,duration: Delay.long).show()
                completion(nil)
                return
            }
            
            for data in snapshot?.documentChanges ?? []{
                guard data.document.data()["listID"] != nil else {
                    print("+++NILLLLLL+")
                    continue
                }
                let model = try! FirestoreDecoder().decode(PlayList.self, from: data.document.data())
                switch data.type {
                case .added:
                    print("PublicPlayList---->added \(String(describing: model.listID))")
                    GlobleDB.rawPrivateList.append(model)
                    
                    
                case .modified:
                    print("PublicPlayList---->modified \(String(describing: model.listID))")
                    
                    if let index = GlobleDB.rawPrivateList.firstIndex(where: {$0.listID == model.listID}){
                        
                        GlobleDB.rawPrivateList.remove(at: index)
                        GlobleDB.rawPrivateList.insert(model, at: index)
                    }
                    
                case .removed:
                    print("PublicPlayList---->removed \(String(describing: model.listID))")
                    if let index = GlobleDB.rawPrivateList.firstIndex(where: {$0.listID == model.listID}){
                        GlobleDB.rawPrivateList.remove(at: index)
                        print("item deleted")
                    }
                }
            }
            print("********************")
            guard !loadFirstTime else{
                return
            }
            completion(GlobleDB.rawPrivateList)
        }
    }
    static func getPlaylist(with docPath:String,completion:@escaping(_ slist:PlayList?) -> Void){
        guard (Auth.auth().currentUser != nil) else{
            completion(nil)
            return
        }
        print("list pocPath:",docPath)
        
        selectedPlayListListener = Firestore.firestore().document(docPath).addSnapshotListener { (snapshot, error) in
            if let err = error {
                print(err.localizedDescription)
                Toast(text:err.localizedDescription,duration: Delay.long).show()
                completion(nil)
                return
            }
            
            if let data = snapshot?.data(),snapshot?.exists ?? false,!data.isEmpty{
                guard data["listID"] != nil else {
                    print("+++NILLLLLL+")
                    return completion(nil)
                }
                let model = try! FirestoreDecoder().decode(PlayList.self, from: data)
                
                if let index = GlobleDB.rawPrivateList.firstIndex(where: {$0.listID == model.listID}){
                    
                    GlobleDB.rawPrivateList.remove(at: index)
                    GlobleDB.rawPrivateList.insert(model, at: index)
                }
                if let index = GlobleDB.rawPubliclist.firstIndex(where: {$0.listID == model.listID}){
                    
                    GlobleDB.rawPubliclist.remove(at: index)
                    GlobleDB.rawPubliclist.insert(model, at: index)
                }
                
                completion(model)
            }else{
                completion(nil)
            }
            print("********************")
            
            
        }
    }
    static func deletePlaylist(with list: PlayList){
        guard let docPath = list.docPath else{return}
        Firestore.firestore().document(docPath).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
                Toast(text:"Error removing Playlist'",duration: Delay.long).show()
                
            } else {
                print("Document successfully removed!")
                Toast(text:"Playlist successfully removed!",duration: Delay.long).show()
                
            }
        }
    }
    
    static func createPrivatePlayList(with list: PlayList){
        CommonFunc.shared.switchAppLoader(value: true)
        var playList = list
        
        let uuid =  Auth.auth().currentUser?.uid ?? ""
        let uEmail =  Auth.auth().currentUser?.email ?? ""
        let doc = Firestore.firestore().collection("PrivatePlaylists").document(uuid).collection(uEmail).document()
        
        playList.listID = doc.documentID
        playList.docPath = doc.path
        print(">>>>>>",doc.path)
        let dataModal = try! FirebaseEncoder().encode(playList)
        
        doc.setData(dataModal as! [String : Any], merge: true, completion: { (error) in
            CommonFunc.shared.switchAppLoader(value: false)
            
            if error != nil{
                Toast(text:error?.localizedDescription,duration: Delay.long).show()
                
            }else{
                Toast(text:"Private playlist '\(playList.title ?? "")' created",duration: Delay.long).show()
                
            }
        })
    }
    static func createPublicPlayList(with list: PlayList){
        CommonFunc.shared.switchAppLoader(value: true)
        var playList = list
        
        let doc = Firestore.firestore().collection("PublicPlaylists").document()
        
        
        playList.listID = doc.documentID
        playList.docPath = doc.path
        let dataModal = try! FirebaseEncoder().encode(playList)
        
        doc.setData(dataModal as! [String : Any], merge: true, completion: { (error) in
            CommonFunc.shared.switchAppLoader(value: false)
            
            if error != nil{
                Toast(text:error?.localizedDescription,duration: Delay.long).show()
                
            }else{
                Toast(text:"Public playlist, '\(playList.title ?? "")' created",duration: Delay.long).show()
                
            }
        })
        
        
        
        
    }
    
    func updatePlaylist(with pList:PlayList,lectID:Int,addtolist:Bool){
        var rewList = pList
        print("rewList->",rewList)
        print(rewList.docPath)
        if addtolist{
            if rewList.lectureIds?.contains(lectID) ?? false{
                Toast(text:"Lecture Already In Playlist!",duration: Delay.long).show()
            }else{
                rewList.lectureCount! += 1
                rewList.lectureIds?.append(lectID)
                Toast(text:"Lecture added to playlist, '\(pList.title ?? "")'",duration: Delay.long).show()
                
            }
            
            
        }else{
            print(rewList.lectureCount!)
            print(rewList.lectureIds!)
            //            if let ids = rewList.lectureIds,ids.count>1{
            //                rewList.lectureCount! = ids.count
            //                rewList.lectureIds?.removeFirst(lectID)
            //            }else{
            //                rewList.lectureCount! -= 0
            //                rewList.lectureIds = []
            //            }
            guard let index = rewList.lectureIds?.firstIndex(of: lectID)else{return}
            var temp = rewList.lectureIds
            temp?.remove(at: index)
            rewList.lectureIds = temp
            rewList.lectureCount = rewList.lectureIds!.count
            
            Toast(text:"Lecture removed successfully!",duration: Delay.long).show()
            print(rewList.lectureCount!)
            print(rewList.lectureIds!)
            
            
        }
        rewList.lastUpdate =  Double(c_Time)
        
        let dataModal = try! FirebaseEncoder().encode(rewList)
        
        Firestore.firestore().document(rewList.docPath ?? "").setData(dataModal as! [String : Any], merge: true)
    }
    
    
    
}
//MARK:- extension use for sort and filter Functions
extension PlayList{
    
    static func getPlaylist(with searchStr:String, lists:[PlayList])->[PlayList]{
        var oprationalPlaylist : [PlayList] = []
        if searchStr.count > 0{
            oprationalPlaylist = []
            func removeDuplicateElements(playList: [PlayList]) -> [PlayList] {
                var uniquePosts : [PlayList] = []
                for item in playList {
                    if !uniquePosts.contains(where: {$0.listID == item.listID })  {
                        uniquePosts.append(item)
                    }
                }
                return uniquePosts
            }
            let filter1 = lists.filter({ (item) -> Bool in
                return item.title?.range(of: searchStr.replacingOccurrences(of: " ", with: ""), options: .caseInsensitive) != nil
            })
            let filter2 = lists.filter({ (item) -> Bool in
                return item.lecturesCategory?.range(of: searchStr, options: .caseInsensitive) != nil
            })
            let filter3 = lists.filter({ (item) -> Bool in
                return item.discription?.range(of: searchStr, options: .caseInsensitive) != nil
            })
            var tempList : [PlayList] = []
            tempList.append(contentsOf: filter1 )
            tempList.append(contentsOf: filter2 )
            tempList.append(contentsOf: filter3 )
            
            oprationalPlaylist = removeDuplicateElements(playList: tempList )
            
        }else{
            oprationalPlaylist = lists
        }
        return oprationalPlaylist
    }
    
    
    static func getPlaylist(sortBy sort:Sortkind ,rawPlaylist:[PlayList]) -> [PlayList]{
        
        switch sort {
        
        case .alphabeticallyAscending:
            let sortedUsers = rawPlaylist.sorted(by: { $0.title!.uppercased() < $1.title!.uppercased() })
            return sortedUsers
        case .alphabeticallyDescending:
            let sortedUsers = rawPlaylist.sorted(by: { $0.title!.uppercased() > $1.title!.uppercased() })
            return sortedUsers
        default:
            return rawPlaylist
        }
    }
    static func getPlaylist(with searchStr:String?,sortBy:Sortkind?,rawPlaylist:[PlayList]) -> [PlayList]{
        var oprationalPlaylist : [PlayList] = rawPlaylist
        guard oprationalPlaylist.count>0 else {return oprationalPlaylist}
        // sort with search String
        if let search = searchStr{
            oprationalPlaylist = PlayList.getPlaylist(with: search, lists: oprationalPlaylist)
        }
        guard oprationalPlaylist.count>0 else {return oprationalPlaylist}
        // sort with search sortBy
        if let sort = sortBy{
            oprationalPlaylist = PlayList.getPlaylist(sortBy: sort, rawPlaylist: oprationalPlaylist)
        }
        guard oprationalPlaylist.count>0 else {return oprationalPlaylist}
        
        return oprationalPlaylist
    }
}
//ADD TO PLAYLIST
extension PlayList{
    static func addToPlayListAlert(lect:Lecture){
        let presentAbleVC = AppStorybords.home.instantiateViewController(withIdentifier: "AddToPlaylistVC")as! AddToPlaylistVC
        guard let VC = UIApplication.getTopViewController() else{
            Toast(text: "error").show()
            return
        }
        
        let alert = UIAlertController(title: "Add to playlist", message: "Please select from the following options", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Public Playlists", style: .default , handler:{ (UIAlertAction)in
            print("User click Approve button")
            presentAbleVC.listType = .publicList
            presentAbleVC.opratedlecture = lect
            VC.present(presentAbleVC, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Private Playlists", style: .default , handler:{ (UIAlertAction)in
            print("User click Edit button")
            presentAbleVC.listType = .privateList
            presentAbleVC.opratedlecture = lect
            VC.present(presentAbleVC, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Create a New Playlist", style: .default , handler:{ (UIAlertAction)in
            print("User click Edit button")
            let createVC = AppStorybords.home.instantiateViewController(withIdentifier: "CreatePaylistVC")as! CreatePaylistVC
            createVC.opratedlecture = lect
            VC.present(createVC, animated: true, completion: nil)
        }))
        
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            // It's an iPhone
            break
        case .pad:
            // It's an iPad (or macOS Catalyst)
          //  alert.popoverPresentationController?.sourceView = VC.view
            if let popoverPresentationController = alert.popoverPresentationController {
                  popoverPresentationController.sourceView = VC.view
                  popoverPresentationController.sourceRect = CGRect(x: VC.view.bounds.midX, y: VC.view.bounds.midY, width: 0, height: 0)
                  popoverPresentationController.permittedArrowDirections = []
                }
            break
            
        @unknown default:
            // Uh, oh! What could it be?
            break
        }
        
        VC.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
}
