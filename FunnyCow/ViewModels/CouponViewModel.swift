//
//  CouponViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 24/11/20.
//

import SwiftUI

class CouponViewModel: ObservableObject {
    
    @Published var error: String?
    @Published var getConsent: AlertWithAction?
    @Published var loading = false
    @Published var couponCode = ""
    @Published var dissmiss = false
    var validCoupons = [RestaurantCoupon]()
    var visibleCoupons = [RestaurantCoupon]()
    private var allCoupons = [RestaurantCoupon]()
    var discounts = UserDefaultsController.shared.cartSavedData?.otherInfo?.restaurant.discounts ?? []
    var symbol = UserDefaultsController.shared.cartSavedData?.otherInfo?.restaurant.currencyDetail.symbol ?? "$"
    
    lazy var itemsTotalCoupon: Double = {
        let couponItems = UserDefaultsController.shared.cartSavedData?.itemList?.filter({$0.isAllowCoupon}) ?? []
        return couponItems.map({$0.amt}).reduce(0, +)
    }()
    
    init() {
        discounts = discounts.removingDuplicates().filter({$0.isDiscountAvailable()})
        AppToken.shared.getToken { (token) in
            self.getCoupons(tid: token)
        }
    }
    
    func getCoupons(tid: String) {
        guard let userid = UserDefaultsController.shared.userModel?.id else { return }
        loading = true
        let body = DoLoginRequest(data: DoLoginRequestData(custID: userid), tID: tid)
        
        HitApi.shared.postData("GetUserCoupons", bodyData: body) { (result: Result<[GetUserCoupon], HitApiError>) in
            self.loading = false
            switch result {
                case .success(let result):
                    
                    var coupons = UserDefaultsController.shared.cartSavedData?.otherInfo?.restaurant.coupons ?? []
                    coupons.removeAll { (restCoupon: RestaurantCoupon) -> Bool in
                        if restCoupon.cType == "Specific" {
                            return !result.contains(where: {$0.couponCode == restCoupon.couponCode})
                        }
                        return false
                    }
                    for enumu in coupons.enumerated() {
                        if enumu.element.cType == "Specific" {
                            let userCoupon = result.first(where: {$0.couponCode == enumu.element.couponCode})!
                            coupons[enumu.offset].id = userCoupon.custCouponID
                            coupons[enumu.offset].usageCountLeft = userCoupon.usageCountLeft
                        }
                    }
                    self.allCoupons = coupons
                    self.validCoupons = coupons.filter({self.isCouponAvailable(coupen: $0).0})
                    self.visibleCoupons = self.validCoupons.filter({ (restCou: RestaurantCoupon) -> Bool in
                        result.contains(where: {$0.custCouponID == restCou.id})
                    })
                    self.objectWillChange.send()
                case .failure(let error):
                    self.error = error.toString()
            }
        }
    }
    
    private func isCouponAvailable(coupen: RestaurantCoupon) -> (Bool, String?) {
        if let leftCount = coupen.usageCountLeft, leftCount == 0 {
            return (false, "Coupon code has already been used")
        }
        guard let cart = UserDefaultsController.shared.cartSavedData else {return (false, nil)}
        
        if (coupen.minOrderAmt > 0.0 && coupen.preTax == "T") {
            if (itemsTotalCoupon < coupen.minOrderAmt){
                return (false, "Coupon code does not meet the minimum order of \(symbol)\(coupen.minOrderAmt.to2Decimal)")
            }
        }else{
            if (coupen.minOrderAmt > 0.0){
                if ((cart.preTaxAmt ?? 0) < coupen.minOrderAmt){
                    return (false, "Coupon code does not meet the minimum order of \(symbol)\(coupen.minOrderAmt.to2Decimal)")
                }
            }
        }
        let now = Date()
        if now < dateFromString(date: coupen.startDate) || now > dateFromString(date: coupen.endDate) {
            return (false, "Coupon code has expired")
        }
        return (true, nil)
    }
    func dateFromString(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current.restTimeZone()
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        return formatter.date(from: date) ?? Date()
    }
    
