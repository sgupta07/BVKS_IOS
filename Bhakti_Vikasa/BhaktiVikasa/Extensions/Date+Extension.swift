//
//  Date+Extension.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 10/01/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import Foundation
    extension Date {
        var millisecondsSince1970:Int64 {
            return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
        }
        init(milliseconds:Int64) {
            self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
        }
        func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
            return calendar.dateComponents(Set(components), from: self)
        }

        func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
            return calendar.component(component, from: self)
        }
    }

extension Date {

var weekdayName: String {
    let formatter = DateFormatter(); formatter.dateFormat = "E"
    return formatter.string(from: self as Date)
}

var weekdayNameFull: String {
    let formatter = DateFormatter(); formatter.dateFormat = "EEEE"
    return formatter.string(from: self as Date)
}
var monthName: String {
    let formatter = DateFormatter(); formatter.dateFormat = "MMM"
    return formatter.string(from: self as Date)
}
var OnlyYear: String {
    let formatter = DateFormatter(); formatter.dateFormat = "YYYY"
    return formatter.string(from: self as Date)
}
var period: String {
    let formatter = DateFormatter(); formatter.dateFormat = "a"
    return formatter.string(from: self as Date)
}
var timeOnly: String {
    let formatter = DateFormatter(); formatter.dateFormat = "hh : mm"
    return formatter.string(from: self as Date)
}
var timeWithPeriod: String {
    let formatter = DateFormatter(); formatter.dateFormat = "hh : mm a"
    return formatter.string(from: self as Date)
}

var DatewithMonth: String {
    let formatter = DateFormatter(); formatter.dateStyle = .medium ;
    return formatter.string(from: self as Date)
}
    var dayNumberOfWeek : Int {
        return Calendar.current.dateComponents([.weekday], from: self).weekday ?? 1
        // returns an integer from 1 - 7, with 1 being Sunday and 7 being Saturday

    }
    func monthName(from monthNumber:Int)-> String{
        let monthName = DateFormatter().monthSymbols[monthNumber - 1]
        return monthName
    }
}


extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var startOfMonth: Date {
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        
        return  calendar.date(from: components)!
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    func isMonday() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 2
    }
    func dateByAddingMonths(_ monthsToAdd: Int) -> Date? {
        let calendar = Calendar.current
        var months = DateComponents()
        months.month = monthsToAdd
        return calendar.date(byAdding: months, to: self)
    }
}


extension Date{
    func getDate(by period:RetriveBy)->(lastDate:Date,currentDate:Date)?{
        let calendar = Calendar.current
        switch period {
        case .lastweek:
            let currentWeek = calendar.component(.weekOfYear, from: Date())
            let currentYear = calendar.component(.year, from: Date())
            var lastYear = currentYear
            var lastWeek = currentWeek-1
            if currentWeek == 1{
                lastYear = currentYear-1
                let lastYearComp = DateComponents(weekOfYear: .max, yearForWeekOfYear: lastYear)
                guard let lastYear = Calendar.current.date(from: lastYearComp) else {return nil}
                lastWeek = calendar.component(.weekOfYear, from: lastYear)
            }
            let lastWeekComponents = DateComponents(weekOfYear: lastWeek, yearForWeekOfYear: lastYear)
            guard let lastWeekDate = Calendar.current.date(from: lastWeekComponents) else {return nil}
            let currentWeekComponents = DateComponents(weekOfYear: currentWeek, yearForWeekOfYear: currentYear)
            guard let currentWeekDate = Calendar.current.date(from: currentWeekComponents) else {return nil}
            print("lastWeekDate\(lastWeekDate),currentWeekDate\(currentWeekDate)")
            return (lastWeekDate,currentWeekDate)
        case .lastMonth:
            let currentMonth = calendar.component(.month, from: Date())
            let currentYear = calendar.component(.year, from: Date())
            var lastMonth = currentMonth-1
            var lastYear = currentYear
            if currentMonth == 1{
                lastYear = currentYear-1
                let lastYearComp =  DateComponents(month: .max, yearForWeekOfYear: lastYear)
                guard let lastYearDate = Calendar.current.date(from: lastYearComp) else {return nil}
                lastMonth = calendar.component(.month, from: lastYearDate)
            }
           
           

            
            guard let start = calendar.date(byAdding: .month, value: -1, to: self)?.startOfMonth else{return nil}
            guard let end = calendar.date(byAdding: .month, value: -1, to: self)?.endOfMonth else{return nil}
           
            
            
            return (start,end)
        case .thisWeek:
            let currentWeek = calendar.component(.weekOfYear, from: Date())
            let year = calendar.component(.year, from: Date())
            
            let thisWeekComponents = DateComponents(weekOfYear: currentWeek, yearForWeekOfYear: year)
            guard let thisWeekDates = Calendar.current.date(from: thisWeekComponents) else {return nil}
           
            return (thisWeekDates,Date())
        default:
            return nil
        }
    }
    
}
