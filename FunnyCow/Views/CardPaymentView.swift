//
//  CardPaymentView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 27/11/20.
//

import SwiftUI
import Stripe

struct CardPaymentView: View {
    @Environment(\.presentationMode) var presentation
    
    init(payable: PaymentInfo, restaurantDetail: RestaurantModel, success: @escaping (Bool) -> Void) {
        self._viewModel = StateObject(wrappedValue: CardPaymentViewModel(restauarntDetail: restaurantDetail, payment: payable, success: success))
    }
    
    @StateObject var viewModel: CardPaymentViewModel
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {presentation.wrappedValue.dismiss()}, label: {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                    })
                    Spacer()
                    Text("Payable: \(viewModel.currencySymbol)\(viewModel.payment.total.to2Decimal)")
                        .font(.title2)
                }
                .padding(.vertical)
                if viewModel.isPaymentProviderStripe {
                    Button(action: viewModel.setupPKPaymentRequest, label: { Text("")} )
                        .frame(height: 45)
                        .buttonStyle(ApplePayButtonStyle())
                        .padding()
                    Text("or")
                }
                
                StripeTextField(number: $viewModel.number,
                                cvc: $viewModel.cvc,
                                expMonth: $viewModel.expMonth,
                                expYear: $viewModel.expYear,
                                postalCode: $viewModel.postalCode,
                                showPostalCode: !viewModel.isPaymentProviderStripe)
                    .frame(height: 50)
                if !viewModel.isPaymentProviderStripe && !viewModel.isPaymentProviderIMenu {
                    HStack {
                        TextField("First Name", text: $viewModel.firstName)
                            .roundedCorner(radius: 4, padding: 8, color: .gray)
                        TextField("Last Name", text: $viewModel.lastName)
                            .roundedCorner(radius: 4, padding: 8, color: .gray)
                    }
                    HStack {
                        TextField("City", text: $viewModel.city)
                            .roundedCorner(radius: 4, padding: 8, color: .gray)
                        TextField("State", text: $viewModel.state)
                            .roundedCorner(radius: 4, padding: 8, color: .gray)
                    }
                    TextField("Address", text: $viewModel.address)
                        .roundedCorner(radius: 4, padding: 8, color: .gray)
                    
                }
                Button(action: viewModel.checkOutTapped) {
                    Text("CHECKOUT")
                        .bold()
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color("redColor"))
                        .clipShape(Capsule())
                }
                .padding()
                Spacer()
            }
            if viewModel.loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.3))
            }
        }
        .padding()
        .alert(item: $viewModel.errror) { (errstr) -> Alert in
            Alert(title: Text(errstr))
        }
    }
    
    
}

struct StripeTextField: UIViewRepresentable {
    typealias UIViewType = STPPaymentCardTextField
    @Binding var number: String
    @Binding var cvc: String
    @Binding var expMonth: Int?
    @Binding var expYear: Int?
    @Binding var postalCode: String
    let showPostalCode: Bool
    
    func makeUIView(context: Context) -> STPPaymentCardTextField {
        let cardTextField = STPPaymentCardTextField()
        cardTextField.postalCodeEntryEnabled = showPostalCode
        cardTextField.delegate = context.coordinator
        return cardTextField
    }
    
    func updateUIView(_ uiView: STPPaymentCardTextField, context: Context) {
        uiView.cardParams.number = number
        uiView.cardParams.cvc = cvc
        uiView.cardParams.expMonth = NSNumber(value: expMonth ?? 0)
        uiView.cardParams.expYear = NSNumber(value: expYear ?? 0)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, STPPaymentCardTextFieldDelegate {
        var uiView: StripeTextField
        init(_ control: StripeTextField) {
            uiView = control
        }
        
        func paymentCardTextFieldDidChange(_ textField: Stripe.STPPaymentCardTextField) {
            uiView.number = textField.cardParams.number ?? ""
            uiView.cvc = textField.cardParams.cvc ?? ""
            uiView.expMonth = textField.cardParams.expMonth?.intValue
            uiView.expYear = textField.cardParams.expYear?.intValue
            uiView.postalCode = textField.postalCode ?? ""
        }
    }
}