    func selectDiscountTapped(_ discount: Discount) {
        if (selectDiscount(discount)) { self.dissmiss = true }
    }
    
    private func selectDiscount(_ discount: Discount) -> Bool {
        var cardData = UserDefaultsController.shared.cartSavedData
        if cardData?.discountType == String(discount.id) || cardData?.discount1Type == String(discount.id) {
            self.error = "Discount is already selected."
            return false
        }
        if let offer = cardData?.itemList?.first(where: {$0.havespicialoffer}), offer.specialOffer?.allowDiscount == .f {
            self.getConsent = AlertWithAction(action: {
                CartManager().decrementItem(item: offer)
                self.selectDiscountTapped(discount)
            }, title: "\(offer.name) is not allowed with other Discount.", subtitle: "Do you want to remove the selected item and apply discount?")
            return false
        }

        guard discount.isDiscountAvailable() else {
            error = "Discount is not available"
            return false
        }
        if (cardData?.otherInfo?.lastAppliedCoupon) != nil, discount.coupon == .f {
            self.getConsent = AlertWithAction(action: {
                UserDefaultsController.shared.cartSavedData?.custCouponID = nil
                UserDefaultsController.shared.cartSavedData?.restChainCouponID = nil
                UserDefaultsController.shared.cartSavedData?.couponAmt = nil
                UserDefaultsController.shared.cartSavedData?.otherInfo?.lastAppliedCoupon = nil
                self.selectDiscountTapped(discount)
            }, title: "\(discount.discountDescription) is not allowed with other Coupon.", subtitle: "Do you want to replace the selected Coupon?")
            return false
        }
        
        if discount.lookup.lookupName == "Payment" {
            if cardData?.otherInfo?.lastAppliedDiscount1 != nil, discount.discount == .f {
                self.getConsent = AlertWithAction(action: {
                    UserDefaultsController.shared.cartSavedData?.otherInfo?.lastAppliedDiscount1 = nil
                    UserDefaultsController.shared.cartSavedData?.discountAmt = nil
                    UserDefaultsController.shared.cartSavedData?.discountType = nil
                    self.selectDiscountTapped(discount)
                }, title: "\(discount.discountDescription) is not allowed with other Discount.", subtitle: "Do you want to replace the selected Discount?")
                return false
                
            } else {
                cardData?.discount1Amt = String(discount.discountPrice())
                cardData?.discount1Type = String(discount.id)
                cardData?.otherInfo?.lastAppliedDiscount2 = discount
            }
        } else if let paymentDis = cardData?.otherInfo?.lastAppliedDiscount2, paymentDis.discount == .f {
            self.getConsent = AlertWithAction(action: {
                UserDefaultsController.shared.cartSavedData?.otherInfo?.lastAppliedDiscount2 = nil
                UserDefaultsController.shared.cartSavedData?.discount1Amt = nil
                UserDefaultsController.shared.cartSavedData?.discount1Type = nil
                self.selectDiscountTapped(discount)
            }, title: "\(paymentDis.discountDescription) is not allowed with other discount.", subtitle: "Do you want to replace the selected Discount?")
            return false
        } else  {
            cardData?.discountAmt = String(discount.discountPrice())
            cardData?.discountType = String(discount.id)
            cardData?.otherInfo?.lastAppliedDiscount1 = discount
        }
        
        if cardData?.otherInfo?.lastAppliedDiscount1 != nil, cardData?.otherInfo?.lastAppliedDiscount2 != nil {
            cardData?.custCouponID = nil
            cardData?.restChainCouponID = nil
            cardData?.couponAmt = nil
            cardData?.otherInfo?.lastAppliedCoupon = nil
        }
        UserDefaultsController.shared.cartSavedData = cardData
        return true
        
    }
    
    func selectCouponCode() -> Bool {
        let code = couponCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let coupon = allCoupons.first(where: {$0.couponCode.lowercased() == code.lowercased()}) else {
            self.error = "Coupon code is not available"
            return false
        }
        let (avail, error) = isCouponAvailable(coupen: coupon)
        if avail {
            return selectCoupon(coupon)
        } else {
            self.error = error
            return avail
        }
    }
    
