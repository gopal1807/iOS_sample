//
//  ApplePayhandler.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 27/11/20.
//

import PassKit
import SwiftUI
import Stripe

enum ApplepayError: Error {
    case failedToPresent
    case someError
    case networkcannotPay
    case userDismiss
    
    func toString() -> String {
        switch self {
            case .networkcannotPay:
                return "Unable to make Apple Pay transaction."
            case .failedToPresent:
                return "Unable to present Apple Pay authorization."
            case .someError:
                return "Unable to make Apple Pay transaction."
            case .userDismiss:
                return "User cancelled the transaction"
        }
    }
}

typealias PaymentCompletionHandler = (Result<String, ApplepayError>) -> Void

class PaymentHandler: NSObject, PKPaymentAuthorizationControllerDelegate {
    static let shared = PaymentHandler()
    private override init() { }

    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
            STPAPIClient.shared.createPaymentMethod(with: payment) { (token, error) in
                if let token = token {
                    completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                    self.completionHandler?(.success(token.stripeId))
                } else if let err = error {
                    print(err.localizedDescription)
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: [err]))
                    self.completionHandler?(.failure(.someError))
                } else {
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                    self.completionHandler?(.failure(.someError))
                }
            }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        self.completionHandler?(.failure(.userDismiss))
        controller.dismiss(completion: nil)
    }
 
    var paymentController: PKPaymentAuthorizationController?
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    var completionHandler: PaymentCompletionHandler?
    
    func startPayment(payment: PaymentInfo, completion: @escaping PaymentCompletionHandler) {
        completionHandler = completion
        let paymentNetworks: [PKPaymentNetwork] = PKPaymentRequest.availableNetworks()
        guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) else {
            self.completionHandler?(.failure(.networkcannotPay))
            return
        }
        let discountAmount = (Double(payment.coupon.to2Decimal) ?? 0)
        let subtotalItem = PKPaymentSummaryItem(label: "subtotal", amount: NSDecimalNumber(string: payment.subTotal.to2Decimal), type: .final)
        let taxItem = PKPaymentSummaryItem(label: "tax", amount: NSDecimalNumber(string: payment.tax.to2Decimal), type: .final)
        let deliveryItem = PKPaymentSummaryItem(label: "\(payment.serviceName) Charge", amount: NSDecimalNumber(string: payment.delivery.to2Decimal), type: .final)
        let serviceFee = PKPaymentSummaryItem(label: "Service", amount: NSDecimalNumber(string: payment.service.to2Decimal), type: .final)
        let tipItem = PKPaymentSummaryItem(label: "tip", amount: NSDecimalNumber(string: payment.tip.to2Decimal), type: .final)
        let discountItem = PKPaymentSummaryItem(label: "discount", amount: NSDecimalNumber(value: -discountAmount), type: .final)
        let totalItem = PKPaymentSummaryItem(label: "iMenu360 Inc. (VIA \(appName))", amount: NSDecimalNumber(string: payment.total.to2Decimal), type: .final)
        paymentSummaryItems = [subtotalItem, taxItem, deliveryItem, serviceFee, tipItem, discountItem, totalItem].filter({ item in
            item.amount.decimalValue > 0
        })
        let cartSavedData = UserDefaultsController.shared.cartSavedData
        let deliveryInfo = cartSavedData?.deliveryInfo
        let contact = PKContact()
        var personName = PersonNameComponents()
        personName.givenName = deliveryInfo?.name
        
        let phonenumber = CNPhoneNumber(stringValue: deliveryInfo?.telephone ?? "")
        let countryCode = String((cartSavedData?.otherInfo?.restaurant.address.country ?? "USA").prefix(2))
        let currencyCode = cartSavedData?.otherInfo?.restaurant.currencyDetail.code ?? "USD"
        let postalAdd = CNMutablePostalAddress()
        postalAdd.city = deliveryInfo?.city ?? ""
        postalAdd.state = deliveryInfo?.state ?? ""
        postalAdd.postalCode = deliveryInfo?.zip ?? ""
        contact.postalAddress = postalAdd
        contact.name = personName
        contact.phoneNumber = phonenumber
        
        // Create our payment request
        let paymentRequest = PKPaymentRequest()
//        paymentRequest.billingContact = contact
//        paymentRequest.shippingContact = contact
        paymentRequest.paymentSummaryItems = paymentSummaryItems
        paymentRequest.merchantIdentifier = merchantId
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = countryCode.uppercased()
        paymentRequest.currencyCode = currencyCode
        paymentRequest.supportedNetworks = paymentNetworks
                
        // Display our payment request
        if let cont = self.paymentController {
            cont.dismiss {
                self.paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
                self.paymentController!.delegate = self
                self.paymentController!.present { presented in
                    if presented {
                        NSLog("Presented payment controller")
                    } else {
                        NSLog("Failed to present payment controller")
        //                self.completionHandler!(.failure(.failedToPresent))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.startPayment(payment: payment, completion: completion)
                        }
                    }
                }
            }
        } else {
            self.paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
            self.paymentController!.delegate = self
            self.paymentController!.present { presented in
                if presented {
                    NSLog("Presented payment controller")
                } else {
                    NSLog("Failed to present payment controller")
    //                self.completionHandler!(.failure(.failedToPresent))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.startPayment(payment: payment, completion: completion)
                    }
                }
            }
        }

    }
  
}


struct ApplePayButton: UIViewRepresentable {
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {
        
    }
    func makeUIView(context: Context) -> PKPaymentButton {
        return PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
    }
}
struct ApplePayButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return ApplePayButton()
    }
}
