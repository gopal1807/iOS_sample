//
//  ScheduleOrderView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 11/11/20.
//

import SwiftUI

struct ScheduleOrderView: View {
    @Environment(\.presentationMode) var presentation
    @StateObject private var viewModel: ScheduleTimeViewModel
    init(isDelivery: Bool) {
        let schedVM = ScheduleTimeViewModel(isDelivery: isDelivery)
        _viewModel = StateObject(wrappedValue: schedVM)
        UIDatePicker.appearance().calendar = schedVM.calender
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "greenColor")
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
    
    var body: some View {
        VStack {
            Text(viewModel.titleText)
                .font(.title2)
                .foregroundColor(Color.appGreen)
            Picker("", selection: $viewModel.selectedSegment) {
                ForEach(0..<viewModel.options.count, id: \.self) { index in
                    Text(viewModel.options[index].rawValue)
                        .tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            Form {
                if viewModel.isTodayaAvailable() {
                    DatePicker("Select time", selection: $viewModel.todaySelectedTime, in: viewModel.todayTimeRange, displayedComponents: .hourAndMinute)
                        //                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                        .environment(\.timeZone, viewModel.calender.timeZone)
                        .padding()
                }
                
                if viewModel.isLaterAvailable() {
                    DatePicker("Select a date", selection: $viewModel.laterSelectedDate, in: viewModel.laterDateRange, displayedComponents: .date)
                        .environment(\.timeZone, viewModel.calender.timeZone)
                    if viewModel.isFutureTimeAvailable {
                        DatePicker("Select time", selection: $viewModel.laterSelectedTime, in: viewModel.laterTimeRange, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(WheelDatePickerStyle())
                            .environment(\.timeZone, viewModel.calender.timeZone)
                    } else {
                        Text("Please select another date as Online ordering is not available on selected week day.")
                            .fontWeight(.semibold)
                            .padding(10)
                            .frame(maxWidth: 500)
                    }
                }
                
                if !viewModel.options.isEmpty && (viewModel.isLaterAvailable() ? viewModel.isFutureTimeAvailable : true) {
                    Button {
                        if viewModel.saveTime() {
                            presentation.wrappedValue.dismiss()
                        }
                    } label: {
                        Text("SELECT TIME")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.white)
                            .padding(10)
                            .frame(maxWidth: 500)
                            .background(Color.appGreen)
                    }
                    .padding()
                }
            }
            Spacer()
        }
        .alert(item: $viewModel.error, content: { (err) -> Alert in
            Alert(title: Text(err))
        })
        .onAppear {
            viewModel.setComponents()
        }
        .navigationBarTitle("Schedule My Order", displayMode: .inline)
    }
}
