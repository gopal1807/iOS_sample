//
//  LoginModel.swift
//  Exchange
//
//  Created by Gopal Krishan on 20/06/20.
//  Copyright © 2020 Gopal Krishan. All rights reserved.
//

import Foundation

// MARK: - LoginRequest
struct LoginRequest: Codable {
    let data: LoginRequestData
    let tID: String

    enum CodingKeys: String, CodingKey {
        case data
        case tID = "tId"
    }
}

// MARK: - DataClass
struct LoginRequestData: Codable {
    let username, password, deviceID, deviceType: String
    let /*fcmToken,*/ isApp: String
}
