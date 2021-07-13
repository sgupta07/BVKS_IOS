//
//  CustomeProtocoal.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 18/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
protocol sectionSelecterProtocol {
    func selectedSectionChange(with selection:LType)
}

protocol lectureSearchProtocol {
    func filterWithString(search: String,isActiveString:Bool)
}
protocol FilterApplyProtocoal {
    func filterApply(with selecter:Int,filters:[Filter])
    func videoFileter(with status:Bool)
    /// this function called when sort option is setect or change
    /// - Parameter sortBy: Sortkind, eg: Ascending ,Descending
    func lectureList(sortBy:Sortkind)
}



