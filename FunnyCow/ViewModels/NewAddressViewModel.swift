//
//  NewAddressViewModel.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 25/11/20.
//

import SwiftUI
import MapKit
import Combine

class NewAddressViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    let instructionPlaceholder = "Special Instructions"
    let locationManager = CLLocationManager()
    var selectedAddress: AddressBook?
    let locationNameSearchDebouncer = Debounce()
    let geoCoder = CLGeocoder()
    var placeSelected: CLPlacemark?
    @Published var showLocationError = false
    @Published var error: String?
    @Published var popView = false
    var cancellable: AnyCancellable?
    @Published var loading = false
    @Published var doorFlat = ""
    @Published var address1 = ""
    @Published var specialInstructions = ""
    @Published var selectedType = 0
    var types = ["HOME", "OFFICE", "OTHER"]
    @Published var completions: [MKMapItem] = []
    @Published var addressString = ""
    @Published var userName = ""
    @Published var countryCode = "1"
    @Published var telPhone = "" {
        didSet {
            if telPhone.count > 10 {
                telPhone.removeLast(telPhone.count - 10)
            }
        }
    }
    @Published var searchQuery = "" {
        didSet {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchQuery
            //            request.region = mapView.region
            let search = MKLocalSearch(request: request)
            search.start { (respon, err) in
                self.completions = respon?.mapItems ?? []
            }
        }
    }
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 41.8781,
            longitude: -87.6298
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.01,
            longitudeDelta: 0.01
        )
    ) {
        didSet {
            locationNameSearchDebouncer.debounce(seconds: 0.8) {
                self.nameSearch()
            }
        }
    }
    
    func nameSearch() {
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)) { (_placemarks, _error) in
            self.addressString = ""
            if let placemark = _placemarks?.first {
                self.placeSelected = placemark
                var address: [String] = [placemark.name, placemark.locality, placemark.administrativeArea, placemark.country].compactMap{ $0 }
                address.removeAll(where: { $0.isEmpty })
                self.addressString = address.joined(separator: ", ")
                self.address1 = placemark.name ?? ""
            }
        }
    }
    
    init(address: AddressBook?) {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if let unrappedAddress = address {
            self.selectedAddress = unrappedAddress
            self.userName = unrappedAddress.fullName
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let phoneNumber = unrappedAddress.telephone.seperateCountryCode()
            self.telPhone = phoneNumber.1
            self.countryCode = phoneNumber.0

                self.region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: unrappedAddress.latitude.toDouble, longitude: unrappedAddress.longitude.toDouble),
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.01,
                        longitudeDelta: 0.01
                    )
                )
            specialInstructions = unrappedAddress.instructions
        } else if let user = UserDefaultsController.shared.userModel {
            var name = ""
            if !(user.fName ?? "").isEmpty {
                name += user.fName!
            }
            if !(user.mName ?? "").isEmpty {
                name += " \(user.mName!)"
            }
            if !(user.lName ?? "").isEmpty {
                name += " \(user.lName!)"
            }
            self.userName = name
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "  ", with: " ")
            let phoneNumber = (user.tel ?? "").seperateCountryCode()
            self.telPhone = phoneNumber.1
            self.countryCode = phoneNumber.0
        }
        
        doorFlat = address?.addr2 ?? ""
        selectedType = types.firstIndex(where: {address?.custAddressName.uppercased() == $0}) ?? 0
    }

    
    func saveAddress() {
//        if doorFlat.isEmpty {
//            error = "Please enter Apartment, suite, unit, building, floor, etc."
//            return
//        }
        if address1.isEmpty {
            error = "Please enter your address."
            return
        }
        if userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            error = "Please enter user name"
            return
        }
        
        if telPhone.isEmpty {
            error = "Please enter phone"
            return
        }
        if !telPhone.isPhoneNumber {
            error = "Please enter a valid phone number"
            return
        }
        AppToken.shared.getToken { (token) in
            self.setuserAddr(token)
        }
    }
    
    func setuserAddr(_ token: String) {
        guard let user = UserDefaultsController.shared.userModel else {
            error = "Login to continue"
            return
        }
        let custAddrId = selectedAddress?.id
        self.loading = true
        let name = userName.components(separatedBy: " ")
        let fname = name.first ?? ""
        let lname = name.count > 1 ? (name.last ?? "") : ""
        let mname = name.count > 2 ? name[1] : ""

        let instructions = specialInstructions == instructionPlaceholder ? "" : specialInstructions
        let request = AddAddressRequest(data: AddAddressRequestData(customerAddress: CustomerAddress(addr1: address1, addr2: doorFlat, addrName: types[selectedType], city: placeSelected?.locality ?? "", custID: user.id, fName: fname, instr: instructions, isPrimary: 0, lName: lname, lat: placeSelected?.location?.coordinate.latitude ?? 0, lon: placeSelected?.location?.coordinate.longitude ?? 0, mName: mname, state: placeSelected?.administrativeArea ?? "", tel: "+"+self.countryCode+telPhone, zip: placeSelected?.postalCode ?? "", custAddrId: custAddrId)), tID: token)
        HitApi.shared.postData("SetUserAddress", bodyData: request) { (result: Result<AddAddressResponse, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let success):
                    UserDefaultsController.shared.userModel?.addressBook?.removeAll(where: {$0.custAddressBookID == success.addressBook.custAddressBookID})
                    UserDefaultsController.shared.userModel?.addressBook?.insert((success.addressBook), at: 0)
                    self.popView = true
                case .failure(let failure):
                    self.error = failure.toString()
            }
        }
    }
    
    func currentLocationtapped() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let status = locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways || status == .notDetermined {
            locationManager.requestLocation()
        } else {
            showLocationError = true
        }
    }
    
    func goToLocationSetting() {
        if let bundleId = Bundle.main.bundleIdentifier,
           let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            if self.selectedAddress == nil {
                locationManager.requestLocation()
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else {return}
        withAnimation {
            region = MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.01,
                    longitudeDelta: 0.01
                )
            )
        }
    }
    
}

extension MKMapItem: Identifiable {}
