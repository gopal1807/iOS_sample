//
//  ChooseSizeViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 22/11/20.
//

import SwiftUI

class ChooseSizeViewModel: ObservableObject {
    let category: CatList
    let itemId: Int
    let currencySymbol: String
    @Published var item: ItemList
    let availableSize: [ItemListSize]
    @Published var selectedSize: ItemListSize?
    @Published var itemCount = 1
    @Published var specialInstructions = "Special Instructions"
    @Published var totalPrice = 0.0
    @Published var error: String?
    
    init(category: CatList, itemId: Int, currencySymbol: String) {
        self.category = category
        self.itemId = itemId
        self.currencySymbol = currencySymbol
        var item = category.itemList.first(where: {$0.id == itemId})!
        
        let sizesAvailable = [
            ItemListSize(id: category.p1?.id ?? -1, name: category.p1?.name ?? "", price: item.p1, key: "p1"),
            ItemListSize(id: category.p2?.id ?? -1, name: category.p2?.name ?? "", price: item.p2, key: "p2"),
            ItemListSize(id: category.p3?.id ?? -1, name: category.p3?.name ?? "", price: item.p3, key: "p3"),
            ItemListSize(id: category.p4?.id ?? -1, name: category.p4?.name ?? "", price: item.p4, key: "p4"),
            ItemListSize(id: category.p5?.id ?? -1, name: category.p5?.name ?? "", price: item.p5, key: "p5"),
            ItemListSize(id: category.p6?.id ?? -1, name: category.p6?.name ?? "", price: item.p6, key: "p6"),
        ].filter({$0.id > 0 && $0.price >= 0})
        availableSize = sizesAvailable.removingDuplicates()
        self.selectedSize = availableSize.first
        
        for (index,addon) in item.addOnList.enumerated() {
            if addon.reqd == .t {
                let min = max(1, addon.min)
                item.addOnList[index].min = min
                for (index1, _) in item.addOnList[index].addOnOptions.enumerated() {
                    if index1 < min {
                        item.addOnList[index].addOnOptions[index1].isSelected = true
                    }
                }
            }
        }
        self.item = item
        self.itemCount = max(1, item.minQ)
        calculatePrice()
    }
    
    func getModifier(for option: AddOnOption, inList: AddOnList, modifiId: Int) -> Binding<Int> {
        Binding(get: {
            if modifiId == 1 {
                return option.modifier1SelectedIndex
            } else {
                return option.modifier2SelectedIndex
            }
        }) { (newVal) in
            var option = option
            if modifiId == 1 {
                option.modifier1SelectedIndex = newVal
            } else {
                option.modifier2SelectedIndex = newVal
            }
            if let index = inList.addOnOptions.firstIndex(where: {$0.id == option.id}) {
                var addon = inList
                addon.addOnOptions[index] = option
                if let index = self.item.addOnList.firstIndex(where: {$0.id == addon.id}) {
                    self.item.addOnList[index] = addon
                    self.calculatePrice()
                }
            }
        }
    }
    
    func calculatePrice() {
        guard let selectedSize = selectedSize else { return }
        var item = self.item
        item.addOnList = item.addOnList.map { (aa: AddOnList) -> AddOnList in
            var addOns = aa
            addOns.addOnOptions.removeAll(where: {!$0.isSelected})
            return addOns
        }
        item.addOnList.removeAll(where: {$0.addOnOptions.isEmpty})
        let totalPrice = item.addOnList.map { (addOn: AddOnList) -> Double in
            addOn.addOnOptions.map { (option: AddOnOption) -> Double in
                var optionPrice = max(0, (option.value(for: selectedSize.key) as? Double ?? 0))
                if let factor1 = addOn.addOnOptionModifier1?.factors, factor1.indices.contains(option.modifier1SelectedIndex) {
                    let factorPrice = factor1[option.modifier1SelectedIndex]
                    optionPrice = factorPrice * optionPrice
                }
                if let factor1 = addOn.addOnOptionModifier2?.factors, factor1.indices.contains(option.modifier2SelectedIndex) {
                    let factorPrice = factor1[option.modifier2SelectedIndex]
                    optionPrice = factorPrice * optionPrice
                }
                return optionPrice
            }.reduce(0.0, +)
        }.reduce(0.0, +)
        
        let price = (totalPrice + selectedSize.price) * Double(itemCount)
        self.totalPrice = price
    }
    
    func minusTapped() {
        guard self.item.minQ < itemCount else {
            self.error = "Minimum \(self.item.minQ) can be ordered for this item."
            return
        }
        itemCount = max(1, itemCount-1)
        calculatePrice()
    }
    
    func plusTapped() {
        if self.item.maxQ > 0, self.item.maxQ == itemCount {
            return
        }
        itemCount = itemCount + 1
        calculatePrice()
    }
    
    func addItem() -> Bool {
        for (addon) in item.addOnList {
            if addon.reqd == .t {
                let selected = addon.addOnOptions.filter({$0.isSelected})
                if  selected.count < addon.min {
                    error = "Minimum \(addon.min) should selected for \(addon.name)"
                    return false
                }
            }
        }
        
        if item.minP > totalPrice {
            error = "Minimum price for \(item.name) is \(currencySymbol)\(item.minP.to2Decimal)"
            return false
        }
        
        let instruction = specialInstructions == "Special Instructions" ? "" : specialInstructions
        CartManager().addItemWithAddons(selectedSize: selectedSize, item: item, count: itemCount, catData: SelectedCatData(id: category.id, name: category.catName, openTime: category.openTime, closeTime: category.closeTime), instructions: instruction
            .replacingOccurrences(of: ">", with: "")
            .replacingOccurrences(of: "<", with: ""))
        
        return true
    }
    
    func getAddOnTitle(addOn: AddOnOption) -> String {
        var title = addOn.name
        if let price = addOn.value(for: selectedSize?.key ?? "") as? Double, price > 0 {
            title += " \(currencySymbol)\(price.to2Decimal)"
        }
        return title
    }
    
    func selectAddon(addon: AddOnList, option: AddOnOption) {
        var addon = addon
        if addon.dispType != "M" {
            for (i, op) in addon.addOnOptions.enumerated() {
                addon.addOnOptions[i].isSelected = op.id == option.id
            }
        } else if let index = addon.addOnOptions.firstIndex(where: {$0.id == option.id}) {
            let max = addon.max
            let selected  = addon.addOnOptions.filter({$0.isSelected}).count
            if selected < max || (addon.addOnOptions[index].isSelected) {
                addon.addOnOptions[index].isSelected.toggle()
            } else {
                self.error = "Maximum \(max) can be selected for \(addon.name)"
            }
        }
        if let index = self.item.addOnList.firstIndex(where: {$0.id == addon.id}) {
            self.item.addOnList[index] = addon
        }
        calculatePrice()
    }
    
}

struct ItemListSize: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let price: Double
    let key: String
    
    static func == (lhs: ItemListSize, rhs: ItemListSize) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
