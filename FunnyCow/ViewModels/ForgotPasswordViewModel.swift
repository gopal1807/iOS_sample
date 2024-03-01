//
//  ForgotPasswordViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 06/12/20.
//

import Foundation

class ForgotPasswordViewModel: ObservableObject {
    @Published var emailId = ""
    @Published var error: String?
    @Published var loading = false
    var otpRequest: ResetPassRequest?
    @Published var pushToOtp = false
    
    func sendOtpTapped() {
        if emailId.isEmpty {
            self.error = ("Please enter the email id")
        } else if !(emailId.isValidEmail()) {
            self.error = ("Please enter a valid email id")
        } else {
            self.loading = true
            AppToken.shared.getToken { (token) in
                self.forgotPassOtp(token)
            }
        }
        
    }
    
    func forgotPassOtp(_ token: String) {
        let data = ForGotPassRequest(tID: token, data: ForGotPassRequestData(username: emailId))
        HitApi.shared.postData("SendForgetPasswordOTP", bodyData: data) { (result: Result<APIStatusReponse, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let success):
                    if success.serviceStatus == "S" {
                        self.otpRequest = ResetPassRequest(tID: token, data: ResetPassRequestData(username: self.emailId, customerData: ResetPassRequestCustomerData(tel: self.emailId, otp: ""), password: ""))
                        self.pushToOtp = true
                    } else {
                        self.error = (success.message ?? "Something went wrong!")
                    }
                case .failure(let error):
                    self.error = error.toString()
            }
        }
    }
}

struct ForGotPassRequest: Codable {
    let tID: String
    let data: ForGotPassRequestData

    enum CodingKeys: String, CodingKey {
        case tID = "tId"
        case data
    }
}

// MARK: - DataClass
struct ForGotPassRequestData: Codable {
    let username: String
    var DeviceType: String = "2"
    var isApp = "1"
}
