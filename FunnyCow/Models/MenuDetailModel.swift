//
//  MenuDetailModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 21/11/20.
//

import Foundation

// MARK: - RestaurantMenuResponse
struct RestaurantMenuResponse: Codable {
    let menuID: Int
    let name, desc: String
    let asap, lt, fo: AppBool
    var catList: [CatList]
    let imageRepository: [ImageRepository]?

    enum CodingKeys: String, CodingKey {
        case menuID = "MenuId"
        case name = "Name"
        case desc = "Desc"
        case asap = "ASAP"
        case lt = "LT"
        case fo = "FO"
        case catList, imageRepository
    }
}

// MARK: - ImageRepository
struct ImageRepository: Codable {
    let posItemID, posItemImage: String?
    let itemDesc: String?
    enum CodingKeys: String, CodingKey {
        case itemDesc = "ItemDesc"
        case posItemID = "POSItemId"
        case posItemImage = "POSItemImage"
    }
}

// MARK: - CatList
struct CatList: Codable, Identifiable {
    var id: Int {
        return catID
    }
    let catID: Int
    let catName, desc: String
    let p1: PriceDetail?
    let p2, p3, p4, p5: PriceDetail?
    let p6: PriceDetail?
    let catType: String
    let isShowItemImages: String
    var itemList: [ItemList]
    let openTime, closeTime: String

    enum CodingKeys: String, CodingKey {
        case catID = "CatId"
        case catName = "CatName"
        case desc = "Desc"
        case p1 = "P1"
        case p2 = "P2"
        case p3 = "P3"
        case p4 = "P4"
        case p5 = "P5"
        case p6 = "P6"
        case catType = "CatType"
        case isShowItemImages
        case itemList = "ItemList"
        case openTime = "OpenTime"
        case closeTime = "CloseTime"
    }
}

// MARK: - P1
struct PriceDetail: Codable {
    let id: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
    }
}
