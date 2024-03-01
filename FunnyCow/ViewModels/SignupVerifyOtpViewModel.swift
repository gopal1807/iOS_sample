//
//  VerifyOtpViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 06/12/20.
//

import UIKit

class SignupVerifyOtpViewModel: ObservableObject {
    
    @Published var error: String?
    @Published var loading = false
    @Published var timerCount = 120
    @Published var otp = ""
    
    let otpReq: NewUserRequest
    init(_ otpReq: NewUserRequest) {
        self.otpReq = otpReq
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
        let otpCust = otpReq.data.customerData
        let req = SignupSendOtpRequest(tID: otpReq.tID, data: SendOtpReqData(customerData: CustomerData(fName: otpCust.fName, mName: otpCust.mName, lName: otpCust.lName, tel: otpCust.tel, cell: otpCust.cell, eMail: otpCust.eMail)))
        HitApi.shared.postData("SendSignupOTP", bodyData: req) { (result: Result<APIStatusReponse, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let response):
                    if response.serviceStatus == "S" {
                        self.error = "Successfully resend otp"
                        self.startTimer()
                    } else {
                        self.error = "Resend otp failed\nPlease try later!"
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
        self.loading = true
        var body = otpReq
        body.data.customerData.otp = otp
        HitApi.shared.postData("NewUser", bodyData: body) { (result: Result<UserModel, HitApiError>) in
            self.loading = false
            switch result {
                case .success(_):
                    self.normalLogin()
                case .failure(let error):
                    self.error = error.toString()
                    self.otp = ""
            }
        }
    }
    
    
    func normalLogin() {
        self.loading = true
        AppToken.shared.getToken { (tid) in
            let pass = self.otpReq.data.password
            let data = LoginRequestData(username: self.otpReq.data.customerData.eMail, password: pass, deviceID: UIDevice.current.identifierForVendor?.uuidString ?? "", deviceType: "2", isApp: "1")
            let data1 = LoginRequest(data: data, tID: tid)
            HitApi.shared.postData("DoLogin", bodyData: data1) { (result: Result<UserModel, HitApiError>) in
                self.loading = false
                switch result {
                    case .success(let output):
                        UserDefaultsController.shared.userModel = output
                        saveCustFCMToken()
                        NotificationCenter.default.post(name: .dismissLoginView, object: nil)
                    case .failure(let err):
                        self.error = err.toString()
                }
            }
            
        }
    }
    
}
