//
//  SocialSignupOtpVerifyViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 23/12/20.
//

import UIKit

class SocialSignupVerifyOtpViewModel: ObservableObject {
    
    @Published var error: String?
    @Published var loading = false
    @Published var timerCount = 120
    @Published var otp = ""
    
    let otpReq: DoGoogleLoginRequest
    init(_ otpReq: DoGoogleLoginRequest) {
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
    
//    func resendOtp() {
//        let customerData = otpReq.data.customerFBData
//        let custData = CustomerData(fName: customerData.fName ?? "", mName: "", lName: customerData.lName ?? "", tel: otpReq.data.customerData.tel , cell: "", eMail: customerData.fbEmail ?? "")
//        self.loading = true
//        let body = SignupSendOtpRequest(tID: otpReq.tID, data: SendOtpReqData(customerData: custData))
//        HitApi.shared.postData("SendSignupOTP", bodyData: body) { (result: Result<APIStatusReponse, HitApiError>) in
//            self.loading = false
//            switch result {
//                case .success(let success):
//                    if success.serviceStatus == "S" {
//                        self.error = "Successfully resend otp"
//                        self.startTimer()
//                    } else {
//                        self.error = (success.message ?? "Something went wrong")
//                    }
//                case .failure(let error):
//                    self.error = error.toString()
//            }
//        }
//    }
        
    
    func verifyOtp() {
        if otp.count < 4 {
            self.error = "Please enter otp"
            return
        }
        self.loading = true
        var body = otpReq
        body.data.customerData.otp = otp
        HitApi.shared.postData("DoGoogleLogin", bodyData: body) { (result: Result<UserModel, HitApiError>) in
            switch result {
                case .success(let success):
                    UserDefaultsController.shared.userModel = success
                    saveCustFCMToken()
                    NotificationCenter.default.post(name: .dismissLoginView, object: nil)
                case .failure(let error):
                    self.error = error.toString()
            }
        }
    }
}
