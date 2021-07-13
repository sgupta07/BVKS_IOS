//
//  DonationViewModel.swift
//  Bhakti_Vikasa
//
//  Created by harishkumar on 16/02/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import Foundation
import Alamofire
class DonationViewModel:NSObject{
    static let instance = DonationViewModel()
    private override init() {
        
    }
    
    static var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    
    
    func genrateOrderID(url:String,params:[String:Any], headers:HTTPHeaders?=nil, completion: @escaping (RazorPayOrder?,RazorPayError_Ordar?, _ error:String?) -> ()){
        
        if Webservices.isConnectedToInternet == false {
            completion(nil,nil,ErrorMessages.no_internet)
            return
        }
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseData { (response) in
            switch response.result {
            case .success(let data):
                do {
                    if response.response?.statusCode == 400{
                        let errorModel = try JSONDecoder().decode(RazorPayError_Ordar.self, from: data)
                        completion(nil,errorModel,nil)
                    }else{
                        let model = try JSONDecoder().decode(RazorPayOrder.self, from: data)
                        completion(model,nil,nil)
                    }
                    
                } catch let jsonErr {
                    print("catch")
                    completion(nil,nil,jsonErr.localizedDescription)
                }
            case .failure(let err):
                print("FAIL")
                completion(nil,nil,err.localizedDescription)
            }
        }
    }
}
