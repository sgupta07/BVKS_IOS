//
//  Double+Extension.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 15/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
extension Double{
    var clean: String {

        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)

    }
//    10000.asString(style: .positional)  // 2:46:40
//    10000.asString(style: .abbreviated) // 2h 46m 40s
//    10000.asString(style: .short)       // 2 hr, 46 min, 40 sec
//    10000.asString(style: .full)        // 2 hours, 46 minutes, 40 seconds
//    10000.asString(style: .spellOut)    // two hours, forty-six minutes, forty seconds
//    10000.asString(style: .brief)       // 2hr 46min 40sec
    func secToMintasString(style: DateComponentsFormatter.UnitsStyle) -> String {
          let formatter = DateComponentsFormatter()
          formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
          formatter.unitsStyle = style
          guard let formattedString = formatter.string(from: self) else { return "" }
          return formattedString
        }
        func getDateStringFromUnixTime(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = dateStyle
            dateFormatter.timeStyle = timeStyle
            return dateFormatter.string(from: Date(milliseconds:  Int64(self)))
            //return dateFormatter.string(from: Date(timeIntervalSince1970: self))
        }
    
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}
struct StopWatch {

    var totalSeconds: Int

    var years: Int {
        return totalSeconds / 31536000
    }

    var days: Int {
        return (totalSeconds % 31536000) / 86400
    }

    var hours: Int {
        return (totalSeconds % 86400) / 3600
    }

    var minutes: Int {
        return (totalSeconds % 3600) / 60
    }

    var seconds: Int {
        return totalSeconds % 60
    }

    //simplified to what OP wanted
    var hoursMinutesAndSeconds: (hours: Int, minutes: Int, seconds: Int) {
        return (hours, minutes, seconds)
    }
}
extension FloatingPoint {
    var whole: Self { modf(self).0 }
    var fraction: Self { modf(self).1 }
}
