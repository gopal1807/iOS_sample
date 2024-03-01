//
//  GetUserToken.swift
//  Exchange
//
//  Created by Gopal Krishan on 24/06/20.
//  Copyright © 2020 Gopal Krishan. All rights reserved.
//

import Foundation

// MARK: - GetUserCoupon
struct GetUserCoupon: Codable {
    let custCouponID: Int
    let issueDate, expDate, useDate, status: String
    let usageCountLeft: Int
    let name, getUserCouponDescription, couponCode, type: String
    let discount: Double
    let preTax, active, minOrderAmt, couponImage: String
//    let service: ServiceElement?
//    let paymentType: LocationDetailPaymentType?

    enum CodingKeys: String, CodingKey {
        case custCouponID = "CustCouponId"
        case issueDate = "IssueDate"
        case expDate = "ExpDate"
        case useDate = "UseDate"
        case status = "Status"
        case usageCountLeft = "UsageCountLeft"
        case name = "Name"
        case getUserCouponDescription = "Description"
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