    func selectCouponTapped(_ coupon: RestaurantCoupon) {
        if selectCoupon(coupon) { self.dissmiss = true }
    }
    
    private func selectCoupon(_ coupon: RestaurantCoupon) -> Bool {
        guard let order = UserDefaultsController.shared.cartSavedData else { return false }
        if order.custCouponID == coupon.id || order.restChainCouponID == coupon.id {
            self.error = "Coupon is already selected."
            return false
        }
        if let offer = order.itemList?.first(where: {$0.havespicialoffer}), offer.specialOffer?.allowCoupon == .f {
            self.getConsent = AlertWithAction(action: {
                CartManager().decrementItem(item: offer)
                self.selectCouponTapped(coupon)
            }, title: "\(offer.name) is not allowed with other Coupon.", subtitle: "Do you want to remove the selected item and apply Coupon?")
            return false
        }
        
        if let selectedDiscount = order.otherInfo?.lastAppliedDiscount1, selectedDiscount.coupon == .f {
            self.getConsent = AlertWithAction(action: {
                UserDefaultsController.shared.cartSavedData?.otherInfo?.lastAppliedDiscount1 = nil
                UserDefaultsController.shared.cartSavedData?.discountAmt = nil
                UserDefaultsController.shared.cartSavedData?.discountType = nil
                self.selectCouponTapped(coupon)
            }, title: "\(selectedDiscount.discountDescription) is not allowed with other Coupon.", subtitle: "Do you want to replace it?")
            return false
        }
        if let selectedDiscount = order.otherInfo?.lastAppliedDiscount2, selectedDiscount.coupon == .f {
            self.getConsent = AlertWithAction(action: {
                UserDefaultsController.shared.cartSavedData?.otherInfo?.lastAppliedDiscount2 = nil
                UserDefaultsController.shared.cartSavedData?.discount1Amt = nil
                UserDefaultsController.shared.cartSavedData?.discount1Type = nil
                self.selectCouponTapped(coupon)
            }, title: "\(selectedDiscount.discountDescription) is not allowed with other Coupon.", subtitle: "Do you want to replace it?")
            return false
        }
        
        if coupon.cType == "Specific" {
            UserDefaultsController.shared.cartSavedData?.custCouponID = coupon.id
            UserDefaultsController.shared.cartSavedData?.restChainCouponID = nil
        } else {
            UserDefaultsController.shared.cartSavedData?.restChainCouponID = coupon.id
            UserDefaultsController.shared.cartSavedData?.custCouponID = nil
        }
        
        if coupon.type == "$" {
            UserDefaultsController.shared.cartSavedData?.couponAmt = coupon.discount
        }
        if coupon.preTax == "T" {
            UserDefaultsController.shared.cartSavedData?.couponType = 0
            if coupon.type == "%" , coupon.discount < 1 {
                let dicount = itemsTotalCoupon * coupon.discount
                UserDefaultsController.shared.cartSavedData?.couponAmt = dicount
            }
        } else {
            UserDefaultsController.shared.cartSavedData?.couponType = 1
            if coupon.type == "%" , coupon.discount < 1 {
                let dicount = (itemsTotalCoupon + Double(order.taxAmt ?? 0)) * coupon.discount
                UserDefaultsController.shared.cartSavedData?.couponAmt = dicount
            }
            
        }
        UserDefaultsController.shared.cartSavedData?.otherInfo?.lastAppliedCoupon = coupon
        
        if order.otherInfo?.lastAppliedDiscount2 != nil, order.otherInfo?.lastAppliedDiscount1 != nil {
            UserDefaultsController.shared.cartSavedData?.otherInfo?.lastAppliedDiscount2 = nil
            UserDefaultsController.shared.cartSavedData?.discount1Amt = nil
            UserDefaultsController.shared.cartSavedData?.discount1Type = nil
        }
        return true
    }
}

