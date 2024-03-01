//
//  GoogleSignInModel.swift
//  Exchange
//
//  Created by Gopal Krishan on 14/06/20.
//  Copyright © 2020 Gopal Krishan. All rights reserved.
//

import UIKit

// MARK: - SocialLoginRequest
struct SocialLoginRequest: Codable {
    let data: SocialLoginRequestData
    let tID: String

    enum CodingKeys: String, CodingKey {
        case data
        case tID = "tId"
    }
}

// MARK: - DataClass
struct SocialLoginRequestData: Codable {
    let customerfbdata: Customerfbdata
}

// MARK: - Customerfbdata
struct Customerfbdata: Codable {
    let fID: String
    let fName, fbemail, lName: String?
    let logintype: String

    enum CodingKeys: String, CodingKey {
        case fID = "FId"
        case fName = "FName"
        case fbemail
        case lName = "LName"
        case logintype
    }
}



// MARK: - APIStatusReponse
struct APIStatusReponse: Codable {
    let serviceName, serviceStatus: String
    let message: String?
}

// MARK: - DoGoogleLoginRequest
struct DoGoogleLoginRequest: Codable {
    let tID: String
    var data: DoGoogleLoginRequestData
    let checkOTP: Int?

    enum CodingKeys: String, CodingKey {
        case tID = "tId"
        case data, checkOTP
    }
}

// MARK: - DataClass
struct DoGoogleLoginRequestData: Codable {
    let customerFBData: Customerfbdata
    var customerData: DoGoogleLoginCustomerData
    let checkOTP: Int
    var deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
    var deviceType = "2"
//    let fcmToken = UserDefaultsController.shared.fcmToken
    var isApp = "1"
}

// MARK: - CustomerData
struct DoGoogleLoginCustomerData: Codable {
    var tel, otp: String
    let mobileOptIn: Int

    enum CodingKeys: String, CodingKey {
        case tel
        case otp = "OTP"
        case mobileOptIn = "MobileOptIn"
    }
}

