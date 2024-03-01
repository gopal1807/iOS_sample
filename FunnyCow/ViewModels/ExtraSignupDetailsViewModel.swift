//
//  ExtraSignupDetailsViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 22/12/20.
//

import Foundation

class ExtraSignupViewModel: ObservableObject {
    
    @Published var loading = false
    @Published var error: String?
 
    @Published var mobileNumber = ""
    @Published var countryCode = "1"

    var dismiss: (() -> ())?
    
    func submitTapped() {
        if mobileNumber.isEmpty {
            self.error = ("Please enter mobile number")
        } else if !(mobileNumber.isPhoneNumber) {
            self.error = ("Please enter a valid phone number")
        } else {
            AppToken.shared.getToken { (token) in
                self.editProfile(token: token)
            }
        }
    }
    
    func editProfile(token: String) {
      
        guard let userData = UserDefaultsController.shared.userModel else { return }
        let custData = ["custId":"\(userData.id)","fName":userData.fName ?? "","mName":userData.mName ?? "","lName":userData.lName ?? "","tel":"+" + self.countryCode + self.mobileNumber,"cell":"","eMail":userData.email ?? "","optIn":"F","MobileOptIn":"0"]
        self.loading = true
        HitApi.shared.postData("SetUserProfile", bodyData: TidData(data: ["customerData" : custData], tID: token)) { (result: Result<APIStatusReponse, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let success):
                    if success.serviceStatus == "S" {
                        UserDefaultsController.shared.userModel?.tel = "+" + self.countryCode + self.mobileNumber
                        self.dismiss?()
                    } else {
                        self.error = (success.message ?? "Something went wrong")
                    }
                case .failure(let error):
                    self.error = error.toString()
            }
        }
    }
    
}
