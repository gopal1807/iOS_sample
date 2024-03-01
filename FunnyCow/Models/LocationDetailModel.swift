//
//  LocationDetailRequestModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 20/11/20.
//

import Foundation

struct LocationDetailReq: Codable {
    var data: LocationDetailReqData
    let tID: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case tID = "tId"
    }
}

// MARK: - DataClass
struct LocationDetailReqData: Codable {
    var locationID, menuID: Int
    let mobURL: String
    var isApp: String = "1"
    
    enum CodingKeys: String, CodingKey {
        case locationID = "locationId"
        case menuID = "menuId"
        case mobURL = "mobUrl"
        case isApp
    }
}

// MARK: - LocationDetail
struct RestaurantModel: Codable {
    let id, restChainID: Int
    let name, header, headerBackgroundImage: String
    let restImage, descrip, logoImg: String?
    let address: Address
    let tel: String
    let lon, lat: Double
    let tax: Double
    let timeZone: RestaurantTimeZone
    let miscMask, wlcURL, mediaCDNURL: String
    let alert: [LocationAlert]?
    let theme: String
    let calendar: RestaurantCalendar
    let schedule: [Schedule]
    let paymentTypes: [LocationDetailPaymentType]
    let paymentProviderMercury: AppBool?
    let PaymentProviderMiMenu: AppBool?
    let PaymentProviderPayUMoney: AppBool?
    let PaymentProviderStripe: AppBool?
    let paymentProviderUSAEPay: AppBool?
    let services: [ServiceElement]
    let menus: [Menu]
    let discounts: [Discount]
    let coupons: [RestaurantCoupon]
    let openCloseTime: String
    
    let validationAtSite, isVault: String?
    let paymentProviderAAFES: String?
    let PublishableKey: String?
    
    let isMenuGrubLocation: String?
    let currencyDetail: CurrencyDetail
    let restServiceCharge: String?
    let restServiceChargeType: String?
    let restServiceChargeApplyOn: String?
    
