//
//  CartManager.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 23/11/20.
//

import Foundation


class CartManager {
    
    private func updateTotal() {
        let itemList = UserDefaultsController.shared.cartSavedData?.itemList ?? []
        let pretax: Double = itemList.map({$0.amt}).reduce(0.0, +)
        if let offer = itemList.first(where: {$0.havespicialoffer}),
           offer.havespicialofferAmount > pretax {
            decrementItem(item: offer)
        }
        UserDefaultsController.shared.cartSavedData?.preTaxAmt = pretax
    }
    
    func incrementItem(item: SelectedItemDetail) {
        guard let list = UserDefaultsController.shared.cartSavedData?.itemList else {return}
        UserDefaultsController.shared.cartSavedData?.itemList = list.map { (bb: SelectedItemDetail) -> SelectedItemDetail in
            var cc = bb
            if bb.myid == item.myid {
                cc.qty = bb.qty + 1
                let unitPrice = cc.unitPrice
                
                let addonPrice = cc.itemAddOnList?.map { (addon) -> Double in
                    addon.addOnOptions.map({max(0, $0.amt)}).reduce(0.0, +)
                }.reduce(0.0, +) ?? 0
                
                let itemFinalPrice = (addonPrice + unitPrice) * Double(cc.qty)
                cc.amt = itemFinalPrice
                return cc
            } else {
                return bb
            }
        }
        updateTotal()
    }
    
    func decrementItem(item: SelectedItemDetail) {
        guard var itemList = UserDefaultsController.shared.cartSavedData?.itemList else {return}
        if (itemList.first(where: {$0.myid == item.myid})?.qty ?? 0) > item.minQ {
            UserDefaultsController.shared.cartSavedData?.itemList = itemList.map({ (aa: SelectedItemDetail) -> SelectedItemDetail in
                if aa.myid == item.myid {
                    var cc = aa
                    cc.qty = aa.qty - 1
                    let unitPrice = cc.unitPrice
                    
                    let addonPrice = cc.itemAddOnList?.map { (addon) -> Double in
                        addon.addOnOptions.map({max(0, $0.amt)}).reduce(0.0, +)
                    }.reduce(0.0, +) ?? 0
                    
                    let itemFinalPrice = (addonPrice + unitPrice) * Double(cc.qty)
                    cc.amt = itemFinalPrice
                    return cc
                } else {
                    return aa
                }
            })
        } else {
            itemList.removeAll(where: {$0.myid == item.myid})
            if itemList.isEmpty {
                UserDefaultsController.shared.removeCartData()
            } else {
                UserDefaultsController.shared.cartSavedData?.itemList = itemList
                if item.havespicialoffer {
                    UserDefaultsController.shared.cartSavedData?.otherInfo?.isSpecialSelected = false
                }
            }
        }
        updateTotal()
        
    }
    
