//
//  ProfileViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 25/11/20.
//

import Foundation

class ProfileViewModel {
    var userModel = UserDefaultsController.shared.userModel
    
    var name: String {
        var name = (userModel?.fName ?? "")
        name += " \(userModel?.mName ?? "")"
        name += " \(userModel?.lName ?? "")"
       return name.replacingOccurrences(of: "  ", with: " ")
    }
    
    var  email: String {
        userModel?.email ?? ""
    }
    
    var phoneNumber: String {
        userModel?.tel ?? userModel?.cell ?? ""
    }
    
    var rewardPoints: String {
        "Coming soon"//userModel?.loyaltyPoints ?? "0"
    }
    
    var totalOrders: String {
        String(userModel?.orderHistory?.count ?? 0)
    }
    
    var lastOrderTime: String {
        let date = userModel?.orderHistory?.first?.createdOn
        return changeCreatedOn(date: date)
    }
    
    func changeCreatedOn(date: String?) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current.restTimeZone()
        formatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
        guard let dd = formatter.date(from: date ?? "") else { return "Not yet" }
        let formatter1 = RelativeDateTimeFormatter()
        formatter1.unitsStyle = .full
        return formatter1.localizedString(for: dd, relativeTo: Date())
    }
    
}
