//
//  AddAddressRequest.swift
//  Exchange
//
//  Created by Gopal Krishan on 29/06/20.
//  Copyright © 2020 Gopal Krishan. All rights reserved.
//

import Foundation


// MARK: - AddAddressRequest
struct AddAddressRequest: Codable {
    let data: AddAddressRequestData
    let tID: String

    enum CodingKeys: String, CodingKey {
        case data
        case tID = "tId"
    }
}

// MARK: - DataClass
struct AddAddressRequestData: Codable {
    let customerAddress: CustomerAddress
}

// MARK: - CustomerAddress
struct CustomerAddress: Codable {
    let addr1, addr2, addrName, city: String
    let custID: Int
    let fName, instr: String
    let isPrimary: Int
    let lName: String
    let lat, lon: Double
    let mName, state, tel, zip: String
    let custAddrId: Int?

    enum CodingKeys: String, CodingKey {
        case addr1, addr2, addrName, city, custAddrId
        case custID = "custId"
        case fName, instr, isPrimary, lName, lat, lon, mName, state, tel, zip
    }
}

// MARK: - AddAddressResponse
struct AddAddressResponse: Codable {
    let addressBook: AddressBook

    enum CodingKeys: String, CodingKey {
        case addressBook = "AddressBook"
    }
}
