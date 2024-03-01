//
//  SelectLocationView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 18/11/20.
//

import SwiftUI
import MapKit

struct SelectLocationView: View {
    init(address: AddressBook?) {
        let model = NewAddressViewModel(address: address)
        _viewModel = StateObject(wrappedValue: model)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "AccentColor")
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
    @StateObject private var viewModel: NewAddressViewModel
    @Environment(\.presentationMode) var presentation
    var body: some View {
        ZStack(alignment: .top) {
            alerts()
            VStack(alignment: .leading) {
                ZStack {
                    ZStack(alignment: .bottomTrailing) {
                        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                        Button(action: {
                            viewModel.currentLocationtapped()
                        }, label: {
                            Image("currentLocation")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color.appAccent)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .addNeumoShadow(shadowRadius: 3)
                                .padding(10)
                        })
                    }
                    Image(systemName: "mappin")
                        .font(.title)
                        .foregroundColor(Color("redColor"))
                        .offset(y: -15)
                }
                .padding(.top)
                Text("Your Location")
                    .font(.headline)
                    .foregroundColor(Color.gray)
                    .padding(.horizontal)
                Label(viewModel.addressString, systemImage: "checkmark.circle")
                    .foregroundColor(Color("redColor"))
                    .padding(.horizontal)
                Divider()
                Group {
                    TextField("Enter Name", text: $viewModel.userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    PhoneNumberRoundedCorner(title: "Enter Phone", text: $viewModel.telPhone, countryCode: $viewModel.countryCode)
                    
                    TextField("Address", text: $viewModel.address1)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                    TextField("Apartment, suite, unit, building, floor, etc.", text: $viewModel.doorFlat)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                    TextField(viewModel.instructionPlaceholder, text: $viewModel.specialInstructions)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                Picker("", selection: $viewModel.selectedType) {
                    ForEach(0..<viewModel.types.count) { index in
                        Text(viewModel.types[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                Button(action: {
                    viewModel.saveAddress()
                }, label: {
                    Text("Save & Proceed")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20.0)
                        .padding(.vertical, 8)
                        .background(
                            Color.black
                                .overlay(
                                    LinearGradient(gradient: Gradient(colors: [Color.appAccent.opacity(0.5), Color.appAccent]), startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(Capsule())
                        )
                    
                })
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            VStack {
                HStack {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.backward")
                            .imageScale(.large).padding(5)
                    }
                    SearchBar(text: $viewModel.searchQuery, placeHolder: "Search place")
                }
                if !viewModel.completions.isEmpty && !viewModel.searchQuery.isEmpty {
                    List(viewModel.completions) { completion in
                        let selectedItem = completion.placemark
                        let address = "\(selectedItem.thoroughfare ?? ""), \(selectedItem.locality ?? ""), \(selectedItem.subLocality ?? ""), \(selectedItem.administrativeArea ?? ""), \(selectedItem.postalCode ?? ""), \(selectedItem.country ?? "")"
                        VStack(alignment: .leading) {
                            Text(selectedItem.name ?? "")
                            Text(address)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }.onTapGesture {
                            viewModel.searchQuery.removeAll()
                            UIApplication.shared.endEditing()
                            viewModel.region = MKCoordinateRegion(
                                center: completion.placemark.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        }
                    }
                }
            }
            .background(Color.white)
            
            if viewModel.loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.3))
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .onAppear {
            viewModel.locationManager.requestWhenInUseAuthorization()
            viewModel.cancellable = viewModel.$popView.sink { (pop) in
                if pop {
                    self.presentation.wrappedValue.dismiss()
                }
            }
        }
    }
    
    func alerts() -> some View {
        return VStack {
            Text("")
                .alert(isPresented: $viewModel.showLocationError) { () -> Alert in
                    Alert(title: Text("Please allow app to use location service."), message: nil, primaryButton: .default(Text("OK"), action: viewModel.goToLocationSetting), secondaryButton: .cancel())
                }
            
            Text("")
                .alert(item: $viewModel.error, content: { (error) -> Alert in
                    Alert(title: Text(error))
                })
        }
    }
}

//struct SelectLocationView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//        SelectLocationView(address: nil)
//        }
//            .previewDevice("iPhone 11")
//    }
//}
