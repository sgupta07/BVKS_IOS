//
//  JKCountry.swift
//  JKCaller
//
//  Created by Jitendra Kumar on 26/10/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import Foundation
struct JKCountry:Decodable,Hashable {
    var countryCode:String
    var countryName:String
    var dialCode:String
    
    
    enum CodingKeys:String,CodingKey {
        case countryCode = "code"
        case countryName = "name"
        case dialCode = "dial_code"
        
        
    }
    var flag:String?{Locale.countryFlag(countryCode: countryCode)}
}

