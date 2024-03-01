//
//  ChainDetailModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 19/11/20.
//

import Foundation

// MARK: - ChainDetails
struct ChainDetails: Codable, Identifiable {
    let id: Int
    let name, desc, tel, fax: String
    let email: String
    let loyaltyRulesCnt: Int
    let locationList: [ChainLocationDetail]

    enum CodingKeys: String, CodingKey {
        case id
        case name = "Name"
        case desc = "Desc"
        case tel = "Tel"
        case fax = "Fax"
        case email = "Email"
        case loyaltyRulesCnt = "LoyaltyRulesCnt"
        case locationList = "LocationList"
    }
}

// MARK: - LocationList
struct ChainLocationDetail: Codable, Identifiable {
    let id: Int
    let name: String
    let address: Address
    let tel: String
    let lon, lat, tax: Double
    let miscMask, urlName, active: String
    let isUnlinkedForPortal: Bool

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case address = "Address"
        case tel = "Tel"
        case lon = "Lon"
        case lat = "Lat"
        case tax = "Tax"
        case miscMask = "MiscMask"
        case urlName = "UrlName"
        case active = "Active"
        case isUnlinkedForPortal
    }
}

// MARK: - Address
struct Address: Codable {
    let addressLine1, addressLine2, city, state: String
    let country, zip: String

    enum CodingKeys: String, CodingKey {
        case addressLine1 = "AddressLine1"
        case addressLine2 = "AddressLine2"
        case city = "City"
        case state = "State"
        case country = "Country"
        case zip = "Zip"
    }
    
    func toString() -> String {
        var address = [addressLine1, addressLine2, city, state, zip]
        address.removeAll(where: { $0.isEmpty })
        return address.joined(separator: ", ")
    }
}
