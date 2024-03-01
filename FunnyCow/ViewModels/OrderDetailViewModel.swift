//
//  OrderDetailViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 29/12/20.
//

import Foundation

class OrderDetailViewModel: ObservableObject {
    
    let history: OrderHistory
    
    var progress: [OrderProgress] {
        return model?.status == "Canceled" ?
            cancelledProgress : orderProgress
    }
    
    var orangePoint: Int {
        return max(1, orderStatusNumber)
    }
    var mobUrl: String?
    @Published var error: String?
    @Published var loading = false
    @Published var model: OrderDetailModel?
    @Published var pushtoFeedback = false
    
    var orderStatusNumber: Int {
        return ["Canceled", "Open", "Confirmed", "Preparing", "Delivered"].firstIndex(where: {$0 == model?.status}) ?? 1
    }
    init(order: OrderHistory) {
        self.history = order
        self.getMobUrl()
    }
    
    fileprivate let orderProgress = [
         OrderProgress(title: "Order Placed", subTitle: "We have received your order", image: "order_placed"),
         OrderProgress(title: "Order Confirmed", subTitle: "Your order has been confirmed", image: "order_confirm"),
         OrderProgress(title: "Order Processed", subTitle: "We are preparing your food", image: "order_processing"),
         OrderProgress(title: "Order Completed", subTitle: "We have successfully completed your order", image: "order_deliver")
     ]
     
     fileprivate let cancelledProgress = [
         OrderProgress(title: "Order Placed", subTitle: "We have received your order", image: "order_placed"),
         OrderProgress(title: "Order Canceled", subTitle: "Your order was canceled", image: "order_confirm"),
     ]
    
    func getMobUrl() {
        let body = TidData(data: ["locationId" : "\(self.history.locationId)"], tID: staticToken)
        self.loading = true
        HitApi.shared.postData("GetLocationMobURL", bodyData: body) { (result: Result<String, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let model):
                    self.mobUrl = model
                    AppToken.shared.getToken(model) { (token) in
                        self.getDetail(id: self.history.id, token: token)
                    }
                case .failure(let err):
                    self.error = err.toString()
            }
        }
    }
  
    func getDetail(id: Int, token: String) {
        loading = true
        HitApi.shared.postData("GetOrderInfo", bodyData: TidData(data: ["orderId": "\(id)"], tID: token)) {
            (result: Result<OrderDetailModel, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let model):
                    self.model = model
                case .failure(let err):
                    self.error = err.toString()
            }
        }
    }
    

}

