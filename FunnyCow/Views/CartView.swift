//
//  CartView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 07/11/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct CartView: View {
    @StateObject var viewModel = CartViewModel()
    @EnvironmentObject var tabbarSelection: TabbarSelection
    let grayColor = Color(#colorLiteral(red: 0.9268741012, green: 0.9268741012, blue: 0.9268741012, alpha: 1))
    
    var body: some View {
        ZStack {
            navigateViews()
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    Group {
                        restaurantHeader()
                            .padding(.horizontal)
                        Divider().padding(8)
                        ForEach(viewModel.orderItems, id: \.myid) { item in
                            cartItemCellView(item: item)
                                .padding(.horizontal)
                        }
                        if !viewModel.suggestedMenu.isEmpty {
                            suggestionsView()
                        }
                    }
                    Group {
                        GroupBox(label: Text("Select Service"), content: {
                            serviceTypeSelectionView()
                        }).groupBoxStyle(CustomGroupBoxStyle(color: grayColor))
                        if viewModel.selectedService?.name == "Curbside" {
                            carDetails()
                        }
                        if viewModel.selectedService?.name == "Dine In" {
                            TextField("Table number", text: $viewModel.tableNumber)
                                .keyboardType(.numberPad)
                                .roundedCorner()
                                .padding(.horizontal, 5)
                        }
                        if viewModel.selectedService?.name
                            .lowercased()
                            .contains("delivery") ?? false {
                            addressView()
                        }
                        if viewModel.selectedService != nil {
                            Button(action: {
                                viewModel.gotoSchedule = true
                            }) {
                                (
                                    Text("Order Schedule For: ")
                                        .foregroundColor(Color.white)
                                        + Text(viewModel.orderTiming())
                                        .bold()
                                        .foregroundColor(Color.white)
                                )
                                .font(.callout)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.appAccent
                                                .cornerRadius(4)
                                                .addNeumoShadow(shadowRadius: 3))
                                .padding()
                            }
                        }
                        
                    }
                
                    if viewModel.selectedService != nil {
                        paymentMethodSelect()
                            .background(grayColor.opacity(0.4))
                        coupon()
                    }
                    if viewModel.selectedPayment?.type != "POP" && viewModel.selectedPayment?.type != "$$" {
                        addTip()
                            .background(grayColor)
                    }
                    prices()
                    TextField("Any special request for the restaurant?", text: $viewModel.restaurantInstructions)
                        .font(.callout)
                        .roundedCorner()
                        .padding()
                    serviceTimeView()
                }
            }
            if viewModel.loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.3))
            }
        }
        .onAppear {
            viewModel.viewWillAppear()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
    
    func getMobileNumber() {
        tabbarSelection.getMobileNumber = true
    }
    
    func showOrderSuccess() {
        tabbarSelection.showOrderSuccess = true
    }
    
    fileprivate func navigateViews() -> some View {
        viewModel.getMobileNumber = self.getMobileNumber
        viewModel.showOrderSuccess = self.showOrderSuccess

       return Group {
           Group {
               if let delivery = viewModel.selectedService?.name.contains("Delivery") {
                   NavigationLink(isActive: $viewModel.gotoSchedule) {
                       ScheduleOrderView(isDelivery: delivery)
                   } label: {  EmptyView() }
               }
               NavigationLink(isActive: $viewModel.couponEnable) {
                   AvailableCouponsView()
               } label: {  EmptyView() }
               
               NavigationLink(isActive: $viewModel.addressEnable) {
                   SavedAddressView(addressSelectable: true)
               } label: { EmptyView() }
               
               NavigationLink(isActive: $viewModel.pushToRestaurant) {
                   RestaurantView(mobUrl: viewModel.appStorage?.otherInfo?.mobUrl ?? "")
               } label: {
                   EmptyView()
               }
               
               NavigationLink(isActive: $tabbarSelection.showOrderSuccess) {
                   SuccessOrderView()
               } label: {
                   EmptyView()
               }
              
           }
           
            Text("")
                .sheet(isPresented: $viewModel.showLogin, content: {
                    SignInView()
                })
            
            Text("")
                .sheet(isPresented: $viewModel.pushToCardPayment, content: {
                    CardPaymentView(payable: PaymentInfo(total: viewModel.grandTotal, subTotal: viewModel.itemTotal, coupon: viewModel.couponPrice + viewModel.discount1Price + viewModel.discount2Price, serviceName: viewModel.selectedService?.name ?? "", delivery: viewModel.deliveryFee, tax: viewModel.taxAmount, tip: viewModel.tipAmount, service: viewModel.serviceFee), restaurantDetail: viewModel.restaurantDetail!) { (tokenSaved) in
                        if tokenSaved {
                            viewModel.pushToCardPayment = false
                            viewModel.updateLocalData()
                            viewModel.setOrder()
                        }
                    }
                })
            
            Text("")
                .sheet(item: $viewModel.selectedItemToAdd, content: { item in
                    ChooseSizeView(catList: item.category, item: item.item, currencySymbol: viewModel.currencySymbol)
                })
            
            Text("")
                .alert(item: $viewModel.error) { (title) -> Alert in
                    Alert(title: Text(title))
                }
            
            Text("")
                .alert(item: $viewModel.deleteItem) { (item) -> Alert in
                    Alert(title: Text("Are you sure you want to remove the item?"), primaryButton: Alert.Button.cancel(), secondaryButton: Alert.Button.destructive(Text("Yes"), action: {
                        CartManager().decrementItem(item: item)
                        viewModel.removeCouponDiscount()
                    }))
                }
        }
    }
    
    fileprivate func carDetails() -> some View {
        return Group {
            HStack {
                TextField("Maker of Car", text: $viewModel.carMaker).roundedCorner()
                TextField("Model of Car", text: $viewModel.carModel).roundedCorner()
            }
            HStack {
                TextField("Color of Car", text: $viewModel.carColor).roundedCorner()
                TextField("License Plate #", text: $viewModel.carPlate).roundedCorner()
            }
        }
        .padding(.horizontal, 5)
    }
    
    fileprivate func serviceTimeView() -> some View {
        HStack {
            if let service = viewModel.selectedService {
                HStack {
                    Image(service.name == "Delivery" ? "delivery" : "pickup")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("\(service.name) \(viewModel.scheduleMinutes)")
                }
            }            
            Spacer()
            Button(action: viewModel.checkError) {
                HStack(spacing: 8.0) {
                    VStack {
                        Text("\(viewModel.currencySymbol)\(viewModel.grandTotal.to2Decimal)")
                            .font(.system(size: 16, weight: .medium))
                        Text("Total")
                            .font(.footnote)
                    }
                    Text("Submit Order")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(5)
                .background(viewModel.isSubmitEnable() ? Color.appAccent : Color(#colorLiteral(red: 0.5019164681, green: 0.5019901395, blue: 0.5018932223, alpha: 1)) )
                .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }.padding([.horizontal, .bottom])
    }
    
    fileprivate func suggestionCellView(item: ItemList) -> some View {
        return VStack {
            WebImage(url: URL(string: menuImageBaseUrl + item.img))
                .placeholder(Image("menuPlaceholder").resizable())
                .resizable()
                .frame(height: 100)
                .imageSize(with: 100)
                .overlay(
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color.appAccent)
                        .font(.title)
                        .background(Color.white)
                        .clipShape(Circle())
                        .padding(.top, 90)
                )
                .padding(5)
            Text(item.name)
                .font(.callout)
                .frame(width: 120)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
            Text("\(viewModel.currencySymbol)\(item.getSomePrice().to2Decimal)")
                .foregroundColor(Color("redColor"))
                .font(.footnote)
        }
    }
    
    fileprivate func suggestionsView() -> some View {
        GroupBox(label: Text("You may also like")) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    ForEach(viewModel.suggestedMenu) { suggestion in
                        Button(action: {
                            viewModel.addSuggestedItem(suggestion)
                        }, label: {
                            suggestionCellView(item: suggestion.item)
                        })
                    }
                }
            }
            .accentColor(.black)
        }
        .groupBoxStyle(CustomGroupBoxStyle(color: grayColor))
    }
    
    fileprivate func paymentMethodSelect() -> some View {
        GroupBox(label: Text("Payment Method"), content: {
            ForEach(viewModel.paymentMethods) { method in
                Button {
                    viewModel.selectPaymentMethod(method)
                } label: {
                    HStack {
                        if viewModel.selectedPayment == method {
                            Image(systemName: "largecircle.fill.circle")
                                .foregroundColor(Color.appAccent)
                        } else {
                            Image(systemName: "circle")
                        }
                        Text(method.type == "CC" ? "Debit/Credit Card" : method.name == "$$" ? "Cash" : method.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        WebImage(url: URL(string: method.icon.replacingOccurrences(of: "~", with: "https://s3.amazonaws.com/v1.0")))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 15, alignment: .trailing)
                        
                    }
                    .font(.system(size: 18, weight: .medium))
                    .accentColor(Color.black)
                }
            }
        }).groupBoxStyle(CustomGroupBoxStyle(color: Color.clear))
    }
    
    fileprivate func addressView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Delivery Address")
                Spacer()
                Button(action: {viewModel.addressTapped()}) {
                    Text(viewModel.userAddress == nil ? "ADD" : "Change")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                }
                
            }
            HStack(alignment: .top) {
                Image(systemName: viewModel.userAddress == nil ? "xmark.circle" : "checkmark.circle")
                    .foregroundColor(Color.appAccent)
                Text(viewModel.userAddress == nil ? "Address not selected" : viewModel.userAddress!)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.gray).font(.callout)
            }
        }.padding()
    }
    
    fileprivate func coupon() -> some View {
        VStack {
            Button(action: { viewModel.couponTapped() }) {
                HStack {
                    Image(systemName: "tag.fill")
                    Text("APPLY COUPON")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(
                    Color.appAccent
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                )
                .overlay(RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [8]))
                            .padding(4)
                )
                
            }
            .accentColor(.white)
            .padding(.horizontal, 20)
            
            if let coupon = viewModel.lastAppliedCoupon {
                discountAppliedView(title: coupon.couponCode, subtile: "(\(viewModel.currencySymbol)\(viewModel.couponPrice.to2Decimal) OFF)", type: "Coupon", discount: nil)
            }
            
            if let discount = viewModel.lastAppliedDiscount1 {
                discountAppliedView(title: discount.discountDescription, subtile: "(\(viewModel.currencySymbol)\(viewModel.discount1Price.to2Decimal) Off)", type: "Discount", discount: 1)
            }
            
            if let discount = viewModel.lastAppliedDiscount2 {
                discountAppliedView(title: discount.discountDescription, subtile: "(\(viewModel.currencySymbol)\(viewModel.discount2Price.to2Decimal) Off)", type: "Discount", discount: 2)
            }
        }.padding(5)
    }
    
    fileprivate func discountAppliedView(title: String, subtile: String, type: String, discount: Int?) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image("couponDiscount")
                    .resizable()
                    .frame(width: 30.0, height: 30.0)
                (
                    Text(title)
                        + Text(subtile)
                        .foregroundColor(Color.appGreen)
                )
                .bold()
                .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Button(action: {
                    if type == "Coupon" {
                        UserDefaultsController.shared.cartSavedData?.custCouponID = nil
                        UserDefaultsController.shared.cartSavedData?.restChainCouponID = nil
                        UserDefaultsController.shared.cartSavedData?.couponAmt = nil
                        UserDefaultsController.shared.cartSavedData?.otherInfo?.lastAppliedCoupon = nil
                    } else if discount == 1 {
                        UserDefaultsController.shared.cartSavedData?.discountAmt = nil
                        UserDefaultsController.shared.cartSavedData?.discountType = nil
                        UserDefaultsController.shared.cartSavedData?.otherInfo?.lastAppliedDiscount1 = nil
                    } else if discount == 2 {
                        UserDefaultsController.shared.cartSavedData?.discount1Amt = nil
                        UserDefaultsController.shared.cartSavedData?.discount1Type = nil
                        UserDefaultsController.shared.cartSavedData?.otherInfo?.lastAppliedDiscount2 = nil
                    }
                }, label: {
                    Image(systemName: "multiply.circle")
                        .font(.title3)
                })
            }
            Text("Congratulations, \(type) Applied Successfully !!").font(.footnote)
        }.padding(.vertical, 8)
    }
    
    fileprivate func prices() -> some View {
        Group {
            VStack(spacing: 4.0) {
                priceItem("Item Total", viewModel.itemTotal.to2Decimal)
                    .font(.title3)
                if viewModel.taxAmount > 0 {
                    priceItem("Tax Applied", viewModel.taxAmount.to2Decimal)
                }
                
                if viewModel.tipAmount > 0 {
                    priceItem("Tip Added", viewModel.tipAmount.to2Decimal)
                }
                
                if viewModel.deliveryFee > 0 {
                    priceItem("\(viewModel.selectedService?.name ?? "Delivery") charge", viewModel.deliveryFee.to2Decimal)
                }
                
                if viewModel.serviceFee > 0 {
                    priceItem("Service charge", viewModel.serviceFee.to2Decimal)
                }
                
                if viewModel.couponPrice > 0 {
                    priceItem("Applied coupon", (-viewModel.couponPrice).to2Decimal)
                        .foregroundColor(Color.appGreen)
                }
                
                if viewModel.discount1Price > 0 {
                    priceItem("Applied discount", (-viewModel.discount1Price).to2Decimal)
                        .foregroundColor(Color.appGreen)
                }
                
                if viewModel.discount2Price > 0 {
                    priceItem("Applied discount", (-viewModel.discount2Price).to2Decimal)
                        .foregroundColor(Color.appGreen)
                }
                
                priceItem("Grand Total", viewModel.grandTotal.to2Decimal)
                    .font(.title2)
            }
            .padding()
            .font(.callout)
        }.background(grayColor)
    }
    
    fileprivate func priceItem(_ title: String, _ subTitle: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(("\(viewModel.currencySymbol)" + subTitle).replacingOccurrences(of: "\(viewModel.currencySymbol)-", with: "-\(viewModel.currencySymbol)"))
        }
    }
    
    fileprivate func addTip() -> some View {
        GroupBox(label: Text("Add a Tip"), content: {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.tipsArr, id: \.self) { item in
                            let isSelected = viewModel.selectedTip == item
                            let color = (isSelected ? Color.appAccent : Color.white)
                            let borderColor = isSelected ? Color.appAccent : Color.gray
                            let textColor = isSelected ? Color.white : Color.appAccent
                            let text = String(item) + "%"
                            Button(action: {
                                viewModel.selectedTip = item
                            }, label: {
                                Text(text)
                                    .bold()
                                    .foregroundColor(textColor)
                                    .frame(height: 30)
                                    .frame(minWidth: 60)
                                    .background(color)
                                    .clipShape(Capsule(), style: FillStyle())
                                    .overlay(Capsule().stroke(borderColor))
                            })
                        }
                        Button(action: {
                            viewModel.selectedTip = -1
                        }, label: {
                            let isSelected = viewModel.selectedTip == -1
                            let textColor = isSelected ? Color.white : Color.appAccent
                            let color = (isSelected ? Color.appAccent : Color.white)
                            let borderColor = isSelected ? Color.appAccent : Color.gray
                            Text("Other")
                                .bold()
                                .foregroundColor(textColor)
                                .frame(height: 30)
                                .frame(minWidth: 60)
                                .background(color)
                                .clipShape(Capsule(), style: FillStyle())
                                .overlay(Capsule().stroke(borderColor))
                        })
                    }
                }
                if viewModel.selectedTip == -1 {
                    TextField("Tip Amount", text: $viewModel.manualTip)
                        .keyboardType(.numberPad)
                        .roundedCorner()
                        .padding(.horizontal, 5)
                }
            }
        })
        .groupBoxStyle(CustomGroupBoxStyle(color: Color.clear))
    }
    
    fileprivate func serviceTypeSelectionView() -> some View {
        return HStack {
            ForEach(viewModel.restaurantServices) { service in
                Button(action: {
                    viewModel.selectService(service: service)
                }, label: {
                    HStack(spacing: 2.0) {
                        Image(systemName: viewModel.selectedService == service
                                ? "largecircle.fill.circle"
                                : "circle")
                        Text(service.name)
                            .font(.callout)
                            .foregroundColor(Color(#colorLiteral(red: 0.1992851496, green: 0.1992851496, blue: 0.1992851496, alpha: 1)))
                    }
                })
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    fileprivate func restaurantHeader() -> some View {
        return HStack(alignment: .top, spacing: 5) {
            WebImage(url: URL(string: restaurantImageBaseUrl + (viewModel.restaurantDetail?.logoImg ?? "")))
                .placeholder(Image("restaurantPlaceholder").resizable())
                .resizable()
                .imageSize(with: 100)
            VStack(alignment: .leading, spacing: 5) {
                
                Text(viewModel.restaurantDetail?.name ?? "")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color(#colorLiteral(red: 0.2300000042, green: 0.2300000042, blue: 0.2300000042, alpha: 1)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(viewModel.restaurantDetail?.address.toString() ?? "")
                    .font(.callout)
                    .fontWeight(.regular)
                    .foregroundColor(Color.gray)
            }
        }.onTapGesture {
            viewModel.pushToRestaurant.toggle()
        }
    }
    
    fileprivate func cartItemCellView(item: SelectedItemDetail) -> some View {
        
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.name)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(viewModel.currencySymbol)\(item.unitPrice.to2Decimal)")
                        .foregroundColor(Color("redColor"))
                }
                Spacer()
                PlusMinusCountView(minusTapped: {
                    viewModel.decrementCount(for: item)
                }, plusTapped: {
                    viewModel.incrementCount(for: item)
                }, count: item.qty)
            }
            if let addonList = item.itemAddOnList?.sorted(by: {$0.addOnOptions.count < $1.addOnOptions.count}), !addonList.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Addons -").font(.footnote)
                    MyVGrid(views: addonList.map( {addOnView(addOn: $0)} ))
                }
            }
            if !item.specialInstructions.isEmpty {
                Text("Special Instructions:")
                    .font(.callout)
                Text(item.specialInstructions)
                    .font(.caption)
            }
            Divider()
        }
    }
    
    func addOnView(addOn: ItemAddOnList) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "square.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 8))
                Text(addOn.name)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ForEach(addOn.addOnOptions) { option in
                let name = "\(option.name) (\(option.addOnOptionModifier1?.label ?? " ") \(option.addOnOptionModifier2?.label ?? ""))"
                    .replacingOccurrences(of: "( ", with: "")
                    .replacingOccurrences(of: "  )", with: "")
                    .replacingOccurrences(of: " )", with: ")")
                (
                    Text(name)
                        .foregroundColor(Color.black.opacity(0.5))
                        + Text(option.amt > 0 ? " \(viewModel.currencySymbol)\(option.amt.to2Decimal)" : "")
                        .foregroundColor(Color.appAccent)
                )
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
                .id(UUID())
            }
            .padding(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

struct CustomGroupBoxStyle<T: View>: GroupBoxStyle {
    let color: T
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            configuration.label.font(.title2)
            configuration.content
                .frame(maxWidth: .infinity, alignment: .leading)
        }.padding().background(color)
    }
}
