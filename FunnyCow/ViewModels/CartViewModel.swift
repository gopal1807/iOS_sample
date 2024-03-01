//
//  CartViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 23/11/20.
//

import Combine
import SwiftUI
import CoreLocation

class CartViewModel: ObservableObject {
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(dismissLogin), name: .dismissLoginView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeCouponDiscount), name: .newItemAddedTocart, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalData), name: .dataUpdated, object: nil)
    }
  
    @Published var error: String?
    @Published var deleteItem: SelectedItemDetail?
    @Published var restaurantInstructions = ""
    @Published var carMaker = ""
    @Published var carModel = ""
    @Published var carColor = ""
    @Published var carPlate = ""
    @Published var tableNumber = ""
    @Published var manualTip = "10"
    @Published var selectedTip: Int = 15 {
        didSet {
            updateCartDataNow()
        }
    }
    @Published var couponEnable = false
    @Published var addressEnable = false
    @Published var loading = false
//    @Published var pushToSuccess = false
    @Published var pushToCardPayment = false
    @Published var pushToRestaurant = false
    @Published var showLogin = false
    @Published var selectedItemToAdd: SuggestedMenu?
    @Published var gotoSchedule = false
    
    let tipsArr = [0,5,10,15,20,25]
    var selectedService: ServiceElement?
    var readyInMinutes = 0
    var paymentMethods = [LocationDetailPaymentType]()
    var selectedPayment: LocationDetailPaymentType?
    var deliveryZoneId = 0
    var tID = ""
    private let calender = Calendar.cstCalendar
    var appStorage: OrderData?
    var restaurantDetail: RestaurantModel?
    var restaurantServices: [ServiceElement] = []
    var orderItems: [SelectedItemDetail] = []
    var suggestedMenu: [SuggestedMenu] = []
    var userAddress: String?
    var deliveryFee: Double = 0
    var serviceFee: Double = 0
    var couponPrice: Double = 0
    var lastAppliedCoupon: RestaurantCoupon?
    var lastAppliedDiscount1: Discount?
    var lastAppliedDiscount2: Discount?
    var discount1Price: Double = 0
    var discount2Price: Double = 0
    var currencySymbol: String { appStorage?.otherInfo?.restaurant.currencyDetail.symbol ?? "$"
    }
    var getMobileNumber: (() -> ())?
    var showOrderSuccess: (() -> ())?
    @objc func dismissLogin() {
        self.showLogin = false
    }
    
    func viewWillAppear() {
        updateLocalData()
        if let service = selectedService {
            let fee = calculateDeliveryFee(service: service)
            appStorage?.srvcFee = max(0, fee)
            updateView()
            updateCartDataNow()
        } else if restaurantServices.count == 1 {
            selectService(service: restaurantServices[0])
        }
    }
    
    private func selectDiscount(_ discount: Discount) {
        guard orderItems.first(where: {$0.havespicialoffer})?.specialOffer?.allowDiscount != .f else { return }
        if discount.isDiscountAvailable(cartData: appStorage) {
            if discount.lookup.lookupName == "Payment" {
                appStorage?.discount1Amt = String(discount.discountPrice())
                appStorage?.discount1Type = String(discount.id)
                appStorage?.otherInfo?.lastAppliedDiscount2 = discount
            } else {
                appStorage?.discountAmt = String(discount.discountPrice())
                appStorage?.discountType = String(discount.id)
                appStorage?.otherInfo?.lastAppliedDiscount1 = discount
            }
            updateCartDataNow()
        }
    }
    
    func updateRestaurantData() {
        guard let rest = UserDefaultsController.shared.cartSavedData?.otherInfo?.restaurant,
              let mobUrl: String = UserDefaultsController.shared.cartSavedData?.otherInfo?.mobUrl
        else { return }
        AppToken.shared.getToken(mobUrl) { token in
            let body = LocationDetailReq(data: LocationDetailReqData(locationID: rest.id, menuID: 0, mobURL: mobUrl), tID: token)
            HitApi.shared.postData("GetLocationdetails", bodyData: body) { (result: Result<RestaurantModel, HitApiError>) in
                switch result {
                    case .success(let result):
                        UserDefaultsController.shared.cartSavedData?.otherInfo?.restaurant = result
                        UserDefaultsController.shared.cartSavedData?.otherInfo?.restaurantSavedAt = Date()
                        self.viewWillAppear()
                    case .failure(let error):
                        print(error)
                }
            }
        }
    }
    
    @objc func updateLocalData() {
        let cardSavedData = UserDefaultsController.shared.cartSavedData
        if let restId = appStorage?.otherInfo?.restaurant.id, restId != cardSavedData?.otherInfo?.restaurant.id { //restaurant changed...
            selectedService = nil
        }
        appStorage = cardSavedData
        var date = Date()
        if let restSavedDate = cardSavedData?.otherInfo?.restaurantSavedAt {
            let seconds = date.timeIntervalSince(restSavedDate)
            let minutes = abs(Int(seconds)) / 60
            if minutes > 40 {
                self.updateRestaurantData()
            }
        }
        
        if cardSavedData?.dueOn != nil, let bdate = cardSavedData?.dueOnDate {
            date = bdate
        }
        
        itemTotal = cardSavedData?.preTaxAmt ?? 0
        orderItems = cardSavedData?.itemList ?? []
        lastAppliedCoupon = cardSavedData?.otherInfo?.lastAppliedCoupon
        couponPrice = cardSavedData?.couponAmt ?? 0
        deliveryFee = cardSavedData?.srvcFee ?? 0
        restaurantDetail = cardSavedData?.otherInfo?.restaurant
        restaurantServices = restaurantDetail?.services.filter({$0.available == .t && $0.openOn.isOpenToday(timeZone: restaurantDetail!.timeZone, date: date) && !$0.name.lowercased().contains("dine")}) ?? []
        suggestedMenu = cardSavedData?.otherInfo?.cartSuggestedMenu ?? []
        userAddress = cardSavedData?.deliveryInfo?.toString()
        restTaxAmt = cardSavedData?.otherInfo?.restaurant.tax ?? 0
        if selectedService != nil {
            lastAppliedDiscount1 = cardSavedData?.otherInfo?.lastAppliedDiscount1
            lastAppliedDiscount2 = cardSavedData?.otherInfo?.lastAppliedDiscount2
        }
//        discount1Price = lastAppliedDiscount1?.discountPrice() ?? 0
//        discount2Price = lastAppliedDiscount2?.discountPrice() ?? 0
        discount1Price = cardSavedData?.discountAmt?.toDouble ?? 0
        discount2Price = cardSavedData?.discount1Amt?.toDouble ?? 0
        updateServiceFee()
        updateView()
    }
    
    func updateServiceFee() {
        let restSrvChr = restaurantDetail?.restServiceCharge?.toDouble ?? 0
        if restaurantDetail?.restServiceChargeApplyOn == "1" {
            if restaurantDetail?.restServiceChargeType == "%" {
                let chr = itemTotal * restSrvChr/100
                serviceFee = chr
            } else {
                serviceFee = restSrvChr
            }
        } else if restaurantDetail?.restServiceChargeApplyOn == "2" {
            if restaurantDetail?.restServiceChargeType == "%" {
                let chr = (itemTotal + deliveryFee + taxAmount + tipAmount - discount1Price - discount2Price - couponPrice) * restSrvChr/100
                serviceFee = chr
            } else {
                serviceFee = restSrvChr
            }
        } else {
            serviceFee = 0
        }
        appStorage?.restServiceAmt = serviceFee
    }
   
    func updateCartDataNow() {
        if let storage = self.appStorage {
            UserDefaultsController.shared.cartSavedData = storage
        }
    }
    
    func incrementCount(for item: SelectedItemDetail) {
        if item.maxQ > item.qty {
            CartManager().incrementItem(item: item)
            removeCouponDiscount()
        } else {
            error = "Maximum \(item.maxQ) can be selected for \(item.name)"
        }
    }
        
    let updateViewDebouncer = Debounce()
    func updateView() {
        updateViewDebouncer.debounce(seconds: 0.15) {  self.updateViewNow() }
    }
    
    func updateViewNow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }
    
    func decrementCount(for item: SelectedItemDetail) {
        if max(1, item.minQ) == item.qty {
            self.deleteItem = item
        } else {
            CartManager().decrementItem(item: item)
            removeCouponDiscount()
        }
    }
    
    func addSuggestedItem(_ suggestion: SuggestedMenu) {
        
        if let offer = suggestion.item.specialOffer  {
            if offer.amt1 > itemTotal {
                self.error = "Minimum order should be \(currencySymbol)\(offer.amt1.to2Decimal)"
                return
            } else if UserDefaultsController.shared.cartSavedData?.otherInfo?.isSpecialSelected == true {
                self.error = "You already have a offer item"
                return
            }
        }
        
        var temp = UserDefaultsController.shared.tempCartData
        temp.restaurant = appStorage?.otherInfo?.restaurant
        UserDefaultsController.shared.tempCartData = temp

        self.selectedItemToAdd = suggestion
    }
    
    @objc func removeCouponDiscount() {
        self.appStorage?.discountType = nil
        self.appStorage?.discountAmt = nil
        self.appStorage?.otherInfo?.lastAppliedDiscount1 = nil
        //        self.lastAppliedDiscount1 = nil
        
        self.appStorage?.discount1Amt = nil
        self.appStorage?.discount1Type = nil
        self.appStorage?.otherInfo?.lastAppliedDiscount2 = nil
        //        self.lastAppliedDiscount2 = nil
        
        //removing coupon
        self.appStorage?.custCouponID = nil
        self.appStorage?.restChainCouponID = nil
        self.appStorage?.couponAmt = nil
        self.appStorage?.otherInfo?.lastAppliedCoupon = nil
        
        // update when order item change...
        guard var appStorage = UserDefaultsController.shared.cartSavedData else { return }
        appStorage.discountType = nil
        appStorage.discountAmt = nil
        appStorage.otherInfo?.lastAppliedDiscount1 = nil
        //        self.lastAppliedDiscount1 = nil
        
        appStorage.discount1Amt = nil
        appStorage.discount1Type = nil
        appStorage.otherInfo?.lastAppliedDiscount2 = nil
        //        self.lastAppliedDiscount2 = nil
        
        //removing coupon
        appStorage.custCouponID = nil
        appStorage.restChainCouponID = nil
        appStorage.couponAmt = nil
        appStorage.otherInfo?.lastAppliedCoupon = nil
        //        self.lastAppliedCoupon = nil
        
        UserDefaultsController.shared.cartSavedData = appStorage
    }
    
    func dateToUserString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = calender.timeZone
        formatter.dateFormat = "MMMM dd,yyyy hh:mm a"
        return formatter.string(from: date)
    }
    
    func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = calender.timeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: date)
    }
    
    func orderTiming() -> String {
        let isOpen = restaurantDetail?.checkIsRestaurantOpen().0 ?? false
        if let selection = appStorage?.timeSelection {
            if selection == 0, isOpen {
                return "Today, ASAP"
            } else {
                return appStorage?.dueOn == nil ? "" : dateToUserString(date: appStorage?.dueOnDate ?? Date())
            }
        } else {
            let isAsap = (appStorage?.otherInfo?.isAsap ?? false) && isOpen
            if isAsap {
                UserDefaultsController.shared.cartSavedData?.timeSelection = 0
                return "Today, ASAP"
            } else {
                return "Schedule your food"
            }
        }
    }
    
    func selectService(service: ServiceElement) {
        appStorage?.dueOn = nil
        appStorage?.createdOn = nil
        appStorage?.timeSelection = nil
        
        appStorage?.serviceID = service.id
        let fee = calculateDeliveryFee(service: service)
        appStorage?.srvcFee = max(0, fee)
        selectedService = service
        readyInMinutes = Int(service.readyInMin.toDouble)
        
        let pickPayments = service.payment.map({$0.id})
        self.paymentMethods = restaurantDetail?.paymentTypes.filter { (loc: LocationDetailPaymentType) -> Bool in
            pickPayments.contains(where: {$0 == loc.id})
        } ?? []
        self.paymentMethods.removeDuplicates()
        
        if let payment = paymentMethods.first {
            self.selectPaymentMethod(payment)
        } else {
            selectedPayment = nil
            removeCouponDiscount()
        }
        updateCartDataNow()
        setOrderTiming()
    }
    
    func contiansInPolygon(point:CLLocationCoordinate2D,bounds:[CLLocationCoordinate2D]) -> Bool{
        let path = CGMutablePath()
        for vertex in bounds {
            if path.isEmpty {
                path.move(to: CGPoint(x: vertex.longitude, y: vertex.latitude))
            } else {
                path.addLine(to: CGPoint(x: vertex.longitude, y: vertex.latitude))
            }
        }
        path.closeSubpath()
        let pointa = CGPoint(x: point.longitude, y: point.latitude)
        return path.contains(pointa)
    }
    
    func createLatLon(pointString: String) -> [CLLocationCoordinate2D] {
        var latlong = [CLLocationCoordinate2D]()
        let str = pointString.components(separatedBy: ",0,")
        for i in str {
            let locations = i.components(separatedBy: ",")
            
            let coordinates:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((locations[0] as NSString).doubleValue), longitude: Double((locations[1] as NSString).doubleValue))
            latlong.append(coordinates)
        }
        return latlong
    }
    
    func getDeliveryZone(point:CLLocationCoordinate2D,deliveryZones:[DeliveryZone]) -> Int {
        for zone in deliveryZones.enumerated() {
            let latLong = createLatLon(pointString: zone.element.pointString ?? "")
            if contiansInPolygon(point: point, bounds: latLong){
                return zone.offset
            }
        }
        return -1
    }
    
    func calculateDeliveryFee(service: ServiceElement) -> Double {
        // -1 -> select service error
        // -2 -> deliver not available error
        guard let restaurantDetail = self.restaurantDetail else { return -1 }
//        guard service.name == "Delivery" else { return service.minFee.toDouble }
        if service.name == "Delivery",
           let zones = service.deliveryZones,
           !zones.isEmpty,
           let address = appStorage?.deliveryInfo {
            let index = self.getDeliveryZone(point: CLLocationCoordinate2D(latitude: (address.latitude ?? 0), longitude: (address.longitude ?? 0)), deliveryZones: zones)
            if index < 0 { // not in zone
                let misc = restaurantDetail.miscMask
                if misc[2] == "1" { // not available for out side zone
                    return -2
                } else {
                    self.deliveryZoneId = zones.last?.deliveryZoneID ?? 0
                    return zones.last?.fixedCharge ?? 0
                }
            } else {
                self.deliveryZoneId = zones[index].deliveryZoneID
                return zones[index].fixedCharge
            }
        }
        // delivery zone if empty or null
        self.deliveryZoneId = 0
        let isDynamic = service.dynamicFee == "T"
        let preTaxAmt = itemTotal
        if isDynamic {
            
            if (preTaxAmt < service.minOrder.toDouble) {
                return 0.0
            }
            else if ((service.minOrder.toDouble <= preTaxAmt) && (preTaxAmt < service.orderAmt1.toDouble)) {
                
                return service.minFlatFee.toDouble + preTaxAmt * (service.minVarFee.toDouble)
            }
            else if ((service.orderAmt1.toDouble <= preTaxAmt) && (preTaxAmt < service.orderAmt2.toDouble)) {
                return service.minFlatFee.toDouble + preTaxAmt * (service.minVarFee.toDouble)
                
            } else if ((service.orderAmt2.toDouble <= preTaxAmt) && (preTaxAmt < service.orderAmt3.toDouble)) {
                return service.flatFee2.toDouble + preTaxAmt * (service.varFee2.toDouble)
            } else {
                return service.flatFee3.toDouble + preTaxAmt * (service.varFee3.toDouble)
            }
            
        } else {
            return max((service.minFee.toDouble), service.minCharges.toDouble)
        }
    }
    
    func selectPaymentMethod(_ payment: LocationDetailPaymentType) {
        removeCouponDiscount()
        selectedTip = 0
        selectedPayment = payment
        self.appStorage?.paymentTypeID = self.selectedPayment?.id
        if let discount = appStorage?.otherInfo?.restaurant.discounts.first(where: {$0.lookup.lookupName == "FirstOrder"}) {
            self.selectDiscount(discount)
        }
        if appStorage?.otherInfo?.lastAppliedDiscount1 == nil, appStorage?.otherInfo?.lastAppliedDiscount2 == nil {
            if let discount = appStorage?.otherInfo?.restaurant.discounts.first(where: {$0.isDiscountAvailable(cartData: appStorage)}) {
                self.selectDiscount(discount)
            }
        }
        self.updateCartDataNow()
        updateView()
    }
    
    //MARK: prices
    var itemTotal: Double = 0
    var restTaxAmt: Double = 0

    var taxAmount: Double {
        let taxItems = orderItems.filter({!$0.isTaxFree})
        let itemTotal = taxItems.map({$0.amt}).reduce(0, +)
        let afterDis = itemTotal - couponPrice - discount1Price - discount2Price
        return restTaxAmt >= 1 ? restTaxAmt : restTaxAmt * afterDis
    }
    
    var tipAmount: Double {
        if selectedTip == 0 {
            return 0
        } else if selectedTip > 0 {
            return itemTotal * (Double(selectedTip) / 100)
        } else {
            return manualTip.toDouble
        }
    }
    
    var grandTotal: Double {
        var gtotal = itemTotal - couponPrice - discount1Price - discount2Price + taxAmount + tipAmount + serviceFee
        gtotal = max(0, gtotal) + deliveryFee
        appStorage?.totalAmt = gtotal
        return gtotal
    }
        
    func couponTapped() {
        if UserDefaultsController.shared.userModel == nil {
            showLogin = true
        } else {
            updateCartDataNow()
            couponEnable = true
        }
    }
    
    func addressTapped()  {
        if UserDefaultsController.shared.userModel == nil {
            showLogin = true
        } else {
            addressEnable = true
        }
    }
    
    var scheduleMinutes: String {
        if let selectedTime = appStorage?.dueOnDate {
            let formatter1 = RelativeDateTimeFormatter()
            formatter1.unitsStyle = .short
            return formatter1.localizedString(for: selectedTime, relativeTo: Date())
        } else {
            return ""
        }
//        let minuteDiff = calender
//            .dateComponents([.minute], from: Date(), to: selectedTime)
//            .minute ?? 0
//        let finalMinutes = max(minuteDiff, readyInMinutes)
//        let dd = calender.date(byAdding: .minute, value: finalMinutes, to: Date()) ?? Date()
      
    }
    
    func isSubmitEnable() -> Bool {
        guard let service = selectedService else { return false }
        var condition = true
        if (service.name.lowercased().contains("curb")) {
            condition = !carMaker.isEmpty &&
                !carModel.isEmpty &&
                !carColor.isEmpty &&
                !carPlate.isEmpty
        } else if (service.name.lowercased().contains("delivery")) {
            condition = appStorage?.deliveryInfo != nil
        } else if (service.name.lowercased().contains("dine")) {
            condition = !tableNumber.isEmpty
        }
        let userData = UserDefaultsController.shared.userModel
        let isEnable =  condition &&
            (appStorage?.timeSelection != nil) &&
            selectedPayment != nil &&
            userData != nil &&
            !((userData?.tel ?? userData?.cell ?? "").isEmpty)
        
        if isEnable {
            if itemTotal < service.minOrder.toDouble {
                return false
            }
            if itemTotal > service.maxOrder.toDouble {
                return false
           }
            
            if let restaurantService = restaurantDetail?.checkIsRestaurantOpen().1 {
                let isDelivery = service.name.contains("Delivery")
                let openTime = hoursTimeToDate(openTime: isDelivery ? restaurantService.firstDel : restaurantService.firstOrd)
                let closeTime = hoursTimeToDate(openTime: isDelivery ? restaurantService.lastDel : restaurantService.lastOrd)
                let seconds = closeTime.timeIntervalSince(openTime)
                let minutes = Int(seconds) / 60
                if abs(minutes) < 15 {
                    return false
                }
            }
        
        }
        if isEnable {
            let fee = calculateDeliveryFee(service: service)
            return fee >= 0
        }
        return isEnable
    }
    
    func hoursTimeToDate(openTime: String) -> Date {
        let date = Date()
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
    
    func getError() {
        guard let service = selectedService else {
            error = "Please select a service type"
            return }
        if (service.name.lowercased().contains("curb")) {
            if carMaker.isEmpty || carModel.isEmpty || carColor.isEmpty || carPlate.isEmpty {
                error = "Please add car details"
            }
        } else if (service.name.lowercased().contains("delivery")) {
            if appStorage?.deliveryInfo == nil {
                error = "Please select delivery address"
            }
        } else if (service.name.lowercased().contains("dine")) {
            if tableNumber.isEmpty {
                error = "Please add table number"
            }
        }
        
        if error == nil, appStorage?.timeSelection == nil {
            self.gotoSchedule = true
            return
        } else if selectedPayment == nil {
            error = "Please select payment method"
        }
        if error == nil, UserDefaultsController.shared.userModel == nil {
            showLogin = true
            return
        }
        let userData = UserDefaultsController.shared.userModel
        if error == nil, (userData?.tel ?? userData?.cell ?? "").isEmpty {
            self.getMobileNumber?()
            return
        }
        
        if error == nil, !showLogin {
            if itemTotal < service.minOrder.toDouble {
                error = "Minimum order for \(service.name) should be \(currencySymbol)\(service.minOrder.toDouble.to2Decimal)"
            } else if itemTotal > service.maxOrder.toDouble {
                error = "Maximum order for \(service.name) can be \(currencySymbol)\(service.maxOrder.toDouble.to2Decimal)"
           } else if let restaurantService = restaurantDetail?.checkIsRestaurantOpen().1 {
                let isDelivery = service.name.contains("Delivery")
                let openTime = hoursTimeToDate(openTime: isDelivery ? restaurantService.firstDel : restaurantService.firstOrd)
                let closeTime = hoursTimeToDate(openTime: isDelivery ? restaurantService.lastDel : restaurantService.lastOrd)
                let seconds = closeTime.timeIntervalSince(openTime)
                let minutes = Int(seconds) / 60
                if abs(minutes) < 15 {
                    error = "\(service.name) is not available"
                }
            }
        }
        
        if error == nil {
            let fee = calculateDeliveryFee(service: service)
            if fee == -2 {
                error = "Delivery not available at selected location"
            } else if fee == -1 {
                error = "Something went wrong"
            }
        }
    }
    
    func checkIfCatInTime(date: Date) -> SelectedCatData? {
        for item in orderItems {
            let available = item.categoryData.isAvailable(on: date, calender: calender)
            if !available { return item.categoryData }
        }
        return nil
    }
    
    func checkError() {
        if isSubmitEnable() {
            let selection = appStorage?.timeSelection ?? 0
            let dueON: String
            if selection == 0, let dueOn = calender.date(byAdding: .minute, value: readyInMinutes, to: Date()) {
                dueON = dateToString(date: dueOn)
            } else {
                dueON = appStorage?.dueOn ?? ""
            }
            var date = Date()
            let formatter = DateFormatter()
            formatter.timeZone = calender.timeZone
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            if let bdate = formatter.date(from: dueON) {
                date = bdate
            }
            
            if restaurantDetail!.checkIsRestaurantOpen(on: date).0 == false {
                self.error = "Please schedule different time\nRestaurant is not available at scheduled time."
            } else
            if let catData = checkIfCatInTime(date: date) {
                self.error = "Please schedule different time\n\(catData.name) is not available at scheduled time."
            } else {
                getToken()
            }
            
        } else {
            getError()
        }
    }
    
    func getToken() {
        loading = true
        let mobUrl = appStorage?.otherInfo?.mobUrl ?? ""
        
        AppToken.shared.getToken(mobUrl) { (token) in
            self.tID = token
            self.doLoginWithCustId()
        }
    }
    
    func doLoginWithCustId() {
        guard let userid = UserDefaultsController.shared.userModel?.id else { return }
        let loginRequest = DologinByCust(data: DoLoginCustData(custId: userid), tId: tID)
        self.loading = true
        HitApi.shared.postData("DoLoginByCustId", bodyData: loginRequest) { (result: Result<UserModel, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let user):
                    UserDefaultsController.shared.userModel = user
                    self.appStorage?.custID = user.id
                    self.appStorage?.carmake = self.carMaker
                    self.appStorage?.carcolor = self.carColor
                    self.appStorage?.carmodel = self.carModel
                    self.appStorage?.dineInTableNum = self.tableNumber
                    self.appStorage?.carplatenumber = self.carPlate
                    self.appStorage?.tipAmt = self.tipAmount
                    self.appStorage?.paymentTypeID = self.selectedPayment?.id
                    self.appStorage?.delzoneInd = self.deliveryZoneId == 0 ? nil : self.deliveryZoneId
                    self.appStorage?.taxAmt = self.taxAmount
                    self.appStorage?.specialInstructions = self.restaurantInstructions.replacingOccurrences(of: "<", with: "")
                        .replacingOccurrences(of: ">", with: "")
                    if self.selectedPayment?.type == "POP" || self.selectedPayment?.type == "$$" {
                        self.appStorage?.ccInfo = CCInfo(ccType: nil, date: nil, hacode: nil, ccAddr1: nil, ccAddr2: nil, cccvv: nil, ccCity: nil, ccExpDate: nil, ccfName: nil, cclName: nil, ccmName: nil, ccNumber: nil, ccState: nil, cczip: nil, service: nil, time: nil, tipPaidbBy: nil, txtPaytronixGiftCard: nil, tipAmount: self.tipAmount)
                        self.setOrder()
                    } else {
                        UserDefaultsController.shared.cartSavedData?.otherInfo?.restaurantSavedAt = Date()
                        self.updateCartDataNow()
                        self.pushToCardPayment = true
                    }
           
                case .failure(let error):
                    print(error)
            }
        }
    }

    func reArrangeDataBeforeOrder() -> OrderData? {
        guard var orderData = appStorage else { return nil }
        let userData = UserDefaultsController.shared.userModel
        if !(selectedService?.name.lowercased().contains("delivery") ?? false) || orderData.deliveryInfo == nil {
            let name = userData?.fName ?? ""
            let phone = userData?.tel ?? userData?.cell ?? ""
            orderData.deliveryInfo = DeliveryInfo(addr1: nil, addr2: nil, addressID: nil, city: nil, custAddressName: nil, fName: nil, mName: nil, lName: nil, instructions: nil, latitude: nil, longitude: nil, state: nil, zip: nil, name: name, telephone: phone)
        }
        orderData.otherInfo = nil
        return orderData
    }
    
    func setOrder() {
        self.setOrderTiming()
        guard let orderData = reArrangeDataBeforeOrder() else { return }
        let request = SetOrderRequest(data: SetOrderRequestData(orderData: orderData), tID: tID)
        self.loading = true
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        if let encoded = try? encoder.encode(request) {
            let decoded = String(decoding: encoded, as: UTF8.self)
            print(decoded)
//            self.loading = false
//            return
        }
        
        HitApi.shared.postData("SetOrder", bodyData: request) { (result: Result<SetOrderResponse, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let response):
                     print(response.orderNumber as Any)
                    self.showOrderSuccess?()
                case .failure(let error):
                    self.error = error.toString()
            }
        }
    }
    
    func setOrderTiming() {
        guard let restaurant = UserDefaultsController.shared.cartSavedData?.otherInfo?.restaurant else {return}
        var restDate = Date()
        let checkOpen = restaurant.checkIsRestaurantOpen()

        if selectedService?.name.contains("Delivery") ?? false,
           let restTime = checkOpen.1 {
            let openTime = hoursTimeToDate(openTime: restTime.firstDel)
            restDate = max(restDate, openTime)
        }
        if let selection = appStorage?.timeSelection {
            if selection == 0 {
                appStorage?.createdOn = dateToString(date: restDate)
                if let dueOn = calender.date(byAdding: .minute, value: readyInMinutes + 1, to: restDate) {
                    appStorage?.dueOn = dateToString(date: dueOn)
                }
                self.updateCartDataNow()
            }
        } else {
            let isAsapavail = appStorage?.otherInfo?.isAsap ?? false
            let isrestOpen = checkOpen.0
            if isrestOpen, isAsapavail {
                appStorage?.timeSelection = 0
                appStorage?.createdOn = dateToString(date: restDate)
                if let dueOn = calender.date(byAdding: .minute, value: readyInMinutes + 1, to: restDate) {
                    appStorage?.dueOn = dateToString(date: dueOn)
                }
                self.updateCartDataNow()
            }
        }
    }
}
