//
//  UserDetailModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 20/11/20.
//

import Foundation

struct UserModel: Codable, Identifiable {
    let id: Int
    let globalUserId: Int
    let isExistsIMenuAccount: Int?
    let username: String?
//    isVerifiedPhone: String?
    var fName, mName, lName: String?
    let email: String?
    var tel: String?
    let cell, taxExempt, loyaltyPoints: String?
    let mobileOptIn: String?
    var orderHistory: [OrderHistory]?
    var addressBook: [AddressBook]?
    let coupons: [Coupon]?
//    let ccInfo: []
    let userid: String?
    var fullName: String {
        var name = [fName, mName, lName].compactMap({$0})
        name.removeAll(where: {$0.isEmpty})
        return name.joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case id, username
        case globalUserId = "GlobalUserId"
//        case isVerifiedPhone
        case fName = "FName"
        case email = "Email"
        case mName = "MName"
        case lName = "LName"
        case tel = "Tel"
        case cell = "Cell"
        case taxExempt = "TaxExempt"
        case loyaltyPoints = "LoyaltyPoints"
        case mobileOptIn = "MobileOptIn"
        case orderHistory = "OrderHistory"
        case addressBook = "AddressBook"
        case coupons = "Coupons"
//        case ccInfo = "CCInfo"
        case isExistsIMenuAccount, userid
    }
}

// MARK: - AddressBook
struct AddressBook: Codable, Identifiable {
    var id: Int {
        custAddressBookID
    }
    
    let custAddressBookID: Int
    let custAddressName, fName, lName, mName: String
    let addr1, addr2, city, state: String
    let zip, instructions, isPrimaryAddress, telephone: String
    let latitude, longitude: String

    enum CodingKeys: String, CodingKey {
        case custAddressBookID = "CustAddressBookId"
        case custAddressName = "CustAddressName"
        case fName = "FName"
        case lName = "LName"
        case mName = "MName"
        case addr1 = "Addr1"
        case addr2 = "Addr2"
        case city = "City"
        case state = "State"
        case zip = "ZIP"
        case instructions = "Instructions"
        case isPrimaryAddress = "IsPrimaryAddress"
        case telephone = "Telephone"
        case latitude = "Latitude"
        case longitude = "Longitude"
    }
    
    var fullName: String {
        var fName = [fName, mName, lName]
        fName.removeAll(where: {$0.isEmpty})
        return fName.joined(separator: " ")
    }
    
    var completeAddress: String {
        var address = [addr1, addr2, city, state, zip]
        address.removeAll(where: { $0.isEmpty })
        return address.joined(separator: ", ")
    }
}

// MARK: - Coupon
struct Coupon: Codable {
    let custCouponID: Int
    let issueDate, expDate, useDate, status: String
    let usageCountLeft: Int
    let name, couponDescription, couponCode, type: String
    let discount: Double
    let preTax, active, minOrderAmt, couponImage: String
//    let service, paymentType: JSONNull?

    enum CodingKeys: String, CodingKey {
        case custCouponID = "CustCouponId"
        case issueDate = "IssueDate"
        case expDate = "ExpDate"
        case useDate = "UseDate"
        case status = "Status"
        case usageCountLeft = "UsageCountLeft"
        case name = "Name"
        case couponDescription = "Description"
        case couponCode = "CouponCode"
        case type = "Type"
        case discount = "Discount"
        case preTax = "PreTax"
        case active = "Active"
        case minOrderAmt = "MinOrderAmt"
        case couponImage = "CouponImage"
//        case service = "Service"
//        case paymentType = "PaymentType"
    }
}

// MARK: - OrderHistory
struct OrderHistory: Codable, Identifiable {
    var id: Int { orderID }
    let orderID: Int
    let chainId: Int
    let locationId: Int
    let locationName: String
    let isSubmittedFeedback: String?
    let orderNumber, createdOn, status, totalAmt: String
    let paymentType, restService, couponCode, couponAmt: String
    let discountAmt, favorite, orderName: String

    enum CodingKeys: String, CodingKey {
        case isSubmittedFeedback
        case locationName = "LocationName"
        case orderID = "OrderId"
        case locationId = "LocationId"
        case chainId = "ChainId"
        case orderNumber = "OrderNumber"
        case createdOn = "CreatedOn"
        case status = "Status"
        case totalAmt = "TotalAmt"
        case paymentType = "PaymentType"
        case restService = "RestService"
        case couponCode = "CouponCode"
        case couponAmt = "CouponAmt"
        case discountAmt = "DiscountAmt"
        case favorite = "Favorite"
        case orderName = "OrderName"
    }
    
    func createdDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
        if let date = formatter.date(from: createdOn) {
            formatter.dateFormat = "MMMM dd, yyyy hh:mm a"
            return formatter.string(from: date)
        }
        return createdOn
    }
}
