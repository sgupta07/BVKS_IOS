//
//  RazorPayCurrancy.swift
//  Bhakti_Vikasa
//
//  Created by gagandeepmishra on 22/01/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import Foundation

 
struct RazorPayCurrancy:Decodable,Hashable {
    var countryCode:String
    var countryName:String
    var currencySymbol:String
    var currencyCode:String
    
    
    enum CodingKeys:String,CodingKey {
        case currencyCode = "currency_code"
        case currencySymbol = "currency_symbol"
        case countryCode = "country_code"
         case countryName = "currency_name"
    }
   // var flag:String?{Locale.countryFlag(countryCode: countryCode)}
}
