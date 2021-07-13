//
//  JKCountryViewModel.swift
//  JKCaller
//
//  Created by Jitendra Kumar on 26/10/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit

final class JKCountryViewModel {
    static let shared  = JKCountryViewModel()
    var countries:[JKCountry] = []
    func getCountry(completion:(()->())? = nil){
       countries = Bundle.decode([JKCountry].self, forResource: "CountryCodes", extension: "json")
        completion?()
        
    }
    
}

extension Locale{
    static var isoCountryCodes:[String]{
        self.ReferenceType.isoCountryCodes
    }
    
    static func countryFlag(countryCode:String)->String{
        let base:UInt32 = 127397
        let countryFlag = String(String.UnicodeScalarView(countryCode.unicodeScalars.compactMap({ UnicodeScalar(base + $0.value) })))
        return countryFlag
    }
  
    
    func object(forKey key: NSLocale.Key) -> Any?{
        (self as NSLocale).object(forKey: key)
    }
    func displayName(forKey key: NSLocale.Key, value: Any) -> String?{
        (self as NSLocale).displayName(forKey: key, value: value)
    }
    var countryCode:String?{
        guard let vl = object(forKey: .countryCode) as? String  else { return nil }
        return vl
    }
    var countryName:String?{
        guard let code  = countryCode, let countryName = self.localizedString(forRegionCode: code) else { return nil }
        return countryName
    }
    var flag:String?{
        guard let countryCode = self.countryCode else { return nil}
        return Locale.countryFlag(countryCode: countryCode)
        
    }

}



