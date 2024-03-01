//
//  FeedbackViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 04/12/20.
//

import Foundation

class FeedbackViewModel: ObservableObject {
    @Published var rate1 = 0
    @Published var rate2 = 0
    @Published var rate3 = 0
    @Published var rate4 = 0
    @Published var rate5 = 0
    @Published var otherComment = ""
    @Published var error: String?
    @Published var loading = false
    @Published var successMessage = false
    let order: OrderHistory
    
    init(order: OrderHistory) {
        self.order = order
    }
    func submitTapped() {
        if rate1 == 0 || rate2 == 0 || rate3 == 0 || rate4 == 0 || rate5 == 0 {
            error = "Please provide your rating"
        } else {
            AppToken.shared.getToken { (token) in
                self.sendFeedback(staticToken)
            }
        }
    }
    
    
    func sendFeedback(_ token:String) {
        guard let user = UserDefaultsController.shared.userModel else { return }
        let request = FeedbackRequest(data: FeedbackRequestData(feedbackData: FeedbackData(answer1: rate1, answer2: rate2, answer3: rate3, answer4: rate4, answer5: rate5, answer6: 0, answer7: 0, answer8: 0, answer9: 0, answer10: 0, comment: otherComment, customerEmail: user.email ?? "", customerName: user.username ?? "", customerTelephone: user.tel ?? "", orderNumber: order.orderNumber, orderTotal: order.totalAmt, paymentMode: order.paymentType, restLocationID: String(order.locationId), restaurantAddress: "", restaurantName: order.locationName, restaurantTelephone: "")), tid: token)
        self.loading = true
        HitApi.shared.postData("SaveOrderFeedback", bodyData: request) { (result: Result<String, HitApiError>) in
            self.loading = false
            switch result {
                case .success(_):
                    self.successMessage = true
                case .failure(let err):
                    self.error = err.toString()
            }
        }
    }
}


// MARK: - FeedbackRequest
struct FeedbackRequest: Codable {
    let data: FeedbackRequestData
    let tid: String
}

// MARK: - DataClass
struct FeedbackRequestData: Codable {
    let feedbackData: FeedbackData
}

// MARK: - FeedbackData
struct FeedbackData: Codable {
    let answer1, answer2, answer3, answer4, answer5: Int
    let answer6, answer7, answer8, answer9, answer10: Int
    let comment, customerEmail: String
    let customerName, customerTelephone, orderNumber, orderTotal: String
    let paymentMode, restLocationID, restaurantAddress, restaurantName: String
    let restaurantTelephone: String
    
    enum CodingKeys: String, CodingKey {
        case answer1 = "Answer1"
        case answer10 = "Answer10"
        case answer2 = "Answer2"
        case answer3 = "Answer3"
        case answer4 = "Answer4"
        case answer5 = "Answer5"
        case answer6 = "Answer6"
        case answer7 = "Answer7"
        case answer8 = "Answer8"
        case answer9 = "Answer9"
        case comment
        case customerEmail = "CustomerEmail"
        case customerName = "CustomerName"
        case customerTelephone = "CustomerTelephone"
        case orderNumber = "OrderNumber"
        case orderTotal = "OrderTotal"
        case paymentMode = "PaymentMode"
        case restLocationID = "RestLocationId"
        case restaurantAddress = "RestaurantAddress"
        case restaurantName = "RestaurantName"
        case restaurantTelephone = "RestaurantTelephone"
    }
}
