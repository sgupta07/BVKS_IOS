//
//  FilterHandler.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 25/11/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import UIKit

class FilterHandler:NSObject{
    static let shared = FilterHandler()
    private override init() {
    }
    

    
    
    
}


//MARK: MINI PLAYER SETUP
extension FilterHandler{
    func setPlayerSpace(spaceObj:NSLayoutConstraint? = nil){
        
        var spaceAmount:CGFloat = 0.0
        if GlobleVAR.currentPlay == nil{
            spaceAmount = 0.0
        }else
        if GlobleVAR.isVideoMode && !GlobleVAR.mustAudio{
            spaceAmount = 250
        }else{
            spaceAmount = 80
        }
        
        if (spaceObj != nil){
            spaceObj?.constant = spaceAmount
            GlobleVAR.playerSpaceMargenOutlets.append(spaceObj!)
        }else{
            for obj in GlobleVAR.playerSpaceMargenOutlets{
                obj.constant = spaceAmount
            }
        }
        
    }
    
}
