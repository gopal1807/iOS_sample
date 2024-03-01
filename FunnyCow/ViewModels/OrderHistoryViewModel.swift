//
//  OrderHistoryViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 04/12/20.
//

import Foundation

class OrderHistoryViewModel: ObservableObject {
    @Published var errror: String?
    @Published var loading = false
    @Published var showNav = true
    @Published var orders = [OrderHistory]()
    
    init() {
        orders = UserDefaultsController.shared.userModel?.orderHistory ?? []
    }
    
    func getHistory() {
        guard let userid = UserDefaultsController.shared.userModel?.globalUserId else {return}
        self.loading = true
        AppToken.shared.getToken { (token) in
        let request = GlobalUserLoginModel(data: GlobalUserLoginData(globalUserID: String(userid), locationtid: token), tID: staticToken)
            HitApi.shared.postData("GetCustOrderHistory", bodyData: request) { (result: Result<OrderHistoryResponse, HitApiError>) in
                self.loading = false
                switch result {
                    case .success(let response):
                        let orders = response.orderHistory.filter({chainId == $0.chainId})
                        UserDefaultsController.shared.userModel?.orderHistory = orders
                        self.orders = orders
                    case .failure(let error):
                        self.errror = error.toString()
                }
            }
        }
    }
}
