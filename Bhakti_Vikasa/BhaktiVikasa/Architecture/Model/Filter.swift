//
//  Filter.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 18/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
struct Filter {
    var name: String?,
    options:[String]?,
    selected:[String]?
    init(filter:NSDictionary) {
        self.name = filter.value(forKey: "name") as? String
        self.options = filter.value(forKey: "options") as? [String]
        self.selected = filter.value(forKey: "selected") as? [String]
    }
    static func createFilterObject(lectures:lectures = GlobleDB.rawGloble)->[Filter]{
        let filterCategories = ["Languages","Countries","Place","Years","Month","Categories","Translation"]
        var language : [String] = []
        var countries : [String] = []
        var place : [String] = []
        var years : [String] = []
        var month : [String] = []
        var categories : [String] = []
        var translation : [String] = []
        for l in lectures{
            if let lang = l.language?.main{
                language.append(lang)
            }
            if let count = l.location?.country{
                
                countries.append(count)
            }
            if let plac = l.place{
                
                place.append(contentsOf:  plac)
            }
            if let year = l.dateOfRecording?.year{
                
                years.append(year)
            }
            if let mont = l.dateOfRecording?.month{
                
                month.append(mont)
            }
            if let cat = l.category{
                
                categories.append(contentsOf:cat)
            }
            if let trans = l.language?.translations{
                
                translation.append(contentsOf:trans)
            }
            
        }
        
        print("language===========>\(language.removeDuplicates())")
        print("language===========>\(language.removeAll(where: {$0 == ""}))")
        print("language===========>\(language = language.sorted()))")

        print("countries===========>\(countries.removeDuplicates())")
        print("countries===========>\(countries.removeAll(where: {$0 == ""}))")
        print("countries===========>\(countries = countries.sorted()))")

        print("place===========>\(place.removeDuplicates())")
        print("place===========>\(place.removeAll(where: {$0 == ""}))")
        print("place===========>\(place = place.sorted()))")

        print("years===========>\(years = years.sorted().reversed()))")
        print("years===========>\(years.removeAll(where: {$0 == ""}))")
        print("years===========>\(years.removeDuplicates())")
        print("month===========>\(month = month.sorted())")
        print("month===========>\(month.removeAll(where: {$0 == ""}))")
        print("month===========>\(month.removeDuplicates())")
        
        print("categories===========>\(categories.removeDuplicates())")
        print("categories===========>\(categories = categories.sorted()))")

        print("translation===========>\(translation.removeDuplicates())")
        print("translation===========>\(translation = translation.sorted()))")

        let optionValue = [language.removeDuplicates(),
                           countries.removeDuplicates(),
                           place.removeDuplicates(),
                           years.removeDuplicates(),
                           month.removeDuplicates(),
                           categories.removeDuplicates(),
                           translation.removeDuplicates()]
        for (index,nameValue) in filterCategories.enumerated(){
            let filterdic : NSDictionary = ["name":nameValue,
                                            "options":optionValue[index],
                                            "selected":[String]()] as NSDictionary
            let filterCat = Filter.init(filter: filterdic)
            GlobleVAR.filterModel.append(filterCat)
        }
        return GlobleVAR.filterModel
        
    }
}
