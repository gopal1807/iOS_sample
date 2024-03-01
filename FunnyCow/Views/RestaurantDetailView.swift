//
//  RestaurantDetailView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 16/11/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct RestaurantDetailView: View {
    
    let viewModel: RestaurantDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("Address:").bold()
                Text(viewModel.restaurantData.address.toString())
            }
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Telephone:").bold()
                    }
                    if (!viewModel.pickup.isEmpty) {
                        HStack {
                            Image(systemName: "timelapse") //TODO: change icon
                            Text("Pickup:").bold()
                        }
                    }
                    if (!viewModel.delivery.isEmpty) {
                        HStack {
                            Image(systemName: "square.grid.2x2.fill") //TODO: Change icon
                            Text("Delivery:").bold()
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(viewModel.restaurantData.tel)
                    if (!viewModel.pickup.isEmpty) {
                        Text(viewModel.pickup)
                    }
                    if (!viewModel.delivery.isEmpty) {
                        Text(viewModel.delivery)
                    }
                }
            }
            
            Text("Service Accepted").bold().padding(.vertical)
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: -1) {
                    ForEach(0..<viewModel.services.count, id: \.self) { y in
                        let service = viewModel.services[y]
                        let comuns = Array(repeating: GridItem(.fixed(100), spacing: -1), count: service.count)
                        LazyVGrid(columns: comuns, spacing: -1, content: {
                            ForEach(0..<service.count, id: \.self) { x in
                                let name = service[x]
                                let font = Font.system(size: 16, weight: x == 0 || y == 0 ? .bold : .regular)
                                Text(name)
                                    .font(font)
                                    .frame(maxWidth: .infinity, maxHeight: 100, alignment: .center)
                                    .border(Color.gray)
                            }
                        })
                    }
                }
            }
            
            Text("Payment Accepted").bold().padding(.vertical)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.payments, id: \.self) { item in
                        WebImage(url: URL(string: item))
                    }
                }
            }
            Spacer()
            
        }
        .padding(.horizontal, 10)
        .navigationBarTitle(viewModel.restaurantData.name, displayMode: .inline)
    }
    
    
}

class RestaurantDetailViewModel {
    let restaurantData: RestaurantModel
    
    var services = [
        ["Name", "Available", "Min Order", "Min Charge", "Ready In"]
        
    ]
    var payments = [String]()
    var pickup = ""
    var delivery = ""
    init(data: RestaurantModel) {
        restaurantData = data
        
        let (_, schedule) = restaurantData.checkIsRestaurantOpen()
        let formatter = DateFormatter()
        
        if let schedule = schedule {
            let serviceNames = restaurantData.services.map({$0.name.lowercased()})
            
            if serviceNames.contains("pickup") {
                let firOrd = formatter.two4To12hr(time: schedule.firstOrd)
                let lastOrd = formatter.two4To12hr(time: schedule.lastOrd)
                pickup = firOrd + " to " + lastOrd
            }
            if serviceNames.contains("delivery") {
                let firDel = formatter.two4To12hr(time: schedule.firstDel)
                let lastDel = formatter.two4To12hr(time: schedule.lastDel)
                delivery = firDel + " to " + lastDel
            }
        }
        for service in restaurantData.services {
            self.services.append([service.name, "Yes", restaurantData.currencyDetail.symbol +  service.minOrder.toDouble.to2Decimal, restaurantData.currencyDetail.symbol +  service.minCharges.toDouble.to2Decimal, service.readyIn])
        }
        self.payments = restaurantData.paymentTypes.map({$0.icon.replacingOccurrences(of: "~", with: "https://s3.amazonaws.com/v1.0")})
    }
}
