//
//  TabbarView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 04/11/20.
//

import SwiftUI

struct TabbarView: View {
    init() {
        UITabBar.appearance().barTintColor = UIColor.white
    }
    
    @StateObject var appStorage = UserDefaultsController.shared
    @StateObject var viewModel = TabbarSelection()
    var cartChooseView: some View {
        ZStack {
            if appStorage.cartSavedData?.itemList?.isEmpty ?? true {
                EmptyCartView()
            } else {
                CartView()
            }
        }
    }
    
    var profileChooseView: some View {
        ZStack {
            if appStorage.userModel == nil {
                EmptyProfileView()
            } else {
                ProfileView()
            }
            if let (mobUrl, reorderData) = viewModel.restReoderData {
                NavigationLink(destination: RestaurantView(mobUrl: mobUrl, reorder: reorderData),
                               isActive: $viewModel.pushTORestaurantForReorder,
                               label: {EmptyView()})
            }
        }
    }
    
    var body: some View {
        Navigation(
            TabView(selection: $viewModel.tabSelection) {
                HomeView()
                    .tabItem {
                        Image("tabHome")
                        Text("Home")
                    }
                    .font(.headline)
                    .tag(0)
                cartChooseView
                    .tabItem {
                        Image("tabCart")
                        Text("My Cart")
                    }
                    .font(.headline)
                    .tag(1)
                
                profileChooseView
                    .tabItem {
                        Image("tabUser")
                        Text("Profile")
                    }
                    .font(.headline)
                    .tag(2)
            }
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .accentColor(Color.appAccent)
                .sheet(isPresented: $viewModel.getMobileNumber, content: {
                    ExtraSignUpDataView()
                })
        )
            .environmentObject(viewModel)
    }
}

class TabbarSelection: ObservableObject {
    @Published var tabSelection = 0
    @Published var pushToOrderHistory = false {
        didSet {
            print("----------", pushToOrderHistory)
        }
    }
    @Published var restReoderData: (mobUrl: String, order: OrderDetailModel)?
    @Published var pushTORestaurantForReorder = false
    @Published var getMobileNumber = false
    @Published var showOrderSuccess = false
}
