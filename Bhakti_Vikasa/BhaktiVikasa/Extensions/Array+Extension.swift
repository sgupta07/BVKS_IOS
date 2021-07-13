//
//  Array+Extension.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 18/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
extension Array where Element:Equatable {
    // Work With Native Data Type 
    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }

        return result
    }
    func mapToSet<T: Hashable>(_ transform: (Element) -> T) -> Set<T> {
           var result = Set<T>()
           for item in self {
               result.insert(transform(item))
           }
           return result
       }
    
 
}
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicatesModel() {
        self = self.removingDuplicates()
    }
    
    
}
//get repitation on array object
extension Sequence where Element: Hashable {
    var frequency: [Element: Int] { reduce(into: [:]) { $0[$1, default: 0] += 1 } }
}
