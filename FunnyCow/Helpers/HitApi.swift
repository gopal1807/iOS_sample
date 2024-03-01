//
//  HitApi.swift
//  Exchange
//
//  Created by Gopal Krishan on 14/06/20.
//  Copyright © 2020 Gopal Krishan. All rights reserved.
//

import UIKit
import SystemConfiguration

enum HitApiError: Error {
    case noInternet
    case invalidUrl
    case generalError(err: Error)
    case dataCurrupt
    case notValidJson
    case dataNull(String)
    
    func toString() -> String {
        switch self {
        case .dataCurrupt:
            return "Unable to read the data"
        case .noInternet:
            return "Please check your internet connection"
        case .invalidUrl:
            return "URL is invalid"
        case .generalError(err: let err):
            return err.localizedDescription
        case .notValidJson:
            return "Response was not valid"
        case .dataNull(let data):
            return data
        }
    }
}

class HitApi {
    static let shared = HitApi()
    
    private init() {}
        
    func postData<T: Decodable, E: Encodable>(_ endPoint: String, bodyData: E, completion: @escaping (( Result<T, HitApiError>) -> ())) {
        
        guard isConnected() else {
            completion(.failure(.noInternet))
            return
        }
        
        guard let url = URL(string: baseUrl + endPoint + ".imsvc") else {
            completion(.failure(.invalidUrl))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let data = try? JSONEncoder().encode(bodyData) else {
            print("bad body request data")
            return
        }
        let newData = ["postData": data.base64EncodedString()]
        request.httpBody = try? JSONSerialization.data(withJSONObject: newData, options: [])
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { (data, resp, error) in
            
            DispatchQueue.main.async {
                
                if let err =  error {
                    completion(.failure(.generalError(err: err)))
                    return
                }
                guard let data = data else {
                    completion(.failure(.dataCurrupt))
                    return
                }
                
                do {
                    if T.self == APIStatusReponse.self {
                        let dd = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(dd))
                        return
                    }
                    let obj = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    guard let jsonGot = obj as? [String: Any] else {
                        completion(.failure(.notValidJson))
                        return
                    }
                    
                    guard let data = jsonGot["data"] as? String else {
                        completion(.failure(.dataNull(jsonGot["message"] as? String ?? "Something went wrong")))
                        return
                    }
                    guard let status = jsonGot["serviceStatus"] as? String, status == "S" else {
                        if let content = Data(base64Encoded: data),
                           let responseErr = try? JSONDecoder().decode(SetOrderResponse.self, from: content),
                           let error = responseErr.errorInfo?.first?.first?.value {
                            completion(.failure(.dataNull(error)))
                        } else {
                            completion(.failure(.dataNull(jsonGot["message"] as? String ?? "Something went wrong")))
                            
                        }
                        return
                    }
                    if let jsonDecoded = Data(base64Encoded: data) {
                        //                    print(String(decoding: jsonDecoded, as: UTF8.self))
                        let dd = try JSONDecoder().decode(T.self, from: jsonDecoded)
                        completion(.success(dd))
                    }
                    
                } catch let err {
                    print(err)
                    completion(.failure(.generalError(err: err)))
                }
            }
        }.resume()
    }
    
    private func isConnected() -> Bool {
             var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
           zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
           zeroAddress.sin_family = sa_family_t(AF_INET)

           let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
               $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                   SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
               }
           }

           var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
           if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
               return false
           }

           /* Only Working for WIFI
           let isReachable = flags == .reachable //.contains
           let needsConnection = flags == .connectionRequired

           return isReachable && !needsConnection
           */

           // Working for Cellular and WIFI
           let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
           let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
           let ret = (isReachable && !needsConnection)

           return ret
    }
}


let imageCache = NSCache<NSString, UIImage>()

class UrlImageView: UIImageView {
    var string: String?
    
    func setImageView(with urlStr: String, placeholderImage: UIImage? = nil, isTemplate: Bool = false, showNoImage: Bool = false) {
        if let placeholder = placeholderImage {
            
            self.image = isTemplate ? placeholder.withRenderingMode(.alwaysTemplate) : placeholder
        }
        guard let urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        self.string = urlStr
       
        if let image = imageCache.object(forKey: urlStr as NSString) {
            self.image = isTemplate ? image.withRenderingMode(.alwaysTemplate) : image
            return
        }
        guard let url = URL(string: self.string ?? "") else { return }
        URLSession.shared.dataTask(with: url) { data, resp, error in
            DispatchQueue.main.async {
                if let err = error {
                    print(err.localizedDescription)
                    if showNoImage {
                        self.image = #imageLiteral(resourceName: "broken")
                    }
                    return
                }
                
                if self.string == url.absoluteString {
                    guard let data = data, let image = UIImage(data: data) else {
                        if showNoImage {
                            self.image = #imageLiteral(resourceName: "broken")
                        }
                        return
                    }
                    self.image = isTemplate ? image.withRenderingMode(.alwaysTemplate) : image
                    imageCache.setObject(isTemplate ? image.withRenderingMode(.alwaysTemplate) : image, forKey: url.absoluteString as NSString)
                }
            }
        }.resume()
        
    }
}
