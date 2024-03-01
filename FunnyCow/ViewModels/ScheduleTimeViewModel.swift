//
//  ScheduleTimeViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 24/11/20.
//

import Foundation
import SwiftUI

class ScheduleTimeViewModel: ObservableObject {
    
    enum segmentOption: String {
        case asap = "ASAP"
        case today = "TODAY"
        case later = "LATER"
    }
    
    var options: [segmentOption] = []
    @Published var selectedSegment = 0 {
        didSet {
            setTime()
        }
    }
    @Published var error: String?
    @Published var todaySelectedTime: Date!
    @Published var laterSelectedDate: Date! { didSet { setFutureTime() } }
    @Published var laterSelectedTime: Date!
    var todayTimeRange: ClosedRange<Date> = Date()...Date()
    var laterTimeRange: ClosedRange<Date> = Date()...Date()
    var laterDateRange: ClosedRange<Date> = Date()...Date()
    @Published var titleText = ""
    @Published var isFutureTimeAvailable = false
    var restaurantSchedule: Schedule?
    
    init(isDelivery: Bool) {
        self.isDelivery = isDelivery
//        setComponents()
    }
    let isDelivery: Bool
    let calender = Calendar.cstCalendar

    func setComponents() {
        guard let orderdata = UserDefaultsController.shared.cartSavedData,
              let otherData = orderdata.otherInfo else { return }
        var restNowDate = Date()
        restNowDate.addTimeInterval(100)
        let restTime = otherData.restaurant.checkIsRestaurantOpen().1
        let openTime = stringToDate(openTime: isDelivery ? restTime?.firstDel ?? "" : restTime?.firstOrd ?? "")
        var closeTime = stringToDate(openTime: isDelivery ? (restTime?.lastDel ?? "") : (restTime?.lastOrd ?? ""))
        if closeTime < openTime {
            closeTime = closeTime.addingTimeInterval(86400)
        }
        var todayOpenTime = max(restNowDate, openTime)
        
        if let serviceMin = otherData.restaurant.services.first(where: {$0.id == orderdata.serviceID})?.readyInMin.toDouble,
           let dd = calender.date(byAdding: .minute, value: Int(serviceMin), to: todayOpenTime) {
            todayOpenTime = dd
        }
       
        let isRestOpenNow = otherData.restaurant.checkIsRestaurantOpen()
        restaurantSchedule = isRestOpenNow.1

        if otherData.isAsap, isRestOpenNow.0 {
            options.append(.asap)
        }
        
        if otherData.isToday, otherData.restaurant.checkIsRestaurantOpenToday().0, todayOpenTime < closeTime {
            self.todayTimeRange = todayOpenTime...closeTime
            options.append(.today)
        }
        
        if otherData.isFuture, let tomorrow = calender.date(byAdding: .day, value: 1, to: restNowDate), let endTime = calender.date(byAdding: .day, value: 7, to: tomorrow) {
            self.laterDateRange = tomorrow...endTime
            options.append(.later)
            laterSelectedDate = tomorrow
            setFutureTime()
        }
        
        if options.isEmpty {
            self.error = "Online ordering is currently not available."
        }
        setTime()
        withAnimation {
            self.objectWillChange.send()
        }
    }
    
    func setFutureTime() {
        guard let orderdata = UserDefaultsController.shared.cartSavedData,
              let otherData = orderdata.otherInfo, let laterSelectedDate = laterSelectedDate else {
            isFutureTimeAvailable = false
            return
        }
        let restTime = otherData.restaurant.checkIsRestaurantOpen(on: laterSelectedDate).1
        let openTime = stringToDate(openTime: isDelivery ? restTime?.firstDel ?? "" : restTime?.firstOrd ?? "")
        var closeTime = stringToDate(openTime: isDelivery ? (restTime?.lastDel ?? "") : (restTime?.lastOrd ?? ""))
        if closeTime < openTime {
            closeTime = closeTime.addingTimeInterval(86400)
        }
        let seconds = closeTime.timeIntervalSince(openTime)
        let minutes = Int(seconds) / 60
        if abs(minutes) > 15 {
            self.laterTimeRange = openTime...closeTime
            isFutureTimeAvailable = true
        } else {
            isFutureTimeAvailable = false
        }
    }
    
    func setTime() {
        guard options.indices.contains(selectedSegment) else {
            todaySelectedTime = nil
            laterSelectedDate = nil
            laterSelectedTime = nil
            titleText = "Schedule Food"
            return
        }
     
        if options[selectedSegment] == .asap {
            titleText = "Schedule for ASAP!"
            todaySelectedTime = nil
            laterSelectedDate = nil
            laterSelectedTime = nil
        } else if options[selectedSegment] == .today {
            titleText = "Select a time for later today"
            todaySelectedTime = todayTimeRange.lowerBound
            laterSelectedDate = nil
            laterSelectedTime = nil
        } else {
            titleText = "Select a time upto 7 days in advance"
            todaySelectedTime = nil
            laterSelectedDate = laterDateRange.lowerBound
            laterSelectedTime = laterTimeRange.lowerBound
        }
      
    }
    
    func stringToDate(openTime: String) -> Date {
        let date = Date()
    
        let values = openTime.components(separatedBy: ":")
        let hour: Int = Int(values.first ?? "0") ?? 0
        let min: Int = Int(values.indices.contains(1) ? values[1] : "0") ?? 0
        let sec: Int = Int(values.indices.contains(2) ? values[2] : "0") ?? 0
        if let bigDate = calender.date(bySettingHour: 0, minute: 0, second: 0, of: date, matchingPolicy: .strict, direction: .backward),
           let returnDate = calender.date(bySettingHour: hour, minute: min, second: sec, of: bigDate, matchingPolicy: .strict, direction: .forward) {
            return returnDate
        }
        return date
    }
    
    func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = calender.timeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: date)
    }
    
    func saveTime() -> Bool {
        let date = Date()
        if options[selectedSegment] == .today {
            UserDefaultsController.shared.cartSavedData?.timeSelection = 1
            UserDefaultsController.shared.cartSavedData?.createdOn = dateToString(date: date)
            UserDefaultsController.shared.cartSavedData?.dueOn = dateToString2(date: date, time: todaySelectedTime)
        } else if options[selectedSegment] == .later {
            UserDefaultsController.shared.cartSavedData?.timeSelection = 2
            UserDefaultsController.shared.cartSavedData?.createdOn = dateToString(date: date)
            UserDefaultsController.shared.cartSavedData?.dueOn = dateToString2(date: laterSelectedDate, time: laterSelectedTime)
        } else {
            UserDefaultsController.shared.cartSavedData?.timeSelection = 0
        }
        return true
    }
    
    func dateToString2(date: Date, time: Date) -> String {
        let hour = calender.component(.hour, from: time)
        let minute = calender.component(.minute, from: time)
        let year = calender.component(.year, from: date)
        let month = calender.component(.month, from: date)
        let day = calender.component(.day, from: date)
        
        let gotDate = calender.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) ?? date
        
        return dateToString(date: gotDate)
    }
    
    func isTodayaAvailable() -> Bool {
        return options.indices.contains(selectedSegment) && options[selectedSegment] == .today && todaySelectedTime != nil
    }
    
    func isLaterAvailable() -> Bool {
        return options.indices.contains(selectedSegment) && options[selectedSegment] == .later && laterSelectedTime != nil && laterSelectedDate != nil
    }
}