    func addItemWithAddons(selectedSize: ItemListSize?, item: ItemList, count: Int, catData: SelectedCatData, instructions: String) {
        
        var item = item
        
        item.addOnList = item.addOnList.map { (aa: AddOnList) -> AddOnList in
            var addOns = aa
            addOns.addOnOptions.removeAll(where: {!$0.isSelected})
            return addOns
        }
        item.addOnList.removeAll(where: {$0.addOnOptions.isEmpty})
        
        let itemAddonList = item.addOnList.map { (addon) -> ItemAddOnList in
            let cartOption = addon.addOnOptions.map { (addonOption) -> CartAddOnOption in
                
                var modifyOne: CartAddOnOptionModifier1?
                var modify2: CartAddOnOptionModifier1?
                
                if let option = addon.addOnOptionModifier1, option.labels.indices.contains(addonOption.modifier1SelectedIndex){
                    let factor = option.factors[addonOption.modifier1SelectedIndex]
                    let label = option.labels[addonOption.modifier1SelectedIndex]
                    modifyOne = CartAddOnOptionModifier1(factor: factor, label: label, text: String(option.id))
                }
                
                if let option = addon.addOnOptionModifier2, option.labels.indices.contains(addonOption.modifier2SelectedIndex){
                    let factor = option.factors[addonOption.modifier2SelectedIndex]
                    let label = option.labels[addonOption.modifier2SelectedIndex]
                    modify2 = CartAddOnOptionModifier1(factor: factor, label: label, text: String(option.id))
                }
                let unitprice = (addonOption.value(for: selectedSize?.key ?? "") as? Double ?? 0)
                let amt = unitprice * (modifyOne?.factor ?? 1) * (modify2?.factor ?? 1)
                return CartAddOnOption(addOnOptionModifier1: modifyOne, addOnOptionModifier2: modify2, amt: amt, id: addonOption.id, isSelected: addonOption.isSelected, name: addonOption.name, portionID: selectedSize?.id, qty: count, unitPrice: unitprice)
            }
            return ItemAddOnList(addOnOptions: cartOption, itemAddOnID: addon.itemAddOnID, name: addon.name)
        }
        let unitPrice = selectedSize?.price ?? 0
        let priceAfterAddon = itemAddonList.map { (addon) -> Double in
            addon.addOnOptions.map({max(0, $0.amt)}).reduce(0.0, +)
        }.reduce(0.0, +) + unitPrice
        let itemFinalPrice = priceAfterAddon * Double(count)
        
        let specialOffer = item.specialOffer != nil
        
        let data = SelectedItemDetail(myid: UUID(), amt: itemFinalPrice, categoryID: catData.id, havespicialoffer: specialOffer, havespicialofferAmount: (item.specialOffer?.amt1 ?? 0), itemId: item.id, itemAddOnList: itemAddonList, name: item.name, portionID: selectedSize?.id, qty: count, specialInstructions: instructions, unitPrice: unitPrice, minQ: item.minQ, maxQ: item.maxQ, isTaxFree: item.isTaxFree, isAllowCoupon: item.isAllowCoupon != false, isAllowDiscount: item.isAllowDiscount, categoryData: catData, specialOffer: item.specialOffer)
        
        let tempData = UserDefaultsController.shared.tempCartData
        let tempRestaurant = tempData.restaurant
        if let savedOrder = UserDefaultsController.shared.cartSavedData,
           (savedOrder.locationID == tempRestaurant?.id) {
            UserDefaultsController.shared.cartSavedData?.itemList?.append(data)
            UserDefaultsController.shared.cartSavedData?.otherInfo?.restaurant = tempRestaurant!
        } else {
            let otherData = OtherData(restaurant: tempRestaurant!, restaurantSavedAt: Date(), cartSuggestedMenu: tempData.suggestedMenu!, mobUrl: tempData.mobUrl!, isAsap: tempData.isAsap!, isToday: tempData.isToday!, isFuture: tempData.isFuture!)
            let setOrder = OrderData(dineInTableNum: "", otherInfo: otherData, specialInstructions: "", carcolor: "", carmake: "", carmodel: "", carplatenumber: "", couponType: nil, couponAmt: nil, couponDescription: nil, createdOn: nil, custCouponID: nil, custID: nil, deliveryInfo: nil, discountAmt : nil, discountType: nil ,dueOn: nil, isPrinterMsgOk: "0", itemList: [data], locationID: tempRestaurant?.id, menuID: tempData.menuId, paymentTypeID: nil, placeOrder: "T", preTaxAmt: itemFinalPrice, restChainCouponID: nil, restChainID: tempRestaurant?.restChainID, serviceID: nil, status: 1, srvcFee: 0.0, taxAmt: nil, timeSelection: nil, tipAmt: nil, totalAmt: itemFinalPrice, utmSource: "", orderFrom: "iOS")
            UserDefaultsController.shared.removeCartData()
            UserDefaultsController.shared.cartSavedData = setOrder
            
        }
        if UserDefaultsController.shared.cartSavedData?.otherInfo?.isSpecialSelected == false {
            UserDefaultsController.shared.cartSavedData?.otherInfo?.isSpecialSelected = specialOffer
        }
        updateTotal()
        NotificationCenter.default.post(name: .newItemAddedTocart, object: nil)
    }
    
}
