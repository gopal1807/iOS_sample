//
//  CardPaymentViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 03/12/20.
//

import Foundation
import Stripe

class CardPaymentViewModel: ObservableObject {
    
    let isPaymentProviderStripe: Bool
    let isPaymentProviderIMenu: Bool
    let payment: PaymentInfo
    init(restauarntDetail: RestaurantModel, payment: PaymentInfo, success: @escaping (Bool) -> Void) {
        self.payment = payment
        self.currencySymbol = restauarntDetail.currencyDetail.symbol
        isPaymentProviderStripe = restauarntDetail.PaymentProviderStripe == .t
        isPaymentProviderIMenu = restauarntDetail.PaymentProviderMiMenu == .t
        STPAPIClient.shared.publishableKey = restauarntDetail.PublishableKey?.base64Decoded() ?? "pk_test_RXuJ6tgyLEOfPMaWToaVZgaS0082fh7fam"
        self.stripeSuccess = success
    }
    @Published var number = ""
    @Published var cvc = ""
    @Published var expMonth: Int?
    @Published var expYear: Int?
    @Published var postalCode = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var city = ""
    @Published var state = ""
    @Published var address = ""
    @Published var errror: String?
    @Published var loading = false
    var stripeToken = "" {
        didSet {
            saveDetailsDebouncer.debounce(seconds: 1) {
                self.saveDetails()
            }
        }
    }
    var currencySymbol: String
    private let saveDetailsDebouncer = Debounce()
    var stripeSuccess: (Bool) -> Void
    
    func setupPKPaymentRequest() {
        self.loading = true
        PaymentHandler.shared.startPayment(payment: payment) { (result) in
            self.loading = false
            switch result {
                case .failure(let err):
                    if err == ApplepayError.userDismiss {
                        // do nothing
                    } else {
                        self.errror = err.toString()
                    }
                case .success(let stripeToken):
                    self.stripeToken = stripeToken
            }
        }
    
    }
    
    func checkOutTapped() {
        var errror = ""
        if number.isEmpty || cvc.isEmpty, expMonth == nil || expMonth == 0 || expYear == nil || expYear == 0 {
            errror = "Please enter card details"
        } else if !isPaymentProviderStripe && postalCode.isEmpty {
            errror = "please enter postal code"
        } else if !isPaymentProviderStripe && !isPaymentProviderIMenu {
            if firstName.isEmpty {
                errror = "Please enter your first name"
            } else if lastName.isEmpty {
                errror = "Please enter your last name"
            } else if city.isEmpty {
                errror = "Please enter the city"
            } else if state.isEmpty {
                errror = "Please enter the state"
            } else if address.isEmpty {
                errror = "Please enter the address"
            }
        }
        
        guard errror.isEmpty else {
            self.errror = errror
            return
        }
        
        if isPaymentProviderStripe {
            getStripTokenFromCard()
        } else {
            saveDetails()
        }
    }
    
    func getStripTokenFromCard()  {
        let card = STPCardParams()
        card.number = self.number
        card.cvc = self.cvc
        card.expYear = UInt(self.expYear ?? 0)
        card.expMonth = UInt(self.expMonth ?? 0)
        let acard = STPPaymentMethodParams(card: STPPaymentMethodCardParams(cardSourceParams: card), billingDetails: nil, metadata: nil)
        self.loading = true
        STPAPIClient.shared.createPaymentMethod(with: acard) { (stpToken, oError) in
            self.loading = false
            if let err = oError {
                self.errror = err.localizedDescription
            }
            if let token = stpToken {
                self.stripeToken = token.stripeId
            } else {
                self.errror = "Please Enter Valid Card details"
            }
        }
    }
    func stringToStringDate(date:String?) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current.restTimeZone()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        guard let dd = date, let newDate =  formatter.date(from: dd) else {return ""}
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: newDate)
    }
    func saveDetails() {
        let info: CCInfo
        var order = UserDefaultsController.shared.cartSavedData
        let time = order?.timeSelection == 0 ? "ASAP" : stringToStringDate(date: order?.dueOn ?? "")
        if let month = expMonth, let year = expYear {
            let expiry = "\(month)/\(year)"
            info = CCInfo(ccType: 2, date: "LT", hacode: "", ccAddr1: self.address, ccAddr2: "", cccvv: self.cvc, ccCity: self.city, ccExpDate: expiry, ccfName: self.firstName, cclName: self.lastName, ccmName: "", ccNumber: self.number, ccState: self.state, cczip: self.postalCode, service: 1, time: time, tipPaidbBy: "on", txtPaytronixGiftCard: "", tipAmount: order?.tipAmt ?? 0)
        } else {
            info = CCInfo(ccType: 2, date: "LT", hacode: "", ccAddr1: self.address, ccAddr2: "", cccvv: self.cvc, ccCity: self.city, ccExpDate: "", ccfName: self.firstName, cclName: self.lastName, ccmName: "", ccNumber: self.number, ccState: self.state, cczip: self.postalCode, service: 1, time: time, tipPaidbBy: "on", txtPaytronixGiftCard: "", tipAmount: order?.tipAmt ?? 0)
        }
        order?.ccInfo = info
        order?.stripeToken = stripeToken
        UserDefaultsController.shared.cartSavedData = order
        stripeSuccess(true)
    }
}

struct PaymentInfo {
    let total: Double
    let subTotal: Double
    let coupon: Double
    let serviceName: String
    let delivery: Double
    let tax: Double
    let tip: Double
    let service: Double
}