    enum CodingKeys: String, CodingKey {
        case restServiceCharge = "RestServiceCharge"
        case restServiceChargeType = "RestServiceChargeType"
        case restServiceChargeApplyOn = "RestServiceChargeApplyOn"
        case id = "Id"
        case PaymentProviderMiMenu,
             PaymentProviderPayUMoney,
             PaymentProviderStripe,
             PublishableKey,
             isMenuGrubLocation,
             currencyDetail
        case logoImg = "LogoImg"
        case restChainID = "RestChainId"
        case name = "Name"
        case descrip = "Description"
        case header = "Header"
        case headerBackgroundImage = "HeaderBackgroundImage"
        case restImage = "RestImage"
        case address = "Address"
        case tel = "Tel"
        case lon = "Lon"
        case lat = "Lat"
        case tax = "Tax"
        case timeZone = "TimeZone"
        case miscMask = "MiscMask"
        case wlcURL = "WLCUrl"
        case mediaCDNURL = "MediaCDNURL"
        case alert = "Alert"
        case theme = "Theme"
        case calendar = "Calendar"
        case schedule = "Schedule"
        case paymentTypes = "PaymentTypes"
        case services = "Services"
        case menus = "Menus"
        case discounts = "Discounts"
        case coupons = "Coupons"
        case openCloseTime = "OpenCloseTime"
        case validationAtSite = "ValidationAtSite"
        case isVault = "IsVault"
        case paymentProviderUSAEPay = "PaymentProviderUSAePay"
        case paymentProviderMercury = "PaymentProviderMercury"
        case paymentProviderAAFES = "PaymentProviderAAFES"
    }
    
    
    func openTimeToDate(openTime: String,date: Date, calender: Calendar) -> Date {
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
    
    func alertsForNow() -> [String] {
        //03/23/2017 13:00:00 startDate : "03/23/2017 13:00:00"
        guard let alert = alert else { return [] }
        let calender = Calendar.cstCalendar
        let today = Date()
        let formatter = DateFormatter()
        formatter.calendar = calender
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        var alertStrings = alert.map { (alert) -> String in
            if let start = formatter.date(from: alert.startDate), let end = formatter.date(from: alert.endDate) {
                if start < today, today < end {
                    return alert.text
                }
            }
            return ""
            
        }
        alertStrings.removeAll(where: {$0.isEmpty})
        return alertStrings
    }
    
    func checkTimeBetwwen(_ schedule: Schedule, _ nowTime: Date, calender: Calendar) -> Bool {
        let opentime = openTimeToDate(openTime: schedule.ot1, date: nowTime, calender: calender)
        let closeTime = openTimeToDate(openTime: schedule.ct1, date: nowTime, calender: calender)
        let openTime2 = openTimeToDate(openTime: schedule.ot2, date: nowTime, calender: calender)
        let closeTime2 = openTimeToDate(openTime: schedule.ct2, date: nowTime, calender: calender)
        return (opentime < nowTime && nowTime < closeTime) || ( openTime2 < nowTime && nowTime < closeTime2)
    }
    
    func checkIsRestaurantOpen(on date: Date = Date()) -> (Bool, Schedule?) {
        var (isOpenToday, rschedule) = checkIsRestaurantOpenToday(on: date)
        if isOpenToday, let sechedule = rschedule {
            let calender = Calendar.current.restCal(timeZ: timeZone)
            
            isOpenToday = checkTimeBetwwen(sechedule, date, calender: calender)
        }
        return (isOpenToday,rschedule)
    }
    
    
    func checkIsRestaurantOpenToday(on date: Date = Date()) -> (Bool, Schedule?) {
        let calender = Calendar.current.restCal(timeZ: timeZone)
        let day = calender.ordinality(of: .day, in: .year, for: date)!
        var isOpenToday = calendar.openOrCloseYearMask[day-1] == "1" &&  calendar.openOn.isOpenToday(timeZone: timeZone,date: date)
        var rschedule = schedule.first
        if isOpenToday {
            let weekDay = calender.component(.weekday, from: date)
            let weekDayName = weekDay == 1 ? "sun" : weekDay == 2 ? "mon" : weekDay == 3 ? "tue" : weekDay == 4 ? "wed" : weekDay == 5 ? "thu" : weekDay == 6 ? "fri" : "sat"
            rschedule = schedule.first(where: {$0.day.lowercased() == weekDayName})
            
            if let sechedule = rschedule {
                isOpenToday = sechedule.closed == .f
                
                let closeTime2 = openTimeToDate(openTime: sechedule.lastCloseTime(), date: date, calender: calender)
                if isOpenToday, closeTime2 < date {
                    isOpenToday = false
                }
            } else {
                isOpenToday = false
            }
        }
        return (isOpenToday,rschedule)
    }
}


//MARK: - CurrencyDetails

struct CurrencyDetail: Codable {
    let lookupCurrencyId: String
    let name: String
    let code: String
    let symbol: String
    let hexCode: String
    
    enum CodingKeys: String , CodingKey {
        case code, name, symbol
        case lookupCurrencyId = "LookupCurrencyId"
        case hexCode = "HexCode"
    }
}
// MARK: - Alert
struct LocationAlert: Codable {
    let text, startDate, endDate: String
    
    enum CodingKeys: String, CodingKey {
        case text = "Text"
        case startDate = "StartDate"
        case endDate = "EndDate"
    }
}

// MARK: - Calendar
struct RestaurantCalendar: Codable {
    let openOrCloseYearMask, openOrCloseNextYearMask: String
    let openOn: OpenOn
    
    enum CodingKeys: String, CodingKey {
        case openOrCloseYearMask = "OpenOrCloseYearMask"
        case openOrCloseNextYearMask = "OpenOrCloseNextYearMask"
        case openOn = "OpenOn"
    }
}

// MARK: - OpenOn
struct OpenOn: Codable {
    let mon, tue, wed, thu: AppBool?
    let fri, sat, sun: AppBool?
    
    enum CodingKeys: String, CodingKey {
        case mon = "Mon"
        case tue = "Tue"
        case wed = "Wed"
        case thu = "Thu"
        case fri = "Fri"
        case sat = "Sat"
        case sun = "Sun"
    }
}


// MARK: - Coupon
struct RestaurantCoupon: Codable, Hashable, Identifiable {
    var id: Int
    var usageCountLeft: Int?
    let couponDescription: String
    let discount: Double
    let couponCode: String
    let type: String
    let startDate, endDate: String
    let preTax: String
    let cType: String
    let minOrderAmt: Double
    //    let service, paymentType: JSONNull?
    
