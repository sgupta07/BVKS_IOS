//
//  UnivarsalLinkHandler.swift
//  Bhakti_Vikasa
//
//  Created by gagandeepmishra on 21/01/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import Foundation
import FirebaseDynamicLinks

class UnivarsalLinkHandler: NSObject {
    static let shared = UnivarsalLinkHandler()
    private override init() {
        
    }
    
    func shareLecture(lecture:Lecture){
        guard let link = URL(string: "https://bvks.com"+"?lectureId=" + "\(String(describing: lecture.id!))") else { return }
        print("URL--->",link)
        
        ////########FOR STAGEING###########/////
        //let dynamicLinksDomainURIPrefix = "https://bvks1.page.link"
        
        ////########FOR PRODUCTIO###########/////
        let dynamicLinksDomainURIPrefix = "https://bvks.page.link"

        guard let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix) else{return}
        
        linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.bhakti.bvks")
        linkBuilder.iOSParameters?.iPadFallbackURL = link
        linkBuilder.iOSParameters?.customScheme = ""
        linkBuilder.iOSParameters?.appStoreID = "1536451261"
        // linkBuilder.iOSParameters?.minimumAppVersion = "1.2.3"
        
        linkBuilder.androidParameters = DynamicLinkAndroidParameters(packageName: "com.iskcon.bvks")
        //linkBuilder.androidParameters?.minimumVersion = 123
        linkBuilder.androidParameters?.fallbackURL = link
        
        linkBuilder.otherPlatformParameters = DynamicLinkOtherPlatformParameters()
        linkBuilder.otherPlatformParameters?.fallbackUrl = link
        
        linkBuilder.analyticsParameters = DynamicLinkGoogleAnalyticsParameters(source: "orkut",
                                                                               medium: "social",
                                                                               campaign: "example-promo")
        
        linkBuilder.iTunesConnectParameters = DynamicLinkItunesConnectAnalyticsParameters()
        linkBuilder.iTunesConnectParameters?.providerToken = "1536451261"
        linkBuilder.iTunesConnectParameters?.campaignToken = "example-promo"
        
        linkBuilder.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        
        //*******************************************//
        var discriptions = ""
        let title = lecture.title?.joined(separator: " ") ??  ""
        let catgory = lecture.category?.joined(separator: ",") ?? ""
        let duration = "\n• Duration: " + Double(lecture.length ?? 0).secToMintasString(style: .positional)
        let location = "\n• Location: "  + (lecture.place?.randomElement() ?? "")
        let record = "\n• Date of Recording: \(lecture.dateOfRecording?.day ?? "")/\(lecture.dateOfRecording?.month ?? "")/\(lecture.dateOfRecording?.year ?? "")"
        if let verse = lecture.legacyData?.verse{
         //discriptions = "• "+catgory+duration+"\n• verse:"+verse+record+location
            discriptions = duration+"\n• \(verse)"+record+location
        }else{
           // discriptions = "• "+catgory+duration+record+location
             discriptions = duration+record+location
        }
        //*******************************************//
        
        linkBuilder.socialMetaTagParameters?.title = title
        linkBuilder.socialMetaTagParameters?.descriptionText = discriptions
        
        if let thumbnil = lecture.thumbnail{
            linkBuilder.socialMetaTagParameters?.imageURL = URL(string:thumbnil)
        }else{
            linkBuilder.socialMetaTagParameters?.imageURL = URL(string:"https://bvks-d1ac.kxcdn.com/wp-content/uploads/2018/05/20151441/GM.jpg")
        }
        
        
        guard let longDynamicLink = linkBuilder.url else { return }
        print("The long URL is: \(longDynamicLink)")
        linkBuilder.options = DynamicLinkComponentsOptions()
        linkBuilder.options?.pathLength = .short
        linkBuilder.shorten() { url, warnings, error in
            
            guard let url = url, error == nil else {
                return
            }
            print("The short URL is: \(url)")
            guard let VC = CommonFunc.shared.currentController else {return}
            VC.openShareActivityControler(userContent: [url])
        }
        
    }
    
    func appHandle(with univarsalLink:DynamicLink?){
//        print("--->",univarsalLink)
//        print("--->",univarsalLink?.url)
        guard let id = Int(univarsalLink?.url?.valueOf("lectureId") ?? "0"), id
            > 0 else{
                print("ERRO")
                return
        }
        if let lect = GlobleDB.rawGloble.first(where: {$0.id == id}){
            NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerModel), object: ["playerModel":lect])
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                self.appHandle(with: univarsalLink)
            }
        }
        
    }
}
