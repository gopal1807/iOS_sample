//
//  HomeView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 04/11/20.
//

import SwiftUI
import SDWebImageSwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var viewModel = ChainDetailViewModel()
    var body: some View {
        VStack (spacing: 4){
            (
                Text(viewModel.restaurantName.isEmpty ? "" : "Welcome to ")
                    .foregroundColor(Color.black)
                    + Text(viewModel.restaurantName)
                    .foregroundColor(Color.appAccent)
            )
            .font(.title2)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 8)
            .padding([.leading, .bottom, .trailing])
            .background(Color.white)
            .shadow(color: Color.gray.opacity(0.4), radius: 3, x: 0, y: 3)
            
            if !viewModel.showLoader {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.locationList){ locationCell($0) }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 14)
                }
                .background(Color(#colorLiteral(red: 0.9436354041, green: 0.9436575174, blue: 0.9436456561, alpha: 1)))
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .alert(item: $viewModel.generalError) { (message) -> Alert in
            Alert(title: Text(message))
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
    
    fileprivate func locationCell(_ model: ChainLocationDetail) -> some View {
        return HStack(spacing: 10) {
            NavigationLink(destination: RestaurantMapView(locationDetail: model)) {
                Image("locationImg")
                    .resizable()
                    .foregroundColor(Color.appAccent)
                    .frame(width: 40, height: 40)
                    .padding(12)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.gray.opacity(0.4), radius: 3, x: 3, y: 3)
                    .shadow(color: .white, radius: 4, x: -4, y: -4)
            }
            NavigationLink(destination: RestaurantView(mobUrl: model.urlName.isEmpty ? String(model.id) : model.urlName)) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(model.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 4) {
                            Image("homeMapMarker")
                                .resizable()
                                .foregroundColor(Color.appAccent)
                                .frame(width: 12, height: 12)
                            Text(model.address.toString())
                                .font(.footnote)
                                .multilineTextAlignment(.leading)
                        }
                        Button(action: {
                            viewModel.callRestaurant(detail: model)
                        }) {
                            HStack(spacing: 4) {
                                Image("homePhone")
                                    .resizable()
                                    .foregroundColor(Color.appAccent)
                                    .frame(width: 12, height: 12)
                                Text(model.tel)
                                    .font(.footnote)
                                    .foregroundColor(Color.appAccent)
                            }
                        }
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.appAccent)
                }
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
            .accentColor(.black)
            .shadow(color: Color.gray.opacity(0.4), radius: 3, x: 3, y: 3)
            .shadow(color: .white, radius: 4, x: -4, y: -4)
        }
    }
}


struct RestaurantMapView: View {
    
    init(locationDetail: ChainLocationDetail) {
        self.restaurantName = locationDetail.name
        self.location = CLLocationCoordinate2D(latitude: locationDetail.lat, longitude: locationDetail.lon)
    }
    let restaurantName: String
    let location: CLLocationCoordinate2D
    
    var body: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(center: self.location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))), interactionModes: .all, showsUserLocation: true, userTrackingMode: nil, annotationItems: [
            RestaurantPin(name: restaurantName, coordinate: self.location)
        ]) { item in
            MapPin(coordinate: item.coordinate)
        }
        .navigationBarTitle(Text(restaurantName), displayMode: .inline)
        
    }
}

struct RestaurantPin: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