    enum CodingKeys: String, CodingKey {
        case usageCountLeft = "UsageCountLeft"
        case id = "Id"
        case couponDescription = "Description"
        case discount = "Discount"
        case couponCode = "CouponCode"
        case type = "Type"
        case startDate = "StartDate"
        case endDate = "EndDate"
        case preTax = "PreTax"
        case cType = "CType"
        case minOrderAmt = "MinOrderAmt"
        //        case service = "Service"
        //        case paymentType = "PaymentType"
    }
    
    static func == (lhs: RestaurantCoupon, rhs: RestaurantCoupon) -> Bool {
        return lhs.couponCode == rhs.couponCode
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(couponCode)
    }
    
    func toString() -> String {
        return type == "%" ? "\((discount * 100).to2Decimal)%" : "FLAT \(currencySymbol)\(discount.to2Decimal)"
    }
}


// MARK: - Discount
struct Discount: Codable, Identifiable, Hashable {
    static func == (lhs: Discount, rhs: Discount) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    let id: Int
    let lookup: Lookup
    let discountDescription: String
    let disc: Double
    let type: String
    let minAmt: Double
    let startDate, endDate: String
    let preTax: String
    let service: DiscountService?
    let paymentTypes: [DiscountPaymentType]?
    let discount, coupon: AppBool
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case lookup = "Lookup"
        case discountDescription = "Description"
        case disc = "Disc"
        case type = "Type"
        case minAmt = "MinAmt"
        case startDate = "StartDate"
        case endDate = "EndDate"
        case preTax = "PreTax"
        case service = "Service"
        case paymentTypes = "PaymentTypes"
        case discount = "Discount"
        case coupon = "Coupon"
    }
    
    
    func isDiscountAvailable(cartData: OrderData? = nil) -> Bool {
        guard let cart = (cartData ?? UserDefaultsController.shared.cartSavedData), let user = UserDefaultsController.shared.userModel else {return false}
        let isFirstOrder = user.orderHistory?.filter({$0.locationId == cart.locationID}).isEmpty ?? true
        if lookup.lookupName == "FirstOrder", !isFirstOrder {
            return false
        }
        if let id = service?.serviceID, id != cart.serviceID {
            return false
        }
        if (minAmt > 0.0 && preTax == "T") {
            let discountItems = cart.itemList?.filter({$0.isAllowDiscount}) ?? []
            let itemTotal = discountItems.map({$0.amt}).reduce(0, +)
            if (itemTotal < minAmt){
                return false
            }
        }else{
            if (minAmt > 0.0){
                if ((cart.totalAmt ?? 0) < minAmt){
                    return false
                }
            }
        }
        
        if Date() < dateFromString(date: startDate) || Date() > dateFromString(date: endDate) {
            return false
        }
        if let payment = paymentTypes {
            return payment.map({$0.id}).contains(cart.paymentTypeID)
        }
        return true
    }
    func dateFromString(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        return formatter.date(from: date) ?? Date()
    }
    
    func discountPrice() -> Double {
        if type == "$" { return disc }
        guard let order = UserDefaultsController.shared.cartSavedData else { return 0 }
        
        let discountItems = order.itemList?.filter({$0.isAllowDiscount}) ?? []
        let amount = discountItems.map({$0.amt}).reduce(0, +)
        if preTax == "T" {
            if type == "%" , disc < 1 {
                return amount * disc
            }
        } else {
            if type == "%" , disc < 1 {
                return (amount + Double(order.taxAmt ?? 0)) * disc
            }
        }
        return 0
    }

    func toString() -> String {
        return type == "%" ? "\((disc * 100).to2Decimal)%" : "FLAT \(currencySymbol)\(disc.to2Decimal)"
    }
}

// MARK: - Lookup
struct Lookup: Codable {
    let lookupID: Int
    let lookupName: String
    
    enum CodingKeys: String, CodingKey {
        case lookupID = "LookupId"
        case lookupName = "LookupName"
    }
}

// MARK: - DiscountPaymentType
struct DiscountPaymentType: Codable {
    let id: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
    }
}

// MARK: - DiscountService
struct DiscountService: Codable {
    let serviceID: Int
    let serviceName: String?
    
    enum CodingKeys: String, CodingKey {
        case serviceID = "ServiceId"
        case serviceName = "ServiceName"
    }
}

// MARK: - Menu
struct Menu: Codable {
    let id: Int
    let name, desc: String
    let asap, lt, fo: String
    let openOn: OpenOn
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case desc = "Desc"
        case asap = "ASAP"
        case lt = "LT"
        case fo = "FO"
        case openOn = "OpenOn"
    }
}

