//
//  URL+Extension.swift
//  Bhakti_Vikasa
//
//  Created by gagandeepmishra on 16/01/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import Foundation
extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
