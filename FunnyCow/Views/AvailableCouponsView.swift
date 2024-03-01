//
//  AvailableCounponView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 11/11/20.
//

import SwiftUI

struct AvailableCouponsView: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var viewModel = CouponViewModel()
    
    
    var couponCodeSearchField: some View {
        HStack {
            TextField("Enter Coupon Code", text: $viewModel.couponCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity)
            Button("APPLY") {
                if viewModel.selectCouponCode() {
                    presentation.wrappedValue.dismiss()
                }
            }
        }
    }
    
    var couponListSection: some View {
        Section(header: Text("Coupons")) {
            ForEach(viewModel.visibleCoupons) { coupon in
                Button {
                    viewModel.selectCouponTapped(coupon)
                } label: {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(coupon.couponCode)
                                .foregroundColor(Color.appAccent)
                            Spacer()
                            Text("APPLY")
                                .foregroundColor(Color.appGreen)
                        }
                        Text("\(coupon.toString()) Off")
                        Text(coupon.couponDescription)
                    }
                }
            }
        }
    }
    
    var discountListSection: some View {
        Section(header: Text("Discounts")) {
            ForEach(viewModel.discounts) { discount in
                Button {
                    viewModel.selectDiscountTapped(discount)
                } label: {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(discount.discountDescription)
                                .foregroundColor(Color.appAccent)
                            Spacer()
                            Text("APPLY")
                                .foregroundColor(Color.appGreen)
                        }
                        Text(discount.toString() + " Off")
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                        if discount.paymentTypes == nil, discount.minAmt > 0 {
                            Text("On orders of \(viewModel.symbol)\(discount.minAmt.to2Decimal) and above")
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            alerts
            VStack {
                couponCodeSearchField
                    .padding()
                List {
                    if viewModel.visibleCoupons.isEmpty {
                        Text("No coupon available")
                            .bold()
                            .frame(maxWidth: 500, alignment: .center)
                    } else {
                        couponListSection
                    }
                    
                    if viewModel.discounts.isEmpty {
                        Text("No discount available")
                            .bold().frame(maxWidth: 500, alignment: .center)
                    } else {
                        discountListSection
                    }
                }
            }
        }
        .onReceive(viewModel.$dissmiss, perform: { dis in
            if dis {
                presentation.wrappedValue.dismiss()
            }
        })
        .navigationBarTitle("Available Coupons", displayMode: .inline)
        .navigationBarItems(trailing: Text(""))
    }
    
    var alerts: some View {
        VStack {
            Text("")
                .alert(item: $viewModel.error, content: { (errString) -> Alert in
                    Alert(title: Text(errString))
                })
            Text("")
                .alert(item: $viewModel.getConsent) { detail in
                    Alert(title: Text(detail.title), message: Text(detail.subtitle), primaryButton: .default(Text("Yes"), action: detail.action), secondaryButton: .cancel())
                }
        }
    }
}

struct AlertWithAction: Identifiable {
    let id = UUID()
    let action: () -> ()
    let title: String
    let subtitle: String
}
