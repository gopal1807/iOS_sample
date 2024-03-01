//
//  SetOrderRequest.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 20/11/20.
//

import Foundation


// MARK: - SetOrderRequest
struct SetOrderRequest: Codable {
    var data: SetOrderRequestData
    var tID: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case tID = "tId"
    }
}

// MARK: - DataClass
struct SetOrderRequestData: Codable {
    var orderData: OrderData
}

// MARK: - OrderData
struct OrderData: Codable {
    var dineInTableNum: String
    var otherInfo: OtherData?
    var specialInstructions: String?
    var aafesPayTraceID: String?
    var carcolor, carmake, carmodel, carplatenumber: String?
    var ccInfo: CCInfo?
    var couponType: Int?
    var couponAmt: Double?
    var couponDescription: String?
    var createdOn: String?
    var custCouponID: Int?
    var custID: Int?
    var deliveryInfo: DeliveryInfo?
    var discountAmt, discountType, discount1Amt, discount1Type: String?
    var dueOn: String?
//    var isAAFESPayGateway: Int? //1 if online else 0
    var isPrinterMsgOk: String?
    var itemList: [SelectedItemDetail]?
    var locationID: Int?
    var menuID: Int?
    //    var mercuryPaymentID, oldOrderID= nil
    var paymentTypeID: Int?
    //    var paypalPayerID, paypalSecureToken= nil
    var placeOrder: String?
    var preTaxAmt: Double?
    var restChainCouponID: Int?
    var restChainID, serviceID,  status: Int?
    var srvcFee: Double?
    var restServiceAmt: Double?
    var taxAmt: Double?
    var timeSelection: Int?
    var tipAmt: Double?
    var totalAmt: Double?
    var utmSource: String?
    var stripeToken: String?
    var delzoneInd: Int?
    var donateCode: String?
    var donateValue: Double = 0
    var orderFrom: String
    var ngoID: Int = 0
    var dueOnDate: Date? {
        let formatter = DateFormatter()
        formatter.timeZone = Calendar.cstCalendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        guard let dd = dueOn, let date = formatter.date(from: dd) else { return nil
        }
        return date
    }
    
    enum CodingKeys: String, CodingKey {
        case restServiceAmt = "RestServiceAmt"
        case donateCode = "DonateCode"
        case donateValue = "DonateValue"
        case dineInTableNum = "DineInTableNum"
        case otherInfo
        case orderFrom = "OrderFrom"
        case ngoID = "NGOId"
        case specialInstructions = "SpecialInstructions"
//        case aafesPayTraceID = "AAFESPayTraceId"
        case carcolor, carmake, carmodel, carplatenumber
        case ccInfo = "CCInfo"
        case couponAmt = "CouponAmt"
        case couponType = "CouponType"
        case createdOn = "CreatedOn"
        case custCouponID = "CustCouponId"
        case custID = "CustId"
        case deliveryInfo = "DeliveryInfo"
        case delzoneInd = "DelzoneInd"
        case discount1Amt = "Discount1Amt"
        case discount1Type = "Discount1Type"
        case discountAmt = "DiscountAmt"
        case discountType = "DiscountType"
        case dueOn = "DueOn"
//        case isAAFESPayGateway
        case isPrinterMsgOk
        case itemList = "ItemList"
        case locationID = "LocationId"
        case menuID = "MenuId"
        //        case mercuryPaymentID = "MercuryPaymentId"
        //        case oldOrderID = "OldOrderId"
        case paymentTypeID = "PaymentTypeId"
        //        case paypalPayerID = "PaypalPayerId"
        //        case paypalSecureToken = "PaypalSecureToken"
        case placeOrder = "PlaceOrder"
        case preTaxAmt = "PreTaxAmt"
        case restChainCouponID = "RestChainCouponId"
        case restChainID = "RestChainId"
        case serviceID = "ServiceId"
        case srvcFee = "SrvcFee"
        case status = "Status"
        case taxAmt = "TaxAmt"
        case timeSelection = "TimeSelection"
        case tipAmt = "TipAmt"
        case totalAmt = "TotalAmt"
        case utmSource = "utm_source"
        case stripeToken = "StripeToken"
    }
}


// MARK: - CCInfo
struct CCInfo: Codable {
    let ccType: Int?
    let date, hacode, ccAddr1, ccAddr2: String?
    let cccvv, ccCity, ccExpDate, ccfName: String?
    let cclName, ccmName, ccNumber, ccState: String?
    let cczip: String?
    let service: Int?
    let time, tipPaidbBy, txtPaytronixGiftCard: String?
    let tipAmount: Double
    
