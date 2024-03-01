//
//  OrderHistoryView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 16/11/20.
//

import SwiftUI

struct OrderHistoryView: View {
    
    @StateObject var viewModel = OrderHistoryViewModel()
    
    var body: some View {
        VStack {
            if viewModel.loading {
                ProgressView()
            } else if viewModel.orders.isEmpty {
                Image("sad")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color.appAccent)
                Text("No order found")
                    .fontWeight(.medium)
                Text("Looks like you haven't made any order yet!")
                    .foregroundColor(Color.gray)
            } else {
                ScrollView {
                    VStack(spacing: 8, content: {
                        ForEach(viewModel.orders) { order in
                            NavigationLink(
                                destination: OrderDetailsView(order: order),
                                label: {
                                    orderItem(order: order)
                                })
                        }
                    })
                    .padding(.vertical)
                }
            }
        }
        .navigationBarTitle("Order History", displayMode: .inline)
        .navigationBarHidden(viewModel.showNav)
        .alert(item: $viewModel.errror) { (errString) -> Alert in
            Alert(title: Text(errString))
        }
        .onAppear {
            viewModel.getHistory()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.showNav = false
            }
        }
    }
    
    
    fileprivate func orderItem(order: OrderHistory) -> some View {
        return VStack {
            HStack(alignment: .top, spacing: 4.0) {
                VStack(alignment: .leading) {
                    Text("Order#:\(order.orderNumber)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.appAccent)
                    Text(order.createdDate())
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                }
                Spacer()
                VStack {
                    Text("Total Amount")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                    Text("$\(order.totalAmt.toDouble.to2Decimal)")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(Color.blue)
                }
            }
            OrderHistoryStatus(order: order)
        }
        .padding()
        .background(Color.white.shadow(radius: 2))
    }
}

struct OrderHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderHistoryView()
        }
        .previewDevice("iPhone 11")
    }
}

// "Delivered", "Canceled", "Open"
struct OrderHistoryStatus: View {
    let order: OrderHistory
    var body: some View {
        let color = order.status == "Canceled"
            ? Color.red
            : order.status == "Delivered"
            ? Color.green : Color.yellow
        let orderType = order.status == "Delivered"
            ? order.restService == "Pickup" ? "Picked-Up" : "Delivered"
            : order.status == "Open" ? "Placed" : order.status
        let orderTypeText = order.status == "Delivered"
            ? order.restService == "Pickup" ? "Order has been picked" : "Order has been Delivered"
            : order.status == "Open" ? "We've received your order"
            : order.status == "Canceled" ? "Order was Canceled"
            : order.status == "Confirmed" ? "Order is Confirmed"
            : "Order is \(order.status)"
        HStack {
            VStack(spacing: 2) {
                Circle()
                    .foregroundColor(.black)
                    .frame(width: 5, height: 5)
                Rectangle()
                    .frame(width: 2, height: 16)
                    .foregroundColor(color)
                Circle()
                    .foregroundColor(color)
                    .frame(width: 16, height: 16)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Order \(orderType)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
                Text(orderTypeText)
                    .foregroundColor(color)
                    .font(.footnote)
            }
            Spacer()
        }
    }
}
