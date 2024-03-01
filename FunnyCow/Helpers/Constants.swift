//
//  Constants.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 20/11/20.
//

import SwiftUI


let defaultMobUrl = Bundle.main.object(forInfoDictionaryKey: "DefaultMobUrl") as! String//"pockets1009madison"//"FCFF"//
let chainId = Bundle.main.object(forInfoDictionaryKey: "ChainId") as! Int//165//8
let iosAppShareId = Bundle.main.object(forInfoDictionaryKey: "iosAppShareId") as! String
let androidAppShareId = Bundle.main.object(forInfoDictionaryKey: "androidAppShareId") as? String ?? ""
let googleServiceFileName = Bundle.main.object(forInfoDictionaryKey: "googleServiceFileName") as! String
let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
let appCode = "921E396D-7F4A-4333-A558-4BF6C32DB73B"
let baseUrl = "https://orderonlinemenu.com/proxy/"
let menuImageBaseUrl = "https://s3.amazonaws.com/v1.0/images/menuitemimages/"
let menuSmallIconsBaseUrl = "https://s3.amazonaws.com/imenu-icons/menu-item-icons/"
let restaurantImageBaseUrl = "https://s3.amazonaws.com/v1.0/"
let staticToken = "463b7b6b-7c26-443f-9bda-67cb2a85980a"
let merchantId = "merchant.com.bellymelly.pockets"
var currencySymbol: String {
    UserDefaultsController.shared.cartSavedData?.otherInfo?.restaurant.currencyDetail.symbol ?? "$"
}
class AppToken {
    static let shared = AppToken()
    private init() {}
    
    var tid = ""
    
    func getToken(_ mobUrl: String = defaultMobUrl, completion: @escaping ((String) -> ())) {
        if !tid.isEmpty && mobUrl == defaultMobUrl {
            completion(tid)
            return
        }
        let body = GetNewTokenBody(appCode: appCode, data: GetTokenBodyData(mobURL: mobUrl, traceID: ""), mobURL: "http://www.imenu360.mobi/?id=" + mobUrl)
        HitApi.shared.postData("GetNewToken", bodyData: body) { (result: Result<GetNewTokenResponse, HitApiError>) in
            switch result {
            case .success(let result):
                self.tid = result.tID
                completion(result.tID)
            case .failure(let error):
                completion(error.toString())
                print(error.toString())
            }
        }
    }
}


extension Color {
    static let appGreen = Color("greenColor")
    static let appAccent = Color("AccentColor")
}
