//
//  MergeAccountViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 22/12/20.
//

import UIKit


class MergeAccountViewModel: ObservableObject {
    let customerData: Customerfbdata
    let user: UserModel
    init(_ data: Customerfbdata, user: UserModel) {
        customerData = data
        self.user = user
    }
    
    @Published var loading = false
    @Published var error: String?
    @Published var password = ""
    @Published var isPassSecure = true
    
    func submitTapped() {
        if password.isEmpty {
            self.error = "Please enter the password"
        } else if password.count < 8 {
            self.error = "Nice try but password need a minimum of 8 characters"
        } else {
            AppToken.shared.getToken { (token) in
                self.mergeAccount(token)
            }
        }
    }
    
    
    func mergeAccount(_ token: String) {
        // https://aafesapi.imenu360.com/iMenu360Service.svc/DoMergeGoogleData
        let dId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let request = MergeRequest(data: MergeRequestData(customerFBData: self.customerData, deviceID: dId, deviceType: "2", password: password, username: self.customerData.fbemail ?? ""), tID: token)
        self.loading = true
        HitApi.shared.postData("DoMergeGoogleData", bodyData: request) { (result: Result<APIStatusReponse, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let response):
                    if response.serviceStatus == "S" {
                        UserDefaultsController.shared.userModel = self.user
                        saveCustFCMToken()
                        NotificationCenter.default.post(name: .dismissLoginView, object: nil)
                    } else if response.serviceStatus == "F" {
                        self.error = response.message ?? "Something went wrong!"
                    }
                case .failure(let error):
                    self.error = error.toString()
            }
        }
    }
}

// MARK: - MergeRequest
struct MergeRequest: Codable {
    let data: MergeRequestData
    let tID: String

    enum CodingKeys: String, CodingKey {
        case data
        case tID = "tId"
    }
}

// MARK: - DataClass
struct MergeRequestData: Codable {
//    let fcmToken: String
    let customerFBData: Customerfbdata
    let deviceID, deviceType, password: String
    let username: String
    var isApp = "1"

    enum CodingKeys: String, CodingKey {
//        case fcmToken = "FCMToken"
        case customerFBData
        case deviceID = "DeviceId"
        case deviceType = "DeviceType"
        case isApp, password, username
    }
}

