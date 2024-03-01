//
//  FeedbackView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 04/12/20.
//

import SwiftUI

struct FeedbackView: View {
        
    @Environment(\.presentationMode) var presentation
    var orderDetailPresentation: Binding<PresentationMode>
    init(order: OrderHistory, parentPresent: Binding<PresentationMode>) {
        _viewModel = StateObject(wrappedValue: FeedbackViewModel(order: order))
        orderDetailPresentation = parentPresent
    }
    
    @StateObject var viewModel: FeedbackViewModel
    
    var body: some View {
        ZStack {
            alerts()
            ScrollView {
                VStack {
                    orderDetails()
                    orderRating()
                    additionalComment()
                }
            }
            if viewModel.loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitle("Give Feedback", displayMode: .inline)
        .navigationBarHidden(false)
       
    }
    
    fileprivate func alerts() -> some View {
        VStack {
            Text("")
                .alert(item: $viewModel.error) { (errString) -> Alert in
                    Alert(title: Text(errString))
                }
            Text("")
                .alert(isPresented: $viewModel.successMessage) { () -> Alert in
                    Alert(title: Text("We have received your feedback for this order"), message: nil, dismissButton: .default(Text("OK"), action: {
                        presentation.wrappedValue.dismiss()
                        orderDetailPresentation.wrappedValue.dismiss()
                    }))
                }
        }
    }
    
    fileprivate func additionalComment() -> some View {
        VStack {
            Text("Additional Comment")
                .bold()
                .foregroundColor(.gray)
                .padding(.top)
            
            TextEditor(text: $viewModel.otherComment)
                .foregroundColor(.gray)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .addNeumoShadow()
                .padding()
            
            Button(action: viewModel.submitTapped, label: {
                Text("SUBMIT")
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .padding(.horizontal)
                    .background(Capsule()
                                    .foregroundColor(Color.appGreen))
            })
            .padding(.bottom)
            .padding(.bottom)
        }.background(Color(#colorLiteral(red: 0.9410971999, green: 0.9412290454, blue: 0.9410556555, alpha: 1)).edgesIgnoringSafeArea(.all))
    }
    
    
    fileprivate func orderRating() -> some View {
        Group {
            Text("Rating")
                .font(.title3)
                .bold()
                .padding(.bottom, 8)
            Group {
                Text("How would you rate the quality of your food?")
                FeedbackStarView(selected: $viewModel.rate1)
                Divider()
            }
            
            Group {
                Text("How would you rate the quality of our service?")
                FeedbackStarView(selected: $viewModel.rate2)
                Divider()
                
            }
            Group {
                Text("Was your order ready for pickup/delivery in a timely fashion?")
                FeedbackStarView(selected: $viewModel.rate3)
                Divider()
                
            }
            Group {
                Text("Please rate the timeliness of Pickup or Delivery service")
                FeedbackStarView(selected: $viewModel.rate4)
                Divider()
                
            }
            Group {
                Text("What is the likelihood that you'd use online versus telephone for your next order?")
                FeedbackStarView(selected: $viewModel.rate5)
                Divider()
                
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
    
    fileprivate func orderDetails() -> some View {
        Group {
            Text("Order Details")
                .bold()
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    Text("Order Number")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Text(viewModel.order.orderNumber)
                        .bold()
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Order Delivery Date")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Text(viewModel.order.createdOn)
                        .bold()
                        .font(.callout)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8)
            VStack(alignment: .leading) {
                Text("Order Status")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Text(viewModel.order.status)
                    .bold()
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    Text("Order Amount")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(Color.appGreen)
                    Text("$\(viewModel.order.totalAmt.toDouble.to2Decimal)")
                        .foregroundColor(Color.appAccent)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Money Saved")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(Color.appGreen)
                    Text("$\(viewModel.order.discountAmt.toDouble.to2Decimal)")
                        .foregroundColor(Color.appAccent)
                }
                
            }
            
            Divider()
        }
        .padding(.horizontal)
    }
}

//struct FeedbackView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//        FeedbackView()
//        }
//        .previewDevice("iPhone 11")
//    }
//}


struct FeedbackStarView: View {
    @Binding var selected: Int
    var body: some View {
        HStack {
            ForEach(0..<5, id:\.self) { position in
                Button(action: {
                    selected = position + 1
                }, label: {
                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundColor(position < selected ? Color.yellow : Color.gray)
                })
            }
        }
        .padding(.vertical, 8)
    }
}
