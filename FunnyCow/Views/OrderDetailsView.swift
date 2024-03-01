//
//  OrderDetailsView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 28/12/20.
//

import SwiftUI

struct OrderDetailsView: View {
    
    @StateObject var viewModel: OrderDetailViewModel
    init(order: OrderHistory) {
        _viewModel = StateObject(wrappedValue: OrderDetailViewModel(order: order))
    }
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var tabbarViewModel: TabbarSelection
    var body: some View {
        ZStack(alignment: .bottom) {
            if let order = viewModel.model {
                orderDetailView(order: order)
            }
            if viewModel.model?.status == "Delivered", let submitted = viewModel.model?.isSubmittedFeedback == "0" {
                Button(action: {
                    if submitted {
                        viewModel.pushtoFeedback = true
                    }
                }) {
                    Text(submitted ? "GIVE FEEDBACK" : "FEEDBACK SUBMITTED")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(10)
                        .padding(.horizontal)
                        .background(submitted ? Color("redColor") : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .addNeumoShadow(shadowRadius: 5)
                }
            }
            
            NavigationLink(destination: FeedbackView(order: viewModel.history, parentPresent: presentation), isActive: $viewModel.pushtoFeedback, label: {  EmptyView()  })
            
            if viewModel.loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .alert(item: $viewModel.error) { (message) -> Alert in
            Alert(title: Text(message))
        }
    }
    
    fileprivate func orderDetailView(order: OrderDetailModel) -> some View {
        ScrollView {
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("Order#:\(order.orderNumber)")
                            .foregroundColor(Color.appGreen)
                        Text(viewModel.history.createdDate())
                            .font(.footnote)
                        (
                            Text("Order From: ")
                                + Text(viewModel.history.locationName)
                                .foregroundColor(Color.appGreen)
                        )
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Button(action: reOrder) {
                        HStack(spacing: 8.0) {
                            VStack {
                                Text("$\(order.totalAmt.toDouble.to2Decimal)")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Total")
                                    .font(.footnote)
                            }
                            Text("RE-ORDER")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(5)
                        .background( Color.appGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .addNeumoShadow(shadowRadius: 5)
                    }
                    
                }
                .padding([.horizontal, .top])
                Divider()
                
                ForEach(order.itemList) { item in
                    cartItemCellView(item: item)
                    Divider()
                }
                
                prices(order: order)
                
                orderProgressView()
                    .padding([.bottom, .horizontal], 40)
                
            }
        }
    }
    
    fileprivate func prices(order: OrderDetailModel) -> some View {
        VStack(spacing: 4.0) {
            Group {
                priceItem("Item Total", "$\(order.preTaxAmt.toDouble.to2Decimal)")
                    .font(.title3)
                priceItem("Tax Applied", "$\(order.taxAmt.toDouble.to2Decimal)")
                    .font(.callout)
                priceItem("Tip Added", "$\(order.tipAmt.toDouble.to2Decimal)")
                    .font(.callout)
                if order.srvcFee.toDouble > 0 {
                    priceItem("Service Charge", "$\(order.srvcFee.toDouble.to2Decimal)")
                        .font(.callout)
                }
                priceItem("Applied coupon", "-$\(order.couponAmt.toDouble.to2Decimal)")
                    .font(.callout)
                    .foregroundColor(Color.appGreen)
                priceItem("Applied discount", ("-$\(order.discountAmt.toDouble.to2Decimal)"))
                    .font(.callout)
                    .foregroundColor(Color.appGreen)
                if order.discount1Amt.toDouble > 0 {
                    priceItem("Applied discount", ("-$\(order.discount1Amt.toDouble.to2Decimal)"))
                        .font(.callout)
                        .foregroundColor(Color.appGreen)
                }
            }
            .padding(.horizontal)
            priceItem("Grand Total", "$\(order.totalAmt.toDouble.to2Decimal)")
                .font(.title2)
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(Color(#colorLiteral(red: 0.8901171088, green: 0.862695992, blue: 0.9317968488, alpha: 1)))
            
        }
        .padding(.top, 5)
        .background(Color(#colorLiteral(red: 0.9268741012, green: 0.9268741012, blue: 0.9268741012, alpha: 1)))
    }
    
    fileprivate func priceItem(_ title: String, _ subTitle: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(subTitle)
        }
    }
    
    fileprivate func cartItemCellView(item: OrderDetailItemList) -> some View {
        return VStack(alignment: .leading) {
            HStack {
                Text(item.name)
                Text("$\(item.price.toDouble.to2Decimal)")
                    .foregroundColor(Color("redColor"))
            }
            HStack {
                Text("Qty:")
                Text("X\(item.qty)")
                    .foregroundColor(Color("redColor"))
            }
            if let addonList: [OrderDetailItemAddOnList] = item.itemAddOnList,
               !addonList.isEmpty {
                VStack(spacing: 0) {
                    Text("Addons")
                        .font(.footnote.bold())
                        .underline()
                    MyVGrid(views: addonList.map { itemAddOnView(addOn: $0) })
                }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func itemAddOnView(addOn: OrderDetailItemAddOnList) -> some View {
        return VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "square.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 8))
                Text(addOn.name)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ForEach(addOn.addOnOptions) { option in
                addOnOptionView(option: option)
            }
            .padding(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func addOnOptionView(option: OrderDetailAddOnOption) -> some View {
        let name = "\(option.name) (\(option.addOnOptionModifier1.label) \(option.addOnOptionModifier2.label))"
            .replacingOccurrences(of: "( )", with: "")
            .replacingOccurrences(of: "( ", with: "(")
            .replacingOccurrences(of: " )", with: ")")
            .replacingOccurrences(of: "(x1)", with: "")
        let amt = option.price.toDouble
        return (
            Text(name)
                .foregroundColor(.gray)
                + Text( amt > 0 ? " $\(amt.to2Decimal)" : "")
                .foregroundColor(Color.appAccent)
        )
        .font(.footnote)
        .fixedSize(horizontal: false, vertical: true)
        .id(UUID())
    }
    
    func orderProgressView() -> some View {
        let orangeIndex = viewModel.orangePoint
        let isCancelled = viewModel.model?.status == "Canceled"
        return HStack (alignment: .top) {
            VStack(spacing: 5) {
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.green)
                ForEach (0..<viewModel.progress.count-1, id: \.self) { item in
                    let color: Color = item == orangeIndex
                        ? isCancelled ? .red : .orange
                        : item < orangeIndex ? .green : .gray
                    Rectangle()
                        .frame(width: 2, height: 50)
                        .foregroundColor(color)
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(isCancelled ? .red : color)
                }
                
            }
            .padding(.vertical, 16)
            
            VStack(alignment: .leading, spacing: 30) {
                ForEach(0..<viewModel.progress.count, id: \.self) {item in
                    let order = viewModel.progress[item]
                    let color: Color = item == orangeIndex ?
                        isCancelled ?
                        .red : .orange :
                        item < orangeIndex ?
                        .green : .gray
                    
                    HStack(alignment: .top) {
                        Image(order.image)
                            .resizable()
                            .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading) {
                            Text(order.title)
                                .font(.callout)
                            Text(order.subTitle)
                                .font(.footnote)
                        }
                    }.foregroundColor(color)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .padding(10)
    }
    
    func reOrder() {
        presentation.wrappedValue.dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UserDefaultsController.shared.removeCartData()
            if let mob = viewModel.mobUrl, let data = viewModel.model {
                tabbarViewModel.pushToOrderHistory = false
                tabbarViewModel.tabSelection = 0
                tabbarViewModel.restReoderData = (mob, data)
                tabbarViewModel.pushTORestaurantForReorder = true
            }
        }
    }
}
