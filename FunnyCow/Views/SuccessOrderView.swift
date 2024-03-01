//
//  SuccessOrderView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 26/11/20.
//

import SwiftUI

struct SuccessOrderView: View {
    
    @StateObject var viewModel = SuccessOrderViewModel()
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var tabSelection: TabbarSelection
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    VStack {
                        HStack {
                            Text("Track Order")
                                .bold()
                                .padding(.leading, 40)
                                .frame(maxWidth: .infinity)
                            LottieView(name: "checkwhite")
                                .frame(width: 30, height: 30)
                                .padding(.trailing, 10)
                        }
                        
                        
                        HStack(spacing: 30.0) {
                            VStack {
                                Text("ESTIMATED TIME")
                                    .bold()
                                Text(viewModel.timeForPicup)
                            }
                            
                            VStack {
                                Text("ORDER NUMBER")
                                    .bold()
                                Text(viewModel.orderNumber)
                            }
                        }
                        .padding(.bottom)
                    }
                    .foregroundColor(.white)
                    .font(.body)
                    .background(Color.appAccent
                                    .edgesIgnoringSafeArea(.all))
                    ScrollView {
                        LottieView(name: "cooking")
                            .frame(height: 250)
                        orderProgressView()
                    }
                    
                    
                    HStack(spacing: 10) {
                        Button(action: {
                            viewModel.contactRestaurant()
                        }, label: {
                            Text("CONTACT\nRESTAURANT")
                                .frame(minWidth: 5, maxWidth: .infinity)
                                .padding(.vertical, 5)
                                .background(Color.appGreen)
                        })
                        
                        Button(action: startNewOrder, label: {
                            Text("START\nNEW ORDER")
                                .frame(minWidth: 5, maxWidth: .infinity)
                                .padding(.vertical, 5)
                                .background(Color.appAccent)
                        })
                    }
                    .padding(10)
                    .font(.callout)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    
                }
            }
            if viewModel.isLoading {
                ProgressView()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.5).edgesIgnoringSafeArea(.all))
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .alert(item: $viewModel.error) { (erString) -> Alert in
            Alert(title: Text(erString))
        }
    }
    
    func startNewOrder() {
        UserDefaultsController.shared.removeCartData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.presentation.wrappedValue.dismiss()
            self.presentation.wrappedValue.dismiss()
            self.tabSelection.tabSelection = 0
        }
    }
    
    
    func orderProgressView() -> some View {
        HStack (alignment: .top) {
            VStack(spacing: 5) {
                ForEach (0..<viewModel.orderProgress.count-1, id: \.self) { item in
                    let color: Color = (item == 0 ? .orange : .gray)
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(color)
                    Rectangle()
                        .frame(width: 2, height: 50)
                        .foregroundColor(color)
                }
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 16)
            
            VStack(alignment: .leading, spacing: 30) {
                ForEach(0..<viewModel.orderProgress.count, id: \.self) {item in
                    let order = viewModel.orderProgress[item]
                    let color: Color = (item == 0 ? .orange : .gray)
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
        .padding()
    }
}

struct SuccessOrderView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessOrderView()
            .previewDevice("iPhone 11")
    }
}
