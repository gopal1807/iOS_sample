//
//  Extensions.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 19/11/20.
//

import SwiftUI

extension View {
    func imageSize(with size: Double) -> some View {
        self.modifier(ImageSize(size: CGFloat(size)))
    }
    
    func addNeumoShadow(shadowRadius: CGFloat = 10) -> some View {
        self.modifier(AddNeumoShadow(shadowRadius: shadowRadius))
    }
    
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        self.modifier(CornerRadiusStyle(radius: radius, corners: corners))
    }
    
    func roundedCorner(radius: CGFloat = 3, padding: CGFloat = 5, color: Color = Color.gray) -> some View {
        self.modifier(RoundedBorder(radius: radius, color: color, padding: padding))
    }

}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


extension TimeZone {
    func restTimeZone() -> TimeZone {
        guard let cstTimeZone = TimeZone(abbreviation: "CST") else { return self }
        let timezoneOffset = cstTimeZone.secondsFromGMT()
        guard let restGivenDifference = UserDefaultsController.shared.cartSavedData?.otherInfo?.restaurant.timeZone else { return cstTimeZone }
        let totalSeconds = timezoneOffset + (restGivenDifference.hoursDifference * 3600 + restGivenDifference.minutesDifference * 60)
        return TimeZone(secondsFromGMT: totalSeconds) ?? cstTimeZone
    }
    
    func restTimeZone(timeZ: RestaurantTimeZone) -> TimeZone {
        guard let cstTimeZone = TimeZone(abbreviation: "CST") else { return self }
        let timezoneOffset = cstTimeZone.secondsFromGMT()
        let totalSeconds = timezoneOffset + (timeZ.hoursDifference * 3600 + timeZ.minutesDifference * 60)
        return TimeZone(secondsFromGMT: totalSeconds) ?? cstTimeZone
    }
    
    func dateToTimeZoneDate(date: Date) -> Date {
        let diff = self.secondsFromGMT(for: date)
        return Date(timeIntervalSinceNow: TimeInterval(diff))
    }
}

extension Calendar {
    static var cstCalendar: Calendar {
        var calender = Calendar(identifier: Calendar.current.identifier)
        let zone = TimeZone.current.restTimeZone()
        print("RestaurantTimeZone:-----",zone)
        calender.timeZone = zone
        return calender
    }
    
    func restCal(timeZ: RestaurantTimeZone) -> Calendar {
        var calender = Calendar(identifier: Calendar.current.identifier)
        let zone = TimeZone.current.restTimeZone(timeZ: timeZ)
        calender.timeZone = zone
        return calender
    }
}


extension OpenOn {
    func isOpenToday(timeZone: RestaurantTimeZone, date: Date) -> Bool {
        let weekDay = Calendar.cstCalendar.component(.weekday, from: date)
        switch weekDay {
            case 1:
                return self.sun == .some(.t)
            
            case 2:
                return self.mon == .some(.t)
            
            case 3:
                return self.tue == .some(.t)
            
            case 4:
                return self.wed == .some(.t)
            
            case 5:
                return self.thu == .some(.t)
            
            case 6:
                return self.fri == .some(.t)
            
            case 7:
                return self.sat == .some(.t)
            default:
                return false
        }
        
    }
}

extension String: Identifiable {
    public var id: String {
        self
    }
    
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
    var toDouble: Double {
        return Double(self) ?? 0
    }
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    var isPhoneNumber: Bool {
        let charcter  = NSCharacterSet(charactersIn: "0123456789").inverted
        let inputString = self.components(separatedBy: charcter)
        return self == inputString.joined() && self.count == 10
    }
    
    func seperateCountryCode() -> (String, String) {
        var completeNumber = self.trimmingCharacters(in: .whitespacesAndNewlines)
        completeNumber.removeAll(where: {!$0.isNumber})
        let number = completeNumber.suffix(10)
        let code = completeNumber.dropLast(number.count)
        return (String(code),String(number))
    }
}

extension Double {
    var to2Decimal: String {
        return String(format: "%.2f", self)
    }
}

extension DateFormatter {
    func two4To12hr(time: String) -> String {
        dateFormat = "HH:mm:ss"
        if let d = date(from: time) {
            dateFormat = "hh:mm a"
            return string(from: d)
        } else {
            return time
        }
    }
}

extension Encodable {
    func hasKey(for path: String) -> Bool {
        return Mirror(reflecting: self).children.contains { $0.label == path }
    }
    func value(for path: String) -> Any? {
        return Mirror(reflecting: self).children.first { $0.label == path }?.value
    }
    func key(for val: Double) -> String? {
        return Mirror(reflecting: self).children.first(where: {($0.value as? Double) == val})?.label
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension Notification.Name {
    static let dismissLoginView = Notification.Name("dismissLoginView")
    static let newItemAddedTocart = Notification.Name("newItemAddedTocart")
    static let dataUpdated = Notification.Name("dataUpdated")
}


class Debounce: NSObject {
    var timer: Timer?
    
    func debounce(seconds: TimeInterval, function: @escaping () -> Swift.Void ) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { _ in
            function()
        })
    }
}
