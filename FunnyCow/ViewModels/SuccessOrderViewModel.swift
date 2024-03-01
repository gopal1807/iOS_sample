//
//  SuccessOrderViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 02/12/20.
//

import UIKit
import Combine
import SwiftUI

class SuccessOrderViewModel: ObservableObject {
    
    var timeZone: TimeZone?
    init() {
        self.timeZone = TimeZone.current.restTimeZone()
        getToken()
        getHistory()
        order = UserDefaultsController.shared.cartSavedData
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: nil) { notification in
            if UserDefaultsController.shared.cartSavedData != nil {
                UserDefaultsController.shared.removeCartData()
            }
        }
    }
    
    @Published var isLoading = false
    @Published var timeForPicup = ""
    @Published var orderNumber = ""
    @Published var error: String?
    @Published var selectedTab: Int?
    var order = UserDefaultsController.shared.cartSavedData
    
    let orderProgress = [
        //        OrderProgress(title: "Order Placed", subTitle: "We have received your order", image: "order_placed"),
        OrderProgress(title: "Order Confirmed", subTitle: "Your order has been confirmed", image: "order_confirm"),
        OrderProgress(title: "Order Processed", subTitle: "We are preparing your food", image: "order_processing"),
        OrderProgress(title: "Order Completed", subTitle: "We have successfully completed your order", image: "order_deliver")
    ]
    
    func contactRestaurant() {
        let tel = order?.otherInfo?.restaurant.tel ?? ""
        let urlString = "tel://\(tel)"
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {return}
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func stringToStringDate(date:String?) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = self.timeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        guard let dd = date, let newDate =  formatter.date(from: dd) else {return ""}
        formatter.dateFormat = "MM-dd-yyyy hh:mm a"
        return formatter.string(from: newDate)
    }
    
    func getToken() {
        isLoading = true
        AppToken.shared.getToken { (token) in
            self.getLastOrder(token: token)
        }
    }
    
    func getLastOrder(token: String) {
        guard let custId = UserDefaultsController.shared.userModel?.id,
              let order = order  else { return }
        timeForPicup = stringToStringDate(date: order.dueOn)
        self.isLoading = true
        let request = DoLoginRequest(data: DoLoginRequestData(custID: custId), tID: token)
        HitApi.shared.postData("GetLastOrder", bodyData: request) { (result: Result<LastOrderResponse, HitApiError>) in
            self.isLoading = false
            switch result {
                case .success(let success):
                    self.orderNumber = (success.orderNumber ?? "")
                case .failure(let error):
                    print(error)
                    self.error = error.toString()
            }
        }
    }
    
    func getHistory() {
        guard let userid = UserDefaultsController.shared.userModel?.globalUserId else {return}
        AppToken.shared.getToken { (token) in
            let request = GlobalUserLoginModel(data: GlobalUserLoginData(globalUserID: String(userid), locationtid: token), tID: staticToken)
            HitApi.shared.postData("GetCustOrderHistory", bodyData: request) { (result: Result<OrderHistoryResponse, HitApiError>) in
                switch result {
                    case .success(let response):
                        let orders = response.orderHistory.filter({chainId == $0.chainId})
                        UserDefaultsController.shared.userModel?.orderHistory = orders
                    case .failure(let error):
                        print(error.toString())
                }
            }
        }
    }
}


struct OrderProgress: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
    let image: String
}

// MARK: - LastOrderResponse
struct LastOrderResponse: Codable {
    let orderID: Int?
    let orderNumber, createdOn, status, totalAmt: String?
    let paymentType, restService: String?
    
    enum CodingKeys: String, CodingKey {
        case orderID = "OrderId"
        case orderNumber = "OrderNumber"
        case createdOn = "CreatedOn"
        case status = "Status"
        case totalAmt = "TotalAmt"
        case paymentType = "PaymentType"
        case restService = "RestService"
    }
}

// MARK: - OrderHistory
struct OrderHistoryResponse: Codable {
    let orderHistory: [OrderHistory]
    
    enum CodingKeys: String, CodingKey {
        case orderHistory = "OrderHistory"
    }
}
