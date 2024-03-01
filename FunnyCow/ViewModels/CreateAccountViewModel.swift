//
//  CreateAccountViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 04/12/20.
//

import Foundation

class CreateAccountViewModel: ObservableObject {
    @Published var error: String?
    @Published var loading = false
    @Published var name = ""
    @Published var emailID = ""
    @Published var phoneNumber = ""
    @Published var countryCode = "1"
    @Published var password = ""
    @Published var securePassword = true
    @Published var needOtpVerify = false
    @Published var otpReq: NewUserRequest?
    
    func signupTapped() {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.error = "Please enter name"
        } else if emailID.isEmpty {
            self.error = ("Please enter email")
        } else if !(emailID.isValidEmail()) {
            self.error = ("Enter valid email id")
        } else if phoneNumber.isEmpty {
            self.error = ("Please enter mobile number")
        } else if !(phoneNumber.isPhoneNumber) {
            self.error = ("please enter a valid 10-digit phone number")
        } else if password.trimmingCharacters(in: .whitespacesAndNewlines).count < 8 {
            self.error = ("Nice try but password need a minimum of 8 characters")
        } else {
            AppToken.shared.getToken { (token) in
                self.socialAccountOtp(token)
            }
        }
    }
    
    
    
    func socialAccountOtp(_ token: String) {
        let names = self.name.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
        let lname = names.indices.contains(2) ? names[2] : names.indices.contains(1) ? names[1] : ""
        let mname = names.indices.contains(2) ? names[1] : ""
        
        let customerData = CustomerData(fName: names.first ?? "", mName: mname, lName: lname, tel: "+"+self.countryCode+self.phoneNumber , cell: "", eMail: self.emailID)
        self.loading = true
        let body = SignupSendOtpRequest(tID: token, data: SendOtpReqData(customerData: customerData))
        HitApi.shared.postData("SendSignupOTP", bodyData: body) { (result: Result<APIStatusReponse, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let success):
                    if success.serviceStatus == "S" {
                        let data = NewUserRequest(tID: token, data: NewUserRequestData(customerData: NewUserRequestCust(fName: names.first ?? "", otp: "", mName: mname, lName: lname, tel: "+"+self.countryCode+self.phoneNumber, cell: "", eMail: self.emailID, mobileOptIn: 1), password: self.password))
                        self.otpReq = data
                        self.needOtpVerify = true
                    } else {
                        self.error = (success.message ?? "Something went wrong")
                    }
                case .failure(let error):
                    self.error = error.toString()
            }
        }
    }
}

// MARK: - CustomerData
struct CustomerData: Codable {
    let fName, mName, lName, tel: String
    let cell, eMail: String
    
}

// MARK: - SocialSendOtp
struct SignupSendOtpRequest: Codable {
    let tID: String
    let data: SendOtpReqData

    enum CodingKeys: String, CodingKey {
        case tID = "tId"
        case data
    }
}

// MARK: - DataClass
struct SendOtpReqData: Codable {
    var DeviceType: String = "2"
    var isApp: String = "1"
    var customerData: CustomerData
}

// MARK: - SignVerifyOtp
struct NewUserRequest: Codable {
    let tID: String
    var data: NewUserRequestData

    enum CodingKeys: String, CodingKey {
        case tID = "tId"
        case data
    }
}

// MARK: - DataClass
struct NewUserRequestData: Codable {
    var customerData: NewUserRequestCust
    let checkOTP = "1"
    let password: String
    let DeviceType = "2"
    let isApp = "1"
   
    enum CodingKeys: String, CodingKey {
        case customerData,
        checkOTP,
        password,
        DeviceType,
        isApp
    }
}

// MARK: - CustomerData
struct NewUserRequestCust: Codable {
    var fName, otp, mName, lName: String
    let tel, cell, eMail: String
    let mobileOptIn: Int

    enum CodingKeys: String, CodingKey {
        case fName
        case otp = "OTP"
        case mName, lName, tel, cell, eMail, mobileOptIn
    }
}
