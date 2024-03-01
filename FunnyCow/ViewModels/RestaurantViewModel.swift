//
//  RestaurantViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 20/11/20.
//

import Foundation
import SwiftUI

class RestaurantViewModel: ObservableObject {
    
    init(mobUrl: String, reorder: OrderDetailModel?) {
        self.mobUrl = mobUrl
        self.reorder = reorder
        getToken()
    }
    var reorder: OrderDetailModel?
    @Published var restaurantData: RestaurantModel?
    var restaurantMenuData: RestaurantMenuResponse?
    @Published var menuCategories = [CatList]()
    @Published var showLaoder = false
    @Published var selectedTab: Int?
    @Published var showRestaurantDetails = false
    @Published var discountTapped = false
    @Published var alerts = [AlertTitle]()
    @Published var openCategories: Set<Int> = []
    var selectedItemToAdd: (catList: CatList, item: ItemList)?
    @Published var presentChooseSize = false
    @Published var selectedFullImage: String?

    var appStorage: OrderData?  {
        get {
            UserDefaultsController.shared.cartSavedData
        }
        set {
            UserDefaultsController.shared.cartSavedData = newValue
        }
    }
      
    var currencySymbol: String {
        appStorage?.otherInfo?.restaurant.currencyDetail.symbol ?? "$"
    }
    var isOpenNow = false
    var openTime = ""
    let mobUrl: String
    
    func getToken() {
        showLaoder = true
        let body = GetNewTokenBody(appCode: appCode, data: GetTokenBodyData(mobURL: mobUrl, traceID: ""), mobURL: "http://www.imenu360.mobi/?id=" + mobUrl)
        HitApi.shared.postData("GetNewToken", bodyData: body) { (result: Result<GetNewTokenResponse, HitApiError>) in
            self.showLaoder = false
            switch result {
            case .success(let result):
                let body = LocationDetailReq(data: LocationDetailReqData(locationID: result.locationID, menuID: 0, mobURL: self.mobUrl), tID: result.tID)
                AppToken.shared.tid = result.tID
                self.getRestaurantDetail(body: body)
            case .failure(let error):
                self.alerts.append(AlertTitle(title: error.toString(), subTitle: ""))
            }
        }
    }
    func getRestaurantDetail(body: LocationDetailReq) {
        showLaoder = true
        HitApi.shared.postData("GetLocationdetails", bodyData: body) { (result: Result<RestaurantModel, HitApiError>) in
            self.showLaoder = false
            switch result {
            case .success(let result):
                self.restaurantData = result
                print("rest coupons:--", result.coupons.map({$0.couponCode}))
                self.checkRestaurantOpen(rest: result, body: body)
                UserDefaultsController.shared.tempCartData.mobUrl = self.mobUrl
                UserDefaultsController.shared.tempCartData.restaurant = result
              
            case .failure(let error):
                self.alerts.append(AlertTitle(title: error.toString(), subTitle: ""))
            }
        }
    }

    func checkRestaurantOpen(rest: RestaurantModel, body: LocationDetailReq) {
        let (isOpenToday,schedule) = rest.checkIsRestaurantOpen()
        let ot1 = schedule?.ot1 ?? ""
        let ct2 = schedule?.ct2 ?? ""
        let formatter = DateFormatter()
        if schedule?.closed == .t {
            self.openTime = "CLOSED"
        } else {
            self.openTime = isOpenToday
                ? ("OPEN " + formatter.two4To12hr(time: ot1) + " TO " + formatter.two4To12hr(time: ct2))
                : "CLOSED TILL " + formatter.two4To12hr(time: ot1)
        }
        let restAlerts = rest.alertsForNow()
            .map({$0.htmlToString})
            .map({AlertTitle(title: rest.name, subTitle: $0)})
        
        self.alerts.append(contentsOf: restAlerts)
        
        isOpenNow = isOpenToday
        var body = body
        body.data.menuID = self.restaurantData?.menus.first?.id ?? 0
        self.getMenuForRestaurant(reqBody: body, isOpen: isOpenToday)
    }
    
    func checkCartAddedItems() -> (count: Int, total: String) {
        guard (restaurantData?.id ?? -1) == appStorage?.locationID else {return (0, "")}
        let count = appStorage?.itemList?.map({$0.qty}).reduce(0, +)
        let cost = currencySymbol + (appStorage?.preTaxAmt?.to2Decimal ?? "0")
        return (count ?? 0, cost)
    }
    
    func getMenuForRestaurant(reqBody: LocationDetailReq, isOpen: Bool) {
        self.showLaoder = true
        HitApi.shared.postData("GetMenuDetail", bodyData: reqBody) { (result: Result<RestaurantMenuResponse, HitApiError>) in
            self.showLaoder = false
            switch result {
            case .success(let result):
                self.restaurantMenuData = result
                self.setRestaurantMenu()
                
                var suggestedItems = [SuggestedMenu]()
                
                for cat in result.catList {
                    for item in cat.itemList {
                        if item.isShowforSuggestion == "True" {
                            suggestedItems.append(SuggestedMenu(item: item, category: cat))
                        }
                    }
                }
                
                var temp = UserDefaultsController.shared.tempCartData
                temp.suggestedMenu = suggestedItems
                temp.menuId = result.menuID
                temp.isAsap = result.asap == .some(.t)
                temp.isToday = result.lt == .some(.t)
                temp.isFuture = result.fo == .some(.t)
                UserDefaultsController.shared.tempCartData = temp
                self.addReorderData()
                if !isOpen {
                    let message = (result.lt == .some(.t) && result.fo == .some(.t))
                        ? "Sorry, We Are Currently Closed But You Can Place Order For Later Today And Future Dates"
                        : result.lt == .some(.t) ? "Sorry, We Are Currently Closed But You Can Place Order For Later Today"
                        : result.fo == .some(.t) ? "Sorry, We Are Currently Closed But You Can Place Order For Future Dates"
                        : "Sorry, We Are Currently Closed."
                    self.alerts.append(AlertTitle(title: self.restaurantData?.name ?? "", subTitle: message))
                }
                
            case .failure(let error):
                self.alerts.append(AlertTitle(title: error.toString(), subTitle: ""))
            }
        }
    }
    
