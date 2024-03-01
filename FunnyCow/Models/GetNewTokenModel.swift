//
//  GetNewTokenModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 20/11/20.
//

import Foundation

// MARK: - GetNewTokenBody
struct GetNewTokenBody: Codable {
    let appCode: String
    let data: GetTokenBodyData
    let mobURL: String

    enum CodingKeys: String, CodingKey {
        case appCode = "AppCode"
        case data
        case mobURL = "mobUrl"
    }
}

// MARK: - DataClass
struct GetTokenBodyData: Codable {
    let mobURL, traceID: String
    let GlobalUserId: String = String(UserDefaultsController.shared.userModel?.id ?? 0)

    enum CodingKeys: String, CodingKey {
        case mobURL = "mobUrl"
        case traceID = "TraceId"
        case GlobalUserId
    }
}

struct GetNewTokenResponse: Codable {
    let tID: String
    let locationID, chainID: Int
    let locationCurrentDate, currentDateTime: String
//    let wclURL: String
//    let wlcDetails: WLCDetails
//    let setOrderInfo, orderNumber, custInfo: JSONNull?
//    let isRetainTraceID: String
//    let gatewayInfo: JSONNull?

    enum CodingKeys: String, CodingKey {
        case tID = "tId"
        case locationID = "locationId"
        case chainID = "chainId"
        case locationCurrentDate
        case currentDateTime = "CurrentDateTime"
//        case wclURL = "WCLUrl"
//        case wlcDetails = "WLCDetails"
//        case setOrderInfo, orderNumber, custInfo
//        case isRetainTraceID = "isRetainTraceId"
//        case gatewayInfo
    }

}

// MARK: - WLCDetails
struct WLCDetails: Codable {
    let wlcID, defaultURL, mDefaultURL, errorURL: String
    let mErrorURL, inactiveURL, mInactiveURL, maintenanceURL: String
    let mMaintenanceURL: String

    enum CodingKeys: String, CodingKey {
        case wlcID = "WlcId"
        case defaultURL = "DefaultURL"
        case mDefaultURL
        case errorURL = "ErrorURL"
        case mErrorURL
        case inactiveURL = "InactiveURL"
        case mInactiveURL
        case maintenanceURL = "MaintenanceURL"
        case mMaintenanceURL
    }
}
