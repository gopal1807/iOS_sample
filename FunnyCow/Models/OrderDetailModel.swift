//
//  OrderDetailModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 29/12/20.
//

import Foundation

// MARK: - OrderDetailModel
struct OrderDetailModel: Codable {
    let orderID: Int
    let orderNumber, locationID, createdOn, status: String
    let specialInstructions, menuID, preTaxAmt, discountAmt: String
    let discountType: String
    let isDiscountPretax: Bool
    let discount1Amt, discount1Type: String
    let isPaymentDiscountPretax: Bool
    let couponAmt, custCouponID, couponType: String
    let isCouponPretax: Bool
    let taxAmt, srvcFee, tipAmt, totalAmt: String
    let serviceID, isSubmittedFeedback: String
    let itemList: [OrderDetailItemList]

    enum CodingKeys: String, CodingKey {
        case orderID = "OrderId"
        case orderNumber = "OrderNumber"
        case locationID = "LocationId"
        case createdOn = "CreatedOn"
        case status = "Status"
        case specialInstructions = "SpecialInstructions"
        case menuID = "MenuId"
        case preTaxAmt = "PreTaxAmt"
        case discountAmt = "DiscountAmt"
        case discountType = "DiscountType"
        case isDiscountPretax
        case discount1Amt = "Discount1Amt"
        case discount1Type = "Discount1Type"
        case isPaymentDiscountPretax
//        case restChainCouponID = "RestChainCouponId"
        case couponAmt = "CouponAmt"
        case custCouponID = "CustCouponId"
        case couponType = "CouponType"
        case isCouponPretax
        case taxAmt = "TaxAmt"
        case srvcFee = "SrvcFee"
        case tipAmt = "TipAmt"
        case totalAmt = "TotalAmt"
        case serviceID = "ServiceId"
        case isSubmittedFeedback
        case itemList = "ItemList"
    }
}

// MARK: - ItemList
struct OrderDetailItemList: Codable, Identifiable {
    let id: Int
    let name, itemListDescription, catID, catName: String
    let portionID, price: String
    let qty: String
    let specialInstructions, nameOfThePerson: String
    let itemAddOnList: [OrderDetailItemAddOnList]
//    let itemModList: [JSONAny]

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case itemListDescription = "Description"
        case catID = "CatId"
        case catName = "CatName"
        case portionID = "PortionId"
        case price = "Price"
//        case unitPrice = "UnitPrice"
        case qty = "Qty"
//        case amt = "Amt"
        case specialInstructions = "SpecialInstructions"
        case nameOfThePerson = "NameOfThePerson"
//        case discountAmt = "DiscountAmt"
//        case isTaxFree
        case itemAddOnList = "ItemAddOnList"
//        case itemModList = "ItemModList"
    }
}

// MARK: - ItemAddOnList
struct OrderDetailItemAddOnList: Codable, Identifiable {
    let id = UUID()
    let itemAddOnID: Int
    let name: String
    let addOnOptions: [OrderDetailAddOnOption]

    enum CodingKeys: String, CodingKey {
        case itemAddOnID = "ItemAddOnId"
        case name = "Name"
        case addOnOptions = "AddOnOptions"
    }
}

// MARK: - AddOnOption
struct OrderDetailAddOnOption: Codable, Identifiable {
    let id = UUID()
    let itemId: Int
    let name, portionID, price: String
//    let unitPrice, amt: JSONNull?
    let qty, dflt: String
    let isSelected: Bool
    let addOnOptionModifier1, addOnOptionModifier2: OrderDetailAddOnOptionModifier

    enum CodingKeys: String, CodingKey {
        case itemId = "Id"
        case name = "Name"
        case portionID = "PortionId"
        case price = "Price"
//        case unitPrice = "UnitPrice"
//        case amt = "Amt"
        case qty = "Qty"
        case dflt = "Dflt"
        case isSelected
        case addOnOptionModifier1 = "AddOnOptionModifier1"
        case addOnOptionModifier2 = "AddOnOptionModifier2"
    }
}

// MARK: - AddOnOptionModifier
struct OrderDetailAddOnOptionModifier: Codable {
    let label, text: String
    let factor: Double?

    enum CodingKeys: String, CodingKey {
        case label = "Label"
        case text = "Text"
        case factor = "Factor"
    }
}

// MARK: - OrderDetailRequestModel
struct TidData<D: Encodable>: Encodable {
    let data: D
    let tID: String

    enum CodingKeys: String, CodingKey {
        case data
        case tID = "tId"
    }
}

