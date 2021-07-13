//
//  Webservices.swift
//  GenericApi
//
//  Created by Hitesh  on 22/10/19.
//  Copyright © 2019 Hitesh . All rights reserved.
//

import UIKit
import Alamofire

final class Webservices: NSObject {
    static let instance = Webservices()
    private override init() {
        
    }
    
    static var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    
    static var deviceIpAddress : String {
            var address: String = ""
            var ifaddr:UnsafeMutablePointer<ifaddrs>?
            if getifaddrs(&ifaddr) == 0 {
                var ptr = ifaddr
                while ptr != nil {
                    defer { ptr = ptr?.pointee.ifa_next }
                    
                    let interface = ptr?.pointee
                    let addrFamily = interface?.ifa_addr.pointee.sa_family
                    if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                        
                        let name: String = String(cString: (interface?.ifa_name)!)
                        if name == "en0" {
                            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                            getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                            address = String(cString: hostname)
                            print("ip address : \(address)")
                         }
                    }
                }
                freeifaddrs(ifaddr)
            }
             return address
        }
    
    // post
    func post<T:Codable,M:Codable>(url:String,params:[String:Any], headers:HTTPHeaders?=nil, completion: @escaping (T?,M?, _ error:String?) -> ()){
        
        if Webservices.isConnectedToInternet == false {
            completion(nil,nil,ErrorMessages.no_internet)
            return
        }
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseData { (response) in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let data):
                    do {
                        if response.response?.statusCode != 400{
                            let model = try JSONDecoder().decode(T.self, from: data)
                            completion(model,nil,nil)
                        }else{
                            let model = try JSONDecoder().decode(M.self, from: data)
                            completion(nil,model,nil)
                        }
                    } catch let jsonErr {
                        completion(nil,nil,jsonErr.localizedDescription)
                    }
                case .failure(let err):
                    completion(nil,nil,err.localizedDescription)
                }
            }
        }
    }
    
    
    

 
    // get
    func get<T:Codable>(url:String,params:[String:Any]?, completion: @escaping (T?, _ error:String?) -> ()) {
        
        if Webservices.isConnectedToInternet == false {
            completion(nil,ErrorMessages.no_internet)
            return
        }
        
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseData { (response) in
            switch response.result {
            case .success(let data):
                do {
                    let model = try JSONDecoder().decode(T.self, from: data)
                    completion(model,nil)
                } catch let jsonErr {
                    completion(nil,jsonErr.localizedDescription)
                }
            case .failure(let err):
                completion(nil,err.localizedDescription)
            }
        }
    }
    
    // cancel pending requests
    func cancelPendingRequests(){
        Alamofire.Session.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    

    
    func downloadAndLoadFromLocal(url: URL, completion: @escaping (_ savedUrl:URL?,_ error:String?) -> Void) {
        
        if Webservices.isConnectedToInternet == false {
            completion(nil,ErrorMessages.no_internet)
            return
        }
        
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = try! URLRequest(url: url, method: .get)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                
                do {
                    let savepath = self.createNewDirPath()
                    try FileManager.default.copyItem(at: tempLocalUrl, to: savepath)
                    completion(savepath, nil)
                } catch (let writeError) {
                    print("error writing file \(self.createNewDirPath()) : \(writeError)")
                    completion(nil,writeError.localizedDescription)
                }
                
            } else {
                print("Failure: %@", error?.localizedDescription)
                completion(nil,error!.localizedDescription)
            }
        }
        task.resume()
        
    }
    
    func createNewDirPath( )->URL{
        
        let dirPathNoScheme = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        //add directory path file Scheme;  some operations fail w/out it
        let dirPath = "file://\(dirPathNoScheme)"
        //name your file, make sure you get the ext right .mp3/.wav/.m4a/.mov/.whatever
        let fileName = "\(String.random()).pdf"
        let pathArray = [dirPath, fileName]
        let path = URL(string: pathArray.joined(separator: "/"))
        
        //use a guard since the result is an optional
        guard let filePath = path else {
            //if it fails do this stuff:
            return URL(string: "choose how to handle error here")!
        }
        //if it works return the filePath
        return filePath
    }
}
