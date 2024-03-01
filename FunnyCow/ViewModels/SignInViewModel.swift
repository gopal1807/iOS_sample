//
//  SignInViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 25/11/20.
//

import UIKit
import Combine
import SwiftUI
import GoogleSignIn
import AuthenticationServices
import FirebaseCore

class SignInViewModel: NSObject, ObservableObject {
    
    @Published var isPassSecure = true
    @Published var emailID = ""
    @Published var password = ""
    @Published var error: String?
    @Published var loading = false
    @Published var popView = false
    @Published var forgetPassTapped = false
    @Published var showMergeAlert = false
    
    var getMobileNumber:(() -> Void)?
    
    var cancellable: AnyCancellable?
    
    func signIntapped() {
        emailID = emailID.trimmingCharacters(in: .whitespacesAndNewlines)
        if emailID.isEmpty {
            error = "Please enter Email Id"
        } else if password.isEmpty {
            error = "Please enter the password"
        } else if !emailID.isValidEmail() {
            error = "Please enter valid email"
        } else {
            AppToken.shared.getToken { (token) in
                self.doLogin(token)
            }
        }
    }
    
    func doLogin(_ token: String) {
        loading = true
        let data = LoginRequestData(username: emailID, password: password, deviceID: UIDevice.current.identifierForVendor?.uuidString ?? "", deviceType: "2", isApp: "1")
        let data1 = LoginRequest(data: data, tID: token)
        HitApi.shared.postData("DoLogin", bodyData: data1) { (result: Result<UserModel, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let output):
                    UserDefaultsController.shared.userModel = output
                    self.getHistory(userid: output.globalUserId)
                case .failure(let err):
                    self.error = err.toString()
            }
        }
    }
    
    func getHistory(userid: Int) {
        self.loading = true
        AppToken.shared.getToken { (token) in
            let request = GlobalUserLoginModel(data: GlobalUserLoginData(globalUserID: String(userid), locationtid: token), tID: staticToken)
            HitApi.shared.postData("GetCustOrderHistory", bodyData: request) { (result: Result<OrderHistoryResponse, HitApiError>) in
                self.loading = false
                switch result {
                    case .success(let response):
                        saveCustFCMToken()
                        let orders = response.orderHistory.filter({chainId == $0.chainId})
                        UserDefaultsController.shared.userModel?.orderHistory = orders
                        self.popView = true
                    case .failure(let error):
                        self.error = error.toString()
                }
            }
        }
    }
    
    func gmalLoginTapped() {
      guard let vc = UIApplication.shared.windows.first?.rootViewController,
              let filePath = Bundle.main.path(forResource: googleServiceFileName, ofType: "plist"),
              let firebaseOptions = FirebaseOptions(contentsOfFile: filePath),
              let gid = firebaseOptions.clientID  else { return }
        GIDSignIn.sharedInstance.signIn(with: GIDConfiguration(clientID: gid), presenting: vc) { user, error in
            if let err = error {
                if (err as NSError).code != GIDSignInError.canceled.rawValue {
                    self.error = err.localizedDescription
                }
                return
            }
            guard let user = user, let userid = user.userID, let profile = user.profile else { return }
            AppToken.shared.getToken { (token) in
                self.doSocialMediaLogin(request: SocialLoginRequest(data: SocialLoginRequestData(customerfbdata: Customerfbdata(fID: userid, fName: profile.name, fbemail: profile.email, lName: profile.familyName, logintype: "google")), tID: token))
            }
        }
        
        GIDSignIn.sharedInstance.disconnect { error in
            if (error as NSError?)?.code != GIDSignInError.canceled.rawValue {
                self.error = error?.localizedDescription
            }
        }
    }
    
    func appleLoginTapped() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    func doSocialMediaLogin(request: SocialLoginRequest) {
        self.loading = true
        HitApi.shared.postData("DoSocialMediaLogin", bodyData: request) { (result: Result<UserModel, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let result):
                    if (result.tel ?? result.cell ?? "").isEmpty {
                        self.getMobileNumber?()
                    } else {
                        self.getHistory(userid: result.globalUserId)
                    }
                    UserDefaultsController.shared.userModel = result
                case .failure(let err):
                    if request.data.customerfbdata.fbemail == nil {
                        self.error = "\(err.toString())\nTo be able to Sign in with apple, please go to settings -> Your_Name -> Password & Security -> Apps Using Apple ID -> \(appName) -> Stop using Apple ID."
                    } else {
                        self.error = err.toString()
                    }
            }
        }
    }
    
}


extension SignInViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.windows.last!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let appleId = appleIDCredential.user
            let savedDetails = UserDefaultsController.shared.appleLoginDetails
            let appleUserFirstName = appleIDCredential.fullName?.givenName ?? savedDetails?.fName
            let appleUserLastName = appleIDCredential.fullName?.familyName ?? savedDetails?.lName
            let appleUserEmail = appleIDCredential.email ?? savedDetails?.fbemail
    
            let data = Customerfbdata(fID: appleId, fName: appleUserFirstName, fbemail: appleUserEmail, lName: appleUserLastName, logintype: "google")
            UserDefaultsController.shared.appleLoginDetails = data
            AppToken.shared.getToken { (token) in
                self.doSocialMediaLogin(request: SocialLoginRequest(data: SocialLoginRequestData(customerfbdata: data), tID: token))
            }
        }
        //        else if let passwordCredential = authorization.credential as? ASPasswordCredential { }
        else {
            self.error = "Something went wrong!"
        }
        
    }
    
}
