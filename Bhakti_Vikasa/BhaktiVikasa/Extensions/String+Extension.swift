//
//  String+Extension.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 11/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
extension String{
    mutating func removeBlankSpace(){
        self = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
    }
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        
        return "\(randomString.prefix(10))"
    }
    func timeStampTodate()->String{
        if let timeResult = (Double(self)) {
            let date = Date(timeIntervalSince1970: timeResult)
            let dateFormatter = DateFormatter()
          //  dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            dateFormatter.timeZone = .current
            let localDate = dateFormatter.string(from: date)
            return localDate
        }else{
            return ""
        }
    }
    
   
}
extension String
{
    func encodeUrl() -> String?
    {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    }
    func decodeUrl() -> String?
    {
        return self.removingPercentEncoding
    }
}