// MARK: - LocationDetailPaymentType
struct LocationDetailPaymentType: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let type, name, desc, icon: String
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case type = "Type"
        case name = "Name"
        case desc = "Desc"
        case icon = "Icon"
    }
    
    static func == (lhs: LocationDetailPaymentType, rhs: LocationDetailPaymentType) -> Bool {
        return lhs.type == rhs.type
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}


// MARK: - Schedule
struct Schedule: Codable {
    let day, ot1, ct1, ot2: String
    let ct2, firstDel, lastDel, firstOrd: String
    let lastOrd: String
    let closed: AppBool
    
    enum CodingKeys: String, CodingKey {
        case day = "Day"
        case ot1 = "OT1"
        case ct1 = "CT1"
        case ot2 = "OT2"
        case ct2 = "CT2"
        case firstDel = "FirstDel"
        case lastDel = "LastDel"
        case firstOrd = "FirstOrd"
        case lastOrd = "LastOrd"
        case closed = "Closed"
    }
    
    func lastCloseTime() -> String {
        let values = ct1.components(separatedBy: ":")
        let hour: Int = Int(values.first ?? "0") ?? 0
        let min: Int = Int(values.indices.contains(1) ? values[1] : "0") ?? 0
        let sec: Int = Int(values.indices.contains(2) ? values[2] : "0") ?? 0
        let ct1Seconds = (hour * 60 * 60) + (min * 60) + sec
        
        let values1 = ct2.components(separatedBy: ":")
        let hour1: Int = Int(values1.first ?? "0") ?? 0
        let min1: Int = Int(values1.indices.contains(1) ? values[1] : "0") ?? 0
        let sec1: Int = Int(values1.indices.contains(2) ? values[2] : "0") ?? 0
        let ct2Seconds = (hour1 * 60 * 60) + (min1 * 60) + sec1
        
        if ct1Seconds > ct2Seconds {
            return ct1
        } else {
            return ct2
        }
        
    }
}

// MARK: - ServiceElement
struct ServiceElement: Codable, Identifiable, Equatable {
    static func == (lhs: ServiceElement, rhs: ServiceElement) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: Int
    let name, minFee: String
    let deliveryZones: [DeliveryZone]?
    let dynamicFee: String
    let payment: [Payment]
    let openOn: OpenOn
    let available: AppBool
    let minOrder, maxOrder, minCharges, readyIn: String
    let readyInMin, orderAmt1, orderAmt2, orderAmt3: String
    let flatFee1, flatFee2, flatFee3, varFee1: String
    let varFee2, varFee3, minFlatFee, minVarFee: String
    let tempMinDelay, tempMinDelayDate: String
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case minFee = "MinFee"
        case deliveryZones = "DeliveryZones"
        case dynamicFee = "DynamicFee"
        case payment = "Payment"
        case openOn = "OpenOn"
        case available = "Available"
        case minOrder = "MinOrder"
        case maxOrder = "MaxOrder"
        case minCharges = "MinCharges"
        case readyIn = "ReadyIn"
        case readyInMin = "ReadyInMin"
        case orderAmt1 = "OrderAmt1"
        case orderAmt2 = "OrderAmt2"
        case orderAmt3 = "OrderAmt3"
        case flatFee1 = "FlatFee1"
        case flatFee2 = "FlatFee2"
        case flatFee3 = "FlatFee3"
        case varFee1 = "VarFee1"
        case varFee2 = "VarFee2"
        case varFee3 = "VarFee3"
        case minFlatFee = "MinFlatFee"
        case minVarFee = "MinVarFee"
        case tempMinDelay = "TempMinDelay"
        case tempMinDelayDate = "TempMinDelayDate"
    }
}

// MARK: - DeliveryZone
struct DeliveryZone: Codable {
    let deliveryZoneID: Int
    let fixedCharge: Double
    let pointString: String?
    
    enum CodingKeys: String, CodingKey {
        case deliveryZoneID = "DeliveryZoneId"
        case fixedCharge = "FixedCharge"
        case pointString = "PointString"
    }
}

// MARK: - Payment
struct Payment: Codable {
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
    }
}

// MARK: - TimeZone
struct RestaurantTimeZone: Codable {
    let name: String
    let hoursDifference, minutesDifference: Int
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case hoursDifference = "HoursDifference"
        case minutesDifference = "MinutesDifference"
    }
}

enum AppBool: String, Codable {
    case f = "F"
    case t = "T"
}