    enum CodingKeys: String, CodingKey {
        case ccType = "CCType"
        case date, hacode
        case ccAddr1 = "CCAddr1"
        case ccAddr2 = "CCAddr2"
        case cccvv = "CCCVV"
        case ccCity = "CCCity"
        case ccExpDate = "CCExpDate"
        case ccfName = "CCFName"
        case cclName = "CCLName"
        case ccmName = "CCMName"
        case ccNumber = "CCNumber"
        case ccState = "CCState"
        case cczip = "CCZIP"
        case service
//        case stripeToken = "StripeToken"
        case time, tipPaidbBy, txtPaytronixGiftCard,tipAmount
    }
}

// MARK: - DeliveryInfo
struct DeliveryInfo: Codable {
    var addr1, addr2: String?
    var addressID: Int?
    var city, custAddressName: String?
    var fName, mName, lName: String?
    var instructions: String?
    var latitude, longitude: Double?
    var state, zip: String?
    var name, telephone: String
    
    enum CodingKeys: String, CodingKey {
        case addr1 = "Addr1"
        case addr2 = "Addr2"
        case addressID = "AddressId"
        case city = "City"
        case custAddressName = "CustAddressName"
        case fName = "FName"
        case instructions = "Instructions"
        case lName = "LName"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case mName = "MName"
        case name = "Name"
        case state = "State"
        case telephone = "Telephone"
        case zip = "Zip"
    }
    
    func toString() -> String {
        var address = [addr1, addr2, city, state, zip].compactMap { $0 }
        address.removeAll(where: { $0.isEmpty })
        let nameDetail = address.joined(separator: ", ") + "\n" + name + " " + telephone
        return nameDetail
    }
}

// MARK: - ItemList
struct SelectedItemDetail: Codable, Identifiable {
    var id: UUID {
        return myid
    }
    let myid: UUID
    var amt: Double
    var categoryID: Int
    var havespicialoffer: Bool
    var havespicialofferAmount: Double
    var itemId: Int
    var itemAddOnList: [ItemAddOnList]?
    //    var itemModList: [Any]? = nil
    var name: String
    var portionID: Int?
    var qty: Int
    var specialInstructions: String
    var unitPrice: Double
    let minQ: Int
    let maxQ: Int
    let isTaxFree, isAllowCoupon, isAllowDiscount: Bool
    let categoryData: SelectedCatData
    let specialOffer: SpecialOffer?
    
    enum CodingKeys: String, CodingKey {
        case amt = "Amt"
        case myid, minQ, maxQ
        case categoryID = "categoryId"
        case havespicialoffer, havespicialofferAmount
        case itemId = "Id"
        case itemAddOnList = "ItemAddOnList"
        //        case itemModList = "ItemModList"
        case name = "Name"
        case portionID = "PortionId"
        case qty = "Qty"
        case specialInstructions = "SpecialInstructions"
        case unitPrice = "UnitPrice"
        case isTaxFree, isAllowDiscount, isAllowCoupon, categoryData
        case specialOffer
    }
}

struct SelectedCatData: Codable {
    let id: Int
    let name: String
    let openTime, closeTime: String
    
    private func stringToDate(openTime: String, calender: Calendar, date: Date) -> Date {
        let values = openTime.components(separatedBy: ":")
        let hour: Int = Int(values.first ?? "0") ?? 0
        let min: Int = Int(values.indices.contains(1) ? values[1] : "0") ?? 0
        let sec: Int = Int(values.indices.contains(2) ? values[2] : "0") ?? 0
        if let bigDate = calender.date(bySettingHour: 0, minute: 0, second: 0, of: date, matchingPolicy: .strict, direction: .backward),
           let returnDate = calender.date(bySettingHour: hour, minute: min, second: sec, of: bigDate, matchingPolicy: .strict, direction: .forward) {
            return returnDate
        }
        return date
    }
    
    func isAvailable(on date: Date, calender: Calendar) -> Bool {
        if  (openTime == "00:00:00" && closeTime == "00:00:00") {
            return true
        } else {
            let openTime = stringToDate(openTime: self.openTime, calender: calender, date: date)
            var closeTime = stringToDate(openTime: self.closeTime, calender: calender, date: date)
            if closeTime < openTime {
                closeTime = closeTime.addingTimeInterval(86400)
            }
            if date >= openTime && date <= closeTime {
                return true
            }
        }
        return false
    }
}

