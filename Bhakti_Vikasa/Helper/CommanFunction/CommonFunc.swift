//
//  CommanFunc.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 09/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import  UIKit
import ProgressHUD
import Toaster
import Alamofire
import SWRevealViewController
class CommonFunc : NSObject{
    static let shared = CommonFunc()
    private override init() {
        
    }
    
    var currentController:UIViewController?{
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        
        if let navController  =  rootController as? UINavigationController {
            
            if  let visibleViewController = navController.visibleViewController{
                return visibleViewController
            }else{
                return navController
            }
        }else if let sideController  =  rootController as? SWRevealViewController{
            if let tabBarController = sideController.frontViewController as? UITabBarController, let navController = tabBarController.selectedViewController as? UINavigationController {
                if let visibleViewController = navController.visibleViewController{
                    return visibleViewController
                }else{
                    return sideController
                    
                }
                
            }else if let navController = sideController.frontViewController as? UINavigationController {
                if let visibleViewController = navController.visibleViewController{
                    return visibleViewController
                }else{
                    return sideController
                    
                }
                
            }else if let navController = sideController.rearViewController as? UINavigationController {
                if let visibleViewController = navController.visibleViewController
                {
                    return visibleViewController
                }else{
                    return sideController
                }
            }
            
        }else if let tabBarController  =  rootController as? UITabBarController, let navController = tabBarController.selectedViewController as? UINavigationController{
            
            if  let visibleViewController = navController.visibleViewController{
                
                return visibleViewController
                
            }else{
                return tabBarController
            }
            
        }
        
        return nil
        
    }
    func getSafeAreaSize(){
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows[0]
            let safeFrame = window.safeAreaLayoutGuide.layoutFrame
            GlobleVAR.topSafeAreaHeight = safeFrame.minY
            GlobleVAR.bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
            print(safeFrame.minY)
            print(window.frame.maxY)
            print(safeFrame.maxY)
            print(GlobleVAR.bottomSafeAreaHeight)
        }
    }
    
    func switchAppLoader(value: Bool){
        DispatchQueue.main.async {
            if value {
                ProgressHUD.dismiss()
                ProgressHUD.show()
                UIApplication.getTopViewController()?.view.isUserInteractionEnabled = false
            }else{
                ProgressHUD.dismiss()
                UIApplication.getTopViewController()?.view.isUserInteractionEnabled = true
            }
        }
        if UIApplication.getTopViewController() == nil{
            print("VIEW NOT FOUND")
        }
    }
    func setHoemInital(){
        if let VC = UIApplication.getTopViewController()?.navigationController?.viewControllers{
            for v in VC {
                print(v)
                NotificationCenter.default.removeObserver(v)
            }
        }
        
        self.switchAppLoader(value: false)
        let appDeligate = UIApplication.shared.delegate as! AppDelegate
        let rootViewController = AppStorybords.home.instantiateViewController(withIdentifier: "SWRevealViewController")
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.isNavigationBarHidden = true
       
      //  appDeligate.window = UIWindow(frame: UIScreen.main.bounds)
        appDeligate.window?.rootViewController = navigationController
        appDeligate.window?.makeKeyAndVisible()
    }
    
    func setLoginital(){
        self.switchAppLoader(value: false)
        let appDeligate = UIApplication.shared.delegate as! AppDelegate
        let rootViewController = AppStorybords.login.instantiateViewController(withIdentifier: "LoginVC")
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.isNavigationBarHidden = true
       // appDeligate.window = UIWindow(frame: UIScreen.main.bounds)
        appDeligate.window?.rootViewController = navigationController
        appDeligate.window?.makeKeyAndVisible()
    }
    
    func openWebView(url: String){
        let appDeligate = UIApplication.shared.delegate as! AppDelegate
        let nav = appDeligate.window?.rootViewController as! UINavigationController
        let vc = AppStorybords.home.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
        vc.url = ""
        nav.pushViewController(vc, animated: true)
    }
    func openSafari(with url:String){
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
    
}
//MARK: VALIDATION
extension CommonFunc{
    func isEmailValide(_ email  :inout String)->Bool{
        let topVC = UIApplication.getTopViewController()
        email.removeBlankSpace()
        if  email == ""{
            switchAppLoader(value: false)
            
            topVC?.popupAlert(title: AppNotification.appName, message:AppNotification.emailEmpty, actionTitles: ["Ok"], actions: [nil])
            return false
        }else{
            return true
        }
    }
    func isPasswrdValide(_ password  :inout String)->Bool{
        let topVC = UIApplication.getTopViewController()
        password.removeBlankSpace()
        if  password == ""{
            switchAppLoader(value: false)
            
            topVC?.popupAlert(title: AppNotification.appName, message: AppNotification.passwordEmpty, actionTitles: ["Ok"], actions: [nil])
            return false
        }else if password.count < 6{
            switchAppLoader(value: false)
            topVC?.popupAlert(title: AppNotification.appName, message: AppNotification.pwdLegnthShort, actionTitles: ["Ok"], actions: [nil])
            return false
        }else{
            return true
        }
    }
    func isConfirmPWDValide(_ confirPWD  :inout String)->Bool{
        let topVC = UIApplication.getTopViewController()
        confirPWD.removeBlankSpace()
        if  confirPWD == ""{
            switchAppLoader(value: false)
            
            topVC?.popupAlert(title: AppNotification.appName, message: AppNotification.confirmPwdEmpty, actionTitles: ["Ok"], actions: [nil])
            return false
        }else if confirPWD.count < 6{
            switchAppLoader(value: false)
            topVC?.popupAlert(title: AppNotification.appName, message: AppNotification.confirpwdLegnthShort, actionTitles: ["Ok"], actions: [nil])
            return false
        }else{
            return true
        }
    }
    func isConfirmPWDmatch(_ password  :inout String,_ confirPWD  :inout String)->Bool{
        let topVC = UIApplication.getTopViewController()
        confirPWD.removeBlankSpace()
        password.removeBlankSpace()
        
        if  confirPWD != password{
            switchAppLoader(value: false)
            
            topVC?.popupAlert(title: AppNotification.appName, message: AppNotification.pwdNotMatch, actionTitles: ["Ok"], actions: [nil])
            return false
        }else{
            return true
        }
    }
    
}
//Lecture DownLoad process
extension CommonFunc{
    private func registerBackgroundTask() {
        GlobleVAR.backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
        self?.endBackgroundTask()
      }
        assert(GlobleVAR.backgroundTask != .invalid)
    }
    
    func endBackgroundTask() {
      print("Background task ended.")
        UIApplication.shared.endBackgroundTask(GlobleVAR.backgroundTask)
        GlobleVAR.backgroundTask = .invalid
    }
    //cheack loacle status with file url
    func isFileinLocaleDB(lectureRaw: Lecture)->(status:Bool,Path:String){
        func getDecodaUrl(lect:Lecture)->URL?{
            var webUrl : String = lectureRaw.resources?.audios?.first?.url ?? ""
            if let urlDecoder = webUrl.decodeUrl(){
                webUrl = urlDecoder.encodeUrl() ?? ""
            }else{
                webUrl = lectureRaw.resources?.audios?.first?.url ?? ""
            }
            return URL(string: webUrl)
        }
        
        
        
        func isDownloadFileExiset(path:String)->Bool{
            if FileManager.default.fileExists(atPath: path) {
                print("------>  \(path)")
                return true
            } else{
                print("file Not Exists  ------>  \(path)")
                return false
            }
            
        }
        
        guard let audioUrl = getDecodaUrl(lect: lectureRaw) else{return (status:false,Path:"")}
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
        let isdownload =  isDownloadFileExiset(path: destinationUrl.path)
        if isdownload == true {
            return (status:true, Path:destinationUrl.path)
        }else{
            return (status:false, Path:"")
        }
        //SAVE AUDIO FILE WITH PATH
    }
    
    func saveAudioFileLocalDB(with lecture:Lecture ,competion:@escaping(_ progress:Float?,_ progresedlecture:Lecture) -> Void){
    //    var lectureRaw = lecture
        //FALE TO SAVE AUDIO FILE WITH ERROR
        
        func getDecodaUrl(lect:Lecture)->URL?{
            var webUrl : String = lecture.resources?.audios?.first?.url ?? ""
            if let urlDecoder = webUrl.decodeUrl(){
                webUrl = urlDecoder.encodeUrl() ?? ""
            }else{
                webUrl = lecture.resources?.audios?.first?.url ?? ""
            }
            print("getDecodaUrl")
            print(URL(string: webUrl)?.absoluteURL.absoluteString.split(separator: "/").last)
            print(URL(string: webUrl)?.absoluteURL.lastPathComponent)
            return URL(string: webUrl)
        }
        //update lectureInfo
        func seveTofireStore(destinationUrl:URL){
            print("seveTofireStore")
            print(destinationUrl.absoluteURL.lastPathComponent.split(separator: "/").last)
            print(destinationUrl.absoluteURL.lastPathComponent)
            
            if let mtchLect = GlobleVAR.beingDownload?.first(where: { getDecodaUrl(lect: $0)?.absoluteURL.lastPathComponent == destinationUrl.absoluteURL.lastPathComponent}){
                GlobleVAR.beingDownload?.removeAll(where: {$0.id == mtchLect.id})
                setLectureInfoForUpdate(rawLect:mtchLect,destinationUrl:destinationUrl)
                if GlobleVAR.backgroundTask != .invalid {
                  endBackgroundTask()
                }
                competion(110,lecture)
            }
            
            
//            if let mtchLect = GlobleVAR.beingDownload?.first(where: { getDecodaUrl(lect: $0)?.absoluteURL.absoluteString.split(separator: "/").last == destinationUrl.absoluteURL.lastPathComponent.split(separator: "/").last}){
//                GlobleVAR.beingDownload?.removeAll(where: {$0.id == mtchLect.id})
//                setLectureInfoForUpdate(rawLect:mtchLect,destinationUrl:destinationUrl)
//                competion(110,lecture)
//            }
            
        }
        
      
        
        func setLectureInfoForUpdate(rawLect:Lecture,destinationUrl:URL){
            var info = LectureInfo()
            func createMediaObj(isNew:Bool){
                var videoMedia = LectureInfo.FIRMedia()
                videoMedia.url = ""
                videoMedia.downloads = 0
                var audioMedia = LectureInfo.FIRMedia()
                audioMedia.url = destinationUrl.path
                audioMedia.downloads = 1
                var platform = LectureInfo.FIRResources()
                platform.audios = audioMedia
                platform.videos = videoMedia
                info.ios = platform
                //save on fire base
                LectureInfo.setLectureInfo(with: info,isNew: isNew)
            }
            LectureInfo.getCurrentSnapshot(with: rawLect.id!) { (linfo) in
                if let Linfo = linfo {
                    info = Linfo
                    info.isDownloded = true
                    if let audioMediad = info.ios?.audios{
                        info.ios!.audios!.url! = destinationUrl.path
                        info.ios!.audios!.downloads! += 1
                        //save on fire base
                        LectureInfo.setLectureInfo(with: info, isNew: false)

                    }else{
                        createMediaObj(isNew: false)
                    }
                }else{
                    info.isDownloded = true
                    info.id = rawLect.id
                    createMediaObj(isNew: true)
                    
                    
                }
            }
            
            
        }
        
        
        if let audioUrl = getDecodaUrl(lect: lecture) {
            GlobleVAR.beingDownload?.append(lecture)
            print(audioUrl)
            print(audioUrl.lastPathComponent)
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            //SAVE AUDIO FILE WITH PATH
            
            
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("------>  \(destinationUrl.path)")
//                Toast(text: "The Audio file already exists at path").show()
                Toast(text: "The Audio file already downloaded").show()
                seveTofireStore(destinationUrl:destinationUrl)
                
            } else {
                self.registerBackgroundTask()
                AF.download(audioUrl).downloadProgress { (progress) in
                    print("Download Progress: \(progress.fractionCompleted)")
                    let prog = String(format:"%.2f", progress.fractionCompleted).dropFirst(2)
                    let progressFloat = Float(prog) ?? 0.0
                    competion(progressFloat,lecture)
                }
                .responseData { (rData) in
                    
                    guard let location = rData.fileURL, rData.error == nil else {
                        Toast(text: rData.error?.localizedDescription ?? "").show()
                        competion(nil,lecture)
                        return
                    }
                    do {
                        
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("destinationUrl+++++++++++\(destinationUrl.absoluteString)")
                        
                        Toast(text: "File saved under Downloads!").show()
                        seveTofireStore(destinationUrl:destinationUrl)
                        
                    } catch {
                        print(error)
                        Toast(text:  error.localizedDescription).show()
                        competion(nil,lecture)
                    }
                }
            }
        }else{
            Toast(text: "ERROR: Bad Audio Url, Audio is fild to download try again.").show()
            competion(nil,lecture)
        }
        
        
    }
    
    
    //Only check  with Downloaded path
//    func isDownloadFileExiset(path:String)->Bool{
//        if FileManager.default.fileExists(atPath: path) {
//            print("------>  \(path)")
//            Toast(text: "The Audio file already exists at path").show()
//             return true
//        } else{
//            print("file Not Exists  ------>  \(path)")
//            return false
//        }
//        
//    }
}


extension CommonFunc{
    //ONLY FOR TESTING PURPOSE
    func showNotification(){
           DispatchQueue.main.asyncAfter(deadline: .now()+3) {
               let content = UNMutableNotificationContent()
               content.title = "Feed the cat"
               content.subtitle = "It looks hungry"
               content.sound = UNNotificationSound.default
               // show this notification five seconds from now
               let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

               // choose a random identifier
               let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

               // add our notification request
               UNUserNotificationCenter.current().add(request)
           }
       }
}

