//
//  UserDefaultsController.swift
//  Exchange
//
//  Created by Gopal Krishan on 09/06/20.
//  Copyright © 2020 Gopal Krishan. All rights reserved.
//

import UIKit
import AuthenticationServices

class UserDefaultsController: ObservableObject {
    static let shared = UserDefaultsController()
    private init() {
        if let data = UserDefaults.standard.data(forKey: "OrderData") {
            self.cartSavedData = try? JSONDecoder().decode(OrderData.self, from: data)
        }
        
        if let data = UserDefaults.standard.data(forKey: "usermodel") {
            self.userModel = try? JSONDecoder().decode(UserModel.self, from: data)
        }
        checkAppleLogin()
    }
    
    private let debouncer = Debounce()
    var fcmToken: String {
        get {
            UserDefaults.standard.string(forKey: "fcmToken") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "fcmToken")
        }
    }
    
    var appleLoginDetails: Customerfbdata? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "appleLoginDetails") else { return nil }
            return try? JSONDecoder().decode(Customerfbdata.self, from: data)
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: "appleLoginDetails")
            checkAppleLogin()
        }
    }
    
    func checkAppleLogin() {
        guard let userid = appleLoginDetails?.fID else { return }
        // Register for revocation notification
        NotificationCenter.default.addObserver(forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil, queue: nil) { _ in
            self.logout()
            self.appleLoginDetails = nil
        }
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userid) { (credentialState, error) in
            switch credentialState {
                case .revoked, .notFound:
                    self.logout()
                    self.appleLoginDetails = nil
                default: break
            }
        }
    }
    
    @Published var userModel: UserModel? {
        didSet {
            let data = try? JSONEncoder().encode(userModel)
            UserDefaults.standard.set(data, forKey: "usermodel")
        }
    }
    
    @Published var cartSavedData: OrderData? {
        didSet {
            let data = try? JSONEncoder().encode(cartSavedData)
            UserDefaults.standard.set(data, forKey: "OrderData")
            debouncer.debounce(seconds: 0.2) {
                NotificationCenter.default.post(name: .dataUpdated, object: nil)
            }
        }
    }
 
    var tempCartData = TempOrderDetails()
    
    func removeCartData() {
        cartSavedData = nil
    }
    
    func logout() {
        userModel = nil
        removeCartData()
        UserDefaults.standard.removeObject(forKey: "usermodel")
    }
}