// MARK: - ItemAddOnList
struct ItemAddOnList: Codable, Identifiable {
    var id: Int {
        itemAddOnID
    }
    var addOnOptions: [CartAddOnOption]
    var itemAddOnID: Int
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case addOnOptions = "AddOnOptions"
        case itemAddOnID = "ItemAddOnId"
        case name = "Name"
    }
}

// MARK: - AddOnOption
struct CartAddOnOption: Codable, Identifiable {
    var addOnOptionModifier1: CartAddOnOptionModifier1?
    var addOnOptionModifier2: CartAddOnOptionModifier1?
    var amt: Double
    //    var dflt, displayType: JSONNull?
    var id: Int
    var isSelected: Bool
    var name: String
    var portionID: Int?
    var qty: Int
    var unitPrice: Double
    
    enum CodingKeys: String, CodingKey {
        case addOnOptionModifier1 = "AddOnOptionModifier1"
        case addOnOptionModifier2 = "AddOnOptionModifier2"
        case amt = "Amt"
        //        case dflt = "Dflt"
        //        case displayType = "DisplayType"
        case id = "Id"
        case isSelected
        case name = "Name"
        case portionID = "PortionId"
        case qty = "Qty"
        case unitPrice = "UnitPrice"
    }
}

// MARK: - AddOnOptionModifier1
struct CartAddOnOptionModifier1: Codable {
    var factor: Double
    var label, text: String
    
    enum CodingKeys: String, CodingKey {
        case factor = "Factor"
        case label = "Label"
        case text = "Text"
    }
}


struct TempOrderDetails {
    var custId: Int? = nil
    var restaurant: RestaurantModel? = nil
    var suggestedMenu: [SuggestedMenu]? = nil
    var mobUrl: String?
    var menuId: Int? = nil
    var isAsap: Bool? = nil
    var isToday: Bool? = nil
    var isFuture: Bool? = nil
}

struct SuggestedMenu: Codable, Identifiable {
    var id = UUID()
    let item: ItemList
    let category: CatList
}

// MARK: - SetOrderResponse
struct SetOrderResponse: Codable {
    let orderNumber, orderID: String?
    let traceID: traceIDValue?
    let errorInfo: [[String: String]]?
    
    enum CodingKeys: String, CodingKey {
        case orderNumber = "OrderNumber"
        case orderID = "OrderId"
        case traceID = "TraceId"
        case errorInfo = "ErrorInfo"
    }
}

enum traceIDValue: Codable {
    case string(String)
    case int(Int)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(Int.self) {
            self = .int(x)
            return
        }
        throw DecodingError.typeMismatch(traceIDValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for MyValue"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .string(let x):
                try container.encode(x)
            case .int(let x):
                try container.encode(x)
        }
    }
    
    func value() -> String {
        switch self {
            case .string(let s):
                return s
            case .int(let i):
                return String(i)
        }
    }
}

struct OtherData: Codable {
    var isSpecialSelected: Bool = false
    var restaurant: RestaurantModel
    var restaurantSavedAt: Date
    let cartSuggestedMenu: [SuggestedMenu]
    var lastAppliedCoupon: RestaurantCoupon?
    var lastAppliedDiscount1: Discount?
    var lastAppliedDiscount2: Discount?
    let mobUrl: String
    let isAsap: Bool
    let isToday: Bool
    let isFuture: Bool
}


