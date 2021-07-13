//
//  Bundle+Ex.swift
//  Bhakti_Vikasa
//
//  Created by gagandeepmishra on 22/01/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import Foundation
extension Bundle {
    static func path(forResource name:String?,ofType type:String?)->String?{
        return Bundle.main.path(forResource: name, ofType: type)
    }

    static func url(forResource name:String?,extension ex:String?)->URL?{
        return Bundle.main.url(forResource: name, withExtension: ex)

    }

    

    static func decode<T: Decodable>(_ type: T.Type, forResource name: String,extension ex:String?) -> T {

        guard let url = self.url(forResource: name, extension: ex) else {
            fatalError("Failed to locate \(name) in bundle.")

        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(name) from bundle.")

        }

        

        let decoder = JSONDecoder()

        

        guard let loaded = try? decoder.decode(T.self, from: data) else {

            fatalError("Failed to decode \(name) from bundle.")

        }

        

        return loaded

    }

    static func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {

        return self.decode(type, forResource: file, extension: nil)

    }
}
