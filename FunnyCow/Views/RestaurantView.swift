//
//  RestaurantView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 05/11/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct RestaurantView: View {
    
    init(mobUrl: String, reorder: OrderDetailModel? = nil) {
        _viewModel = StateObject(wrappedValue: RestaurantViewModel(mobUrl: mobUrl, reorder: reorder))
    }
    
    @StateObject var viewModel: RestaurantViewModel
    @Environment(\.presentationMode) var presentationMode
    @Namespace var namespace
    @EnvironmentObject var tabSelection: TabbarSelection
    
    var body: some View {
        ZStack {
            Text("")
                .sheet(isPresented: $viewModel.presentChooseSize, onDismiss: {
                    
                }, content: {
                    let chooseSizeFor = viewModel.selectedItemToAdd!
                    ChooseSizeView(catList: chooseSizeFor.catList, item: chooseSizeFor.item, currencySymbol: viewModel.currencySymbol)
                })
            
            VStack {
                if let rest = viewModel.restaurantData {
                    restaurantHeader(rest)
                }
                Divider()
                if viewModel.showLaoder {
                    VStack {
                        LottieView(name: "food")
                            .frame(width: 150, height: 150)
                        
                        Text("Please wait\nYour menu is loading")
                            .multilineTextAlignment(.center)
                    }
                    .offset(y: -100)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    let catogories = viewModel.menuCategories
                    ScrollView {
                        ForEach(catogories) { item in
                            tableSectionView(isOpen: viewModel.openCategories.contains(item.id), catList: item)
                        }
                    }
                }
                let addedItems = viewModel.checkCartAddedItems()
                
                if addedItems.count > 0 {
                    itemsPrice(count: addedItems.count, total: addedItems.total)
                }
                
            }
            // Show selected Image Full screen
            if let image = viewModel.selectedFullImage {
                ZStack {
                    WebImage(url: URL(string: image))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .matchedGeometryEffect(id: image, in: namespace)
                    
                    Button {
                        withAnimation(.spring()){
                            viewModel.selectedFullImage = nil
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .position(x: 12, y: 12)
                    .padding()
                    
                }.background(Color.white.edgesIgnoringSafeArea(.all))
            }
            
            ForEach(viewModel.alerts) { alert in
                AlertView(alert: alert, showAnimation: true) {
                    viewModel.alerts.removeAll(where: {$0.id == alert.id})
                }
            }
        }
        .statusBar(hidden: viewModel.selectedFullImage != nil)
        .navigationBarHidden(viewModel.selectedFullImage != nil)
        .navigationBarTitle(viewModel.restaurantData?.name ?? "", displayMode: .inline)
        .navigationBarItems(trailing:
                                viewModel.restaurantData != nil ?
                            NavigationLink(destination: RestaurantDetailView(viewModel: RestaurantDetailViewModel(data: viewModel.restaurantData!)), label: {
            Image(systemName: "info.circle.fill")
                .imageScale(.large)
        }) : nil
        )
    }
    
    fileprivate func itemsPrice(count: Int, total: String) -> some View {
        
        return HStack {
            Text("\(count) Items")
                .font(.callout)
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 1, height: 20)
            Text(total)
                .font(.headline)
            Spacer()
            Text("VIEW CART")
                .font(.subheadline)
            Image(systemName: "arrow.right")
                .font(.headline)
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.appAccent
                        .ignoresSafeArea(.container))
        .onTapGesture {
            viewModel.selectedFullImage = "" // hide navigation before continue
            presentationMode.wrappedValue.dismiss()
            tabSelection.tabSelection = 1
        }
    }
    
    fileprivate func restaurantHeader(_ rest: RestaurantModel) -> some View {
        return HStack(alignment: .top, spacing: 10) {
            WebImage(url: URL(string: restaurantImageBaseUrl + (rest.logoImg ?? "")), options: .delayPlaceholder)
                .placeholder(Image("restaurantPlaceholder").resizable())
                .resizable()
                .imageSize(with: 100)
            VStack(alignment: .leading) {
                Text(rest.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.appAccent)
                if let discount = rest.discounts.first {
                    Button(action: {
                        viewModel.alerts.append(AlertTitle(title: "Save \(discount.toString())", subTitle: discount.discountDescription))
                    }) {
                        Text("Save \(discount.toString()) \(discount.lookup.lookupName == "FirstOrder" ? "on First Order" : "Tap Here")")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.white)
                            .padding(.all, 6.0)
                            .background(Color.appAccent)
                            .cornerRadius(5.0)
                    }
                }
                HStack {
                    Image("shop")
                    Text(viewModel.openTime)
                        .font(.callout)
                }
                .foregroundColor(viewModel.isOpenNow ? Color.green : Color.red)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 5)
        }
    }
    
    func tableSectionView(isOpen: Bool, catList: CatList) -> some View {
        Group {
            sectionHeaderView(catList: catList, isOpen: isOpen)
            if isOpen {
                VStack {
                    ForEach(catList.itemList) { item in
                        cellView(item, catList: catList)
                        Divider()
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4.0)
    }
    
    fileprivate func sectionHeaderView(catList: CatList, isOpen: Bool) -> some View {
        let formatter = DateFormatter()
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(catList.catName.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.title3)
                    .fontWeight(.medium)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                if catList.openTime != "00:00:00" || catList.closeTime != "00:00:00" {
                    Text("\(formatter.two4To12hr(time: catList.openTime)) - \(formatter.two4To12hr(time: catList.closeTime))")
                        .font(.footnote)
                        .foregroundColor(Color.appGreen)
                }
                Image(systemName: "chevron.right")
                    .imageScale(.large)
                    .foregroundColor(Color.appAccent)
                    .rotationEffect(.init(degrees: isOpen ? 90 : 0))
                
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.addOpenCategory(cat: catList)
            }
            if isOpen, !catList.desc.isEmpty {
                Text(catList.desc)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .animation(.linear)
    }
    
    fileprivate func cellView(_ item: ItemList, catList: CatList) -> some View {
        let imageRepos = viewModel.restaurantMenuData?.imageRepository ?? []
        let icons = item.getIcons()
        return HStack(alignment: .top, spacing: 5) {
            if catList.isShowItemImages == "True" {
                let image = menuImageBaseUrl + item.getImage(imageRepos: imageRepos)
                WebImage(url: URL(string: image))
                    .resizable()
                    .imageSize(with: 100)
                    .matchedGeometryEffect(id: image, in: namespace)
                    .onTapGesture {
                        withAnimation(.spring()){
                            viewModel.selectedFullImage = image
                        }
                    }
            }
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top) {
                    Text(item.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(#colorLiteral(red: 0.2300000042, green: 0.2300000042, blue: 0.2300000042, alpha: 1)))
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(0 ..< min(3, icons.count)) { i in
                        WebImage(url: URL(string: icons[i]))
                            .resizable()
                            .frame(maxWidth: 16, maxHeight: 16)
                    }
                    Spacer()
                    Button(action: {
                        viewModel.addItemTapped(catList: catList, item: item)
                    }) {
                        AddButton(count: viewModel.checkAdded(for: item))
                    }
                    .layoutPriority(1)
                }
                Text("\(viewModel.currencySymbol)\(item.getSomePrice().to2Decimal)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.red)
                Text(item.getDescription(imageRepos: imageRepos))
                    .font(.footnote)
                    .fontWeight(.regular)
                    .foregroundColor(Color.gray)
            }
        }
    }
    
    
}



struct AddButton: View {
    var count: Int
    var body: some View {
        HStack {
            Text(count > 0 ? "\(count) Added" : "Add")
                .font(.callout)
                .fontWeight(.regular)
                .foregroundColor(Color.gray)
            Image(systemName: "plus.circle.fill")
                .imageScale(.medium)
                .foregroundColor(Color.appAccent)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .overlay(
            Capsule()
                .strokeBorder(Color.gray)
        )
    }
}