// MARK: - ItemList
struct ItemList: Codable, Identifiable {
    let id: Int
    let name, desc: String
    let minQ, maxQ: Int
    let minP, maxP: Double
    let p1, p2, p3, p4: Double
    let p5: Double
    let p6: Double
    let img, icon1, icon2, icon3, icon4: String
    let isShowforSuggestion: String
    let posItemID: String?
    let isTaxFree, isAllowCoupon, isAllowDiscount: Bool
    let openOn: OpenOn
    let specialOffer: SpecialOffer?
    var addOnList: [AddOnList]
    let newIcon1, newIcon2, newIcon3, newIcon4: String
    //    let itemModList: [JSONAny]
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case desc = "Desc"
        case minQ = "MinQ"
        case maxQ = "MaxQ"
        case minP = "MinP"
        case maxP = "MaxP"
        case p1 = "P1"
        case p2 = "P2"
        case p3 = "P3"
        case p4 = "P4"
        case p5 = "P5"
        case p6 = "P6"
        case img = "Img"
        case icon1 = "Icon1"
        case icon2 = "Icon2"
        case icon3 = "Icon3"
        case icon4 = "Icon4"
        case isTaxFree, isAllowCoupon, isAllowDiscount, isShowforSuggestion
        case posItemID = "POSItemId"
        case openOn = "OpenOn"
        case specialOffer = "SpecialOffer"
        case addOnList = "AddOnList"
        //        case itemModList = "ItemModList"
        case newIcon1, newIcon2, newIcon3, newIcon4
    }
    
    func getIcons() -> [String] {
        let icons = [icon1, icon2, icon3, icon4, newIcon1, newIcon2, newIcon3, newIcon4]
        return icons.filter({!$0.isEmpty})
    }
    
    func getSomePrice() -> Double {
        return [p1, p2, p3, p4, p5].filter({$0 >= 0}).first ?? 0
    }
    
    func getImage(imageRepos: [ImageRepository]) -> String {
        let image = imageRepos.first(where: {$0.posItemID == posItemID})
        return image?.posItemImage ?? img
    }
    
    func getDescription(imageRepos: [ImageRepository]) -> String {
        let image = imageRepos.first(where: {$0.posItemID == posItemID})
        return image?.itemDesc ?? desc
    }
    
}

// MARK: - AddOnList
struct AddOnList: Codable, Identifiable {
    let id, itemAddOnID: Int
    let name: String
    let desc: String
    let dispType: String
    let reqd: AppBool
    var min, max: Int
    let dsplyPrice: AppBool
    var addOnOptions: [AddOnOption]
    let addOnOptionModifier1: AddOnOptionModifier1?
    let addOnOptionModifier2: AddOnOptionModifier1?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case itemAddOnID = "ItemAddOnId"
        case name = "Name"
        case desc = "Desc"
        case dispType = "DispType"
        case reqd = "Reqd"
        case min = "Min"
        case max = "Max"
        case dsplyPrice = "DsplyPrice"
        case addOnOptions = "AddOnOptions"
        case addOnOptionModifier1 = "AddOnOptionModifier1"
        case addOnOptionModifier2 = "AddOnOptionModifier2"
    }
}


// MARK: - SpecialOffer
struct SpecialOffer: Codable {
    let id: Int
    let name: String
    let preTax: AppBool
    let amt1: Double
    let amt2, amt3: Double?
    let discountType, discountAmt1: Int
    let discountAmt2, discountAmt3: Int?
    let allowDiscount, allowCoupon: AppBool
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case preTax = "PreTax"
        case amt1 = "Amt1"
        case amt2 = "Amt2"
        case amt3 = "Amt3"
        case discountType = "DiscountType"
        case discountAmt1 = "DiscountAmt1"
        case discountAmt2 = "DiscountAmt2"
        case discountAmt3 = "DiscountAmt3"
        case allowDiscount = "AllowDiscount"
        case allowCoupon = "AllowCoupon"
    }
}

// MARK: - AddOnOption
struct AddOnOption: Codable, Identifiable {
    let id: Int
    let name: String
    let p1, p2, p3, p4: Double
    let p5, p6: Double
    let dflt: AppBool?
    var isSelected = false
    var modifier1SelectedIndex = 0
    var modifier2SelectedIndex = 0
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case p1 = "P1"
        case p2 = "P2"
        case p3 = "P3"
        case p4 = "P4"
        case p5 = "P5"
        case p6 = "P6"
        case dflt = "Dflt"
    }
}


// MARK: - AddOnOptionModifier1
struct AddOnOptionModifier1: Codable {
    let id: Int
    let name: String?
    let label1: String?
    let label2: String?
    let label3: String?
    let label4, label5, label6: String?
    let factor1: Double?
    let factor2: Double?
    let factor3: Double?
    let factor4, factor5, factor6: Double?
    
    var labels: [String] {
        [label1, label2, label3, label4, label5, label6].compactMap({$0})
    }
    
    var factors: [Double] {
        [factor1, factor2, factor3, factor4, factor5, factor6].compactMap({$0})
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case label1 = "Label1"
        case label2 = "Label2"
        case label3 = "Label3"
        case label4 = "Label4"
        case label5 = "Label5"
        case label6 = "Label6"
        case factor1 = "Factor1"
        case factor2 = "Factor2"
        case factor3 = "Factor3"
        case factor4 = "Factor4"
        case factor5 = "Factor5"
        case factor6 = "Factor6"
    }
}

