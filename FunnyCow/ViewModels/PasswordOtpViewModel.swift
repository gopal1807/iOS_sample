//
//  PasswordOtpViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 06/12/20.
//

import Foundation

class PasswordOtpViewModel: ObservableObject {
    let otpRequest: ResetPassRequest
    @Published var error: String?
    @Published var loading = false
    @Published var otp = ""
    @Published var newPassword = ""
    @Published var secureTextField = true
    @Published var timerCount = 120
    @Published var isPassReset = false
    
    init(_ otpRequest: ResetPassRequest) {
        self.otpRequest = otpRequest
        startTimer()
    }
    
    var timer: Timer?
    
    deinit {
        timer?.invalidate()
    }
    
    
    func startTimer() {
        timerCount = 120
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if self.timerCount > 0 {
                self.timerCount = self.timerCount - 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    func resendOtp() {
        self.loading = true
        let data = ForGotPassRequest(tID: otpRequest.tID, data: ForGotPassRequestData(username: otpRequest.data.username))
        HitApi.shared.postData("SendForgetPasswordOTP", bodyData: data) { (result: Result<APIStatusReponse, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let response):
                    if response.serviceStatus == "S" {
                        self.error = ("Successfully resend otp")
                        self.startTimer()
                    } else {
                        self.error = ("Resend otp failed\nPlease try later!")
                    }
                case .failure(let error):
                    self.error = error.toString()
            }
        }
    }
    
    func verifyOtp() {
        if otp.count < 4 {
            self.error = "Please enter otp"
            return
        }
        
        if newPassword.isEmpty {
            self.error = ("Please enter the password")
        } else if self.newPassword.count < 8 {
             self.error = ("Password must be 8 characters long")
         } else {
         
        self.loading = true
        var body = otpRequest
        body.data.customerData.otp = otp
        body.data.password = newPassword
        HitApi.shared.postData("ResetPassword_OTP", bodyData: body) { (result: Result<APIStatusReponse, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let response):
                    if response.serviceStatus == "S" {
                        self.isPassReset = true
                    } else {
                        self.error = (response.message ?? "Something went wrong")
                        self.otp.removeAll()
                    }
                case .failure(let error):
                    self.error = error.toString()
                    self.otp.removeAll()
            }
        }
    }
    }
    
}



// MARK: - ResetPassRequest
struct ResetPassRequest: Codable {
    let tID: String
    var data: ResetPassRequestData

    enum CodingKeys: String, CodingKey {
        case tID = "tId"
        case data
    }
}

// MARK: - DataClass
struct ResetPassRequestData: Codable {
    var DeviceType = "2"
    var isApp = "1"
    let username: String
    var customerData: ResetPassRequestCustomerData
    var password: String
}

// MARK: - CustomerData
struct ResetPassRequestCustomerData: Codable {
    let tel: String
    var otp: String

    enum CodingKeys: String, CodingKey {
        case tel
        case otp = "OTP"
    }
}
