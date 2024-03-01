//
//  DoLoginRequest.swift
//  Exchange
//
//  Created by Gopal Krishan on 24/06/20.
//  Copyright © 2020 Gopal Krishan. All rights reserved.
//

import UIKit

// MARK: - DoLoginRequest
struct DoLoginRequest: Codable {
    let data: DoLoginRequestData
    let tID: String

    enum CodingKeys: String, CodingKey {
        case data
        case tID = "tId"
    }
}

// MARK: - DataClass
struct DoLoginRequestData: Codable {
    let custID: Int
    let DeviceType: String = "2"
    var isApp = "1"
    enum CodingKeys: String, CodingKey {
        case custID = "custId"
        case DeviceType
        case isApp
    }
}

// MARK: - GlobalUserLoginModel
struct GlobalUserLoginModel: Codable {
    let data: GlobalUserLoginData
    let tID: String

    enum CodingKeys: String, CodingKey {
        case data
        case tID = "tId"
    }
}

// MARK: - DataClass
struct GlobalUserLoginData: Codable {
    let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
    let deviceType = "2"
//    let fcmToken = UserDefaultsController.shared.fcmToken
    let globalUserID: String
    let chainID = chainId
    let isApp: String = "1"
    let isBMPortal: Int = 1
    let locationtid: String

    enum CodingKeys: String, CodingKey {
        case deviceID = "DeviceId"
        case deviceType = "DeviceType"
//        case fcmToken = "FCMToken"
        case globalUserID = "GlobalUserId"
        case chainID = "chainId"
        case isApp, isBMPortal, locationtid
    }
}

struct DologinByCust: Codable {
    let data: DoLoginCustData
    let tId: String
}


struct DoLoginCustData: Codable {
    let custId: Int
//    var FCMToken: String = UserDefaultsController.shared.fcmToken
}
