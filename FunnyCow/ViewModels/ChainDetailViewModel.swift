//
//  ChainDetailViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 19/11/20.
//

import UIKit

class ChainDetailViewModel: ObservableObject {
    
    @Published var generalError: String?
    @Published var locationList = [ChainLocationDetail]()
    @Published var restaurantName = ""
    @Published var showLoader = false
    
    init() {
        getToken()
    }
    
    func getToken() {
        showLoader = true
        AppToken.shared.getToken { (token) in
            self.showLoader = false
            if token.lowercased().contains("location") {
                self.generalError = token
            } else {
                let data = ChainDetailsRequest(tID: token, data: ChainDetailsRequestData(chainID: chainId, mobURL: defaultMobUrl))
                self.fetchList(data: data)
            }
        }
    }
    
    func fetchList(data: ChainDetailsRequest) {
        showLoader = true
        HitApi.shared.postData("GetChainDetails", bodyData: data) { (result: Result<ChainDetails, HitApiError>) in
            self.showLoader = false
            switch result {
                case .success(let success):
                    self.restaurantName = success.name
                    self.locationList = success.locationList.filter({$0.active == "True"
                        && !$0.isUnlinkedForPortal
                    })
                    if self.locationList.isEmpty {
                        guard let location = success.locationList.first else {
                            self.generalError = "No location found for chain: \(success.id)"
                            return
                        }
                        let active = location.active
                        let unlink = location.isUnlinkedForPortal
                        let error = "ChainId: \(success.id)\nlocationId: \(location.id)\nActive: \(active),  isUnlink: \(unlink)"
                        self.generalError = error
                    }
                case .failure(let err):
                    self.generalError = err.toString()
            }
        }
    }
    
    func callRestaurant(detail: ChainLocationDetail) {
        guard let url = URL(string: "tel://" + detail.tel), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}


// MARK: - ChainDetailsRequest
struct ChainDetailsRequest: Codable {
    let tID: String
    let data: ChainDetailsRequestData

    enum CodingKeys: String, CodingKey {
        case tID = "tId"
        case data
    }
}

// MARK: - DataClass
struct ChainDetailsRequestData: Codable {
    let chainID: Int
    let mobURL: String

    enum CodingKeys: String, CodingKey {
        case chainID = "chainId"
        case mobURL = "mobUrl"
    }
}