    func addReorderData() {
        guard let reorderData = self.reorder else { return }
        let manager = CartManager()
        for item in reorderData.itemList {
            if let count = Int(item.qty), let cat = self.menuCategories.first(where: {$0.catID == Int(item.catID)}) {
                if var itemList = cat.itemList.first(where: {$0.id == item.id}) {
                    let availableSize = [
                        ItemListSize(id: cat.p1?.id ?? -1, name: cat.p1?.name ?? "", price: itemList.p1, key: "p1"),
                        ItemListSize(id: cat.p2?.id ?? -1, name: cat.p2?.name ?? "", price: itemList.p2, key: "p2"),
                        ItemListSize(id: cat.p3?.id ?? -1, name: cat.p3?.name ?? "", price: itemList.p3, key: "p3"),
                        ItemListSize(id: cat.p4?.id ?? -1, name: cat.p4?.name ?? "", price: itemList.p4, key: "p4"),
                        ItemListSize(id: cat.p5?.id ?? -1, name: cat.p5?.name ?? "", price: itemList.p5, key: "p5"),
                        ItemListSize(id: cat.p6?.id ?? -1, name: cat.p6?.name ?? "", price: itemList.p6, key: "p6"),
                    ].filter({$0.id > 0 && $0.price >= 0})
                    let size = availableSize.first(where: {$0.id == Int(item.portionID)})
                    let filteredList = itemList.addOnList.filter { (addonList: AddOnList) -> Bool in
                        item.itemAddOnList.contains(where: {$0.itemAddOnID == addonList.itemAddOnID})
                    }
                    itemList.addOnList = filteredList.map { (aa: AddOnList) -> AddOnList in
                        var addOns = aa
                        let filOptions = aa.addOnOptions.compactMap({ (option: AddOnOption) -> AddOnOption? in
                            for selectedAddon in item.itemAddOnList where selectedAddon.addOnOptions.contains(where: {$0.itemId == option.id}) {
                                    var opt = option
                                    opt.isSelected = true
                                    return opt
                                }
                            return nil
                        })
                        addOns.addOnOptions = filOptions
                        return addOns
                    }
                    let catData = SelectedCatData(id: cat.id, name: cat.catName, openTime: cat.openTime, closeTime: cat.closeTime)
                    manager.addItemWithAddons(selectedSize: size, item: itemList, count: count, catData: catData, instructions: item.specialInstructions)
                }
            }
        }
    }
    
    func setRestaurantMenu() {
        guard let timeZone = self.restaurantData?.timeZone else {return}
        self.menuCategories.removeAll()
        var filteredCatList = self.restaurantMenuData!.catList.map { (a: CatList) -> CatList in
            var cat = a
            let date = Date()
            cat.itemList.removeAll(where: {!$0.openOn.isOpenToday(timeZone: timeZone, date: date)})
            return cat
        }
        filteredCatList.removeAll(where: {$0.itemList.isEmpty})
        self.restaurantMenuData?.catList = filteredCatList
        self.menuCategories = filteredCatList
        self.openCategories.insert(filteredCatList.first?.id ?? 0)
    }
    
    func addItemTapped(catList: CatList, item: ItemList) {
        if let offer = item.specialOffer  {
            if restaurantData?.id ?? 0 == UserDefaultsController.shared.cartSavedData?.locationID {
                if offer.amt1 > (UserDefaultsController.shared.cartSavedData?.preTaxAmt ?? 0) {
                    self.alerts.append(AlertTitle(title: "Minimum order should be \(currencySymbol)\(offer.amt1.to2Decimal)", subTitle: ""))
                    return
                } else if UserDefaultsController.shared.cartSavedData?.otherInfo?.isSpecialSelected == true {
                    self.alerts.append(AlertTitle(title: "You already have a offer item", subTitle: ""))
                    return
                }
            } else {
                self.alerts.append(AlertTitle(title: "Minimum order should be \(currencySymbol)\(offer.amt1.to2Decimal)", subTitle: ""))
                return
            }
        }
        self.selectedItemToAdd = (catList, item)
        self.presentChooseSize = true
    }
    
    func checkAdded(for item: ItemList) -> Int {
        var count = 0
        if var orderDat = appStorage, orderDat.locationID == (UserDefaultsController.shared.tempCartData.restaurant?.id ?? 0) {
            if !(orderDat.itemList?.isEmpty ?? true) {
                orderDat.itemList?.removeAll(where: {$0.itemId != item.id})
                count = orderDat.itemList?.map({$0.qty}).reduce(0, +) ?? 0
            }}
        return count
    }
    
    func addOpenCategory(cat: CatList) {
        if openCategories.contains(cat.id) {
            openCategories.remove(cat.id)
        } else {
            openCategories.insert(cat.id)
        }
    }
}


