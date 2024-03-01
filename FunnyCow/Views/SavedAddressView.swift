//
//  SavedAddressView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 18/11/20.
//

import SwiftUI

struct SavedAddressView: View {
    @Environment(\.presentationMode) var presentation
    @State var addresses = UserDefaultsController.shared.userModel?.addressBook ?? []
    @State var newAddressActive = false
    @State var loading = false
    @State var error: String?
    @State var editAddress = false
    @State var addressEditing: AddressBook?
    let addressSelectable: Bool
    
    var body: some View {
        ZStack {
            VStack {
                VStack(alignment: .leading, spacing: 4) {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "arrow.left").foregroundColor(.white)
                            .font(.system(size: 30))
                    }).padding(.bottom)
                    
                    Text("Saved Address").font(.title).foregroundColor(.white)
                    RoundedRectangle(cornerRadius: 5).frame(width: 60, height: 4).foregroundColor(.white)
                }
                .padding()
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                if addresses.isEmpty {
                    Text("No address found. Please add new Address.")
                        .foregroundColor(Color.white)
                        .frame(height: 200.0)
                    Spacer()
                } else {
                    ScrollView {
                        ForEach(addresses) { savedAddress in
                            addressCell(address: savedAddress)
                                .onTapGesture(perform: {
                                    if addressSelectable {
                                        self.select(savedAddress: savedAddress)
                                    }
                                })
                                .contextMenu {
                                    if !addressSelectable {
                                        Button(action: {
                                            self.delete(savedAddress: savedAddress)
                                        }) {
                                            Label("Delete", systemImage: "minus.circle")
                                        }
                                    }
                                    Button(action: {
                                        self.edit(savedAddress: savedAddress)
                                    }) {
                                        Label("Edit", systemImage: "pencil.circle")
                                    }
                                }
                        }
                    }
                }
                NavigationLink(
                    destination: LazyView(SelectLocationView(address: nil)),
                    isActive: self.$newAddressActive) {
                        EmptyView()
                    }
                
                NavigationLink(isActive: $editAddress) {
                    LazyView(SelectLocationView(address: self.addressEditing))
                } label: {
                    EmptyView()
                }
                
                
                Button(action: {self.newAddressActive.toggle()}, label: {
                    HStack {
                        Image(systemName: "plus").font(.title).foregroundColor(Color("redColor"))
                        Text("ADD NEW ADDRESS")
                            .font(.headline)
                            .foregroundColor(Color.appAccent)
                    }
                    .padding()
                    .background(Color.white
                                    .clipShape(Capsule())
                                    .shadow(color: Color.black.opacity(0.35), radius: 8, x: 8, y: 8)
                                    .shadow(color: Color.white.opacity(0.2), radius: 4, x: -4, y: -4))
                })
                    .padding()
            }
            .background(Color(#colorLiteral(red: 0.9934363961, green: 0.4162771106, blue: 0.009543244727, alpha: 1)).edgesIgnoringSafeArea(.all))
            
            if loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.3).edgesIgnoringSafeArea(.all))
            }
            
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            addresses = UserDefaultsController.shared.userModel?.addressBook ?? []
        }
        .alert(item: $error) { errorItem in
            Alert(title: Text(errorItem))
        }
    }
    
    private func addressCell(address: AddressBook) -> some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack(alignment: .top, spacing: 4) {
                        Text(address.fullName)
                            .font(.subheadline)
                        Spacer()
                        Text(address.telephone)
                            .multilineTextAlignment(.trailing)
                    }
                    .foregroundColor(Color.appAccent)
                    Text(address.completeAddress)
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                VStack {
                    Text(address.custAddressName)
                        .foregroundColor(Color.appAccent)
                    let image = (address.custAddressName.lowercased() == "office") ? "offic" : (address.custAddressName.lowercased() == "home") ? "home-address" : "other-address"
                    Image(image)
                        .font(.title)
                        .foregroundColor(Color.appAccent)
                }
                .padding(.horizontal)
            }
            Divider()
            HStack {
                Text(address.instructions)
                    .foregroundColor(Color.gray)
                Spacer()
                
                Image(systemName: "pencil")
                    .padding(.trailing)
                    .font(.title)
                    .foregroundColor(.gray)
                    .onTapGesture {
                        edit(savedAddress: address)
                    }
                
            }
        }
        .padding(8)
        .background(Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.35), radius: 8, x: 8, y: 8)
                        .shadow(color: Color.white.opacity(0.2), radius: 4, x: -4, y: -4))
        .padding(.horizontal)
    }
    
    private func select(savedAddress: AddressBook) {
        let name = "\(savedAddress.fName) \(savedAddress.mName) \(savedAddress.lName)".replacingOccurrences(of: "  ", with: " ")
        UserDefaultsController.shared.cartSavedData?.deliveryInfo = DeliveryInfo(addr1: savedAddress.addr1, addr2: savedAddress.addr2, addressID: savedAddress.custAddressBookID, city: savedAddress.city, custAddressName: savedAddress.custAddressName, instructions: savedAddress.instructions, latitude: savedAddress.latitude.toDouble, longitude: savedAddress.longitude.toDouble, state: savedAddress.state, zip: savedAddress.zip, name: name, telephone: savedAddress.telephone)
        presentation.wrappedValue.dismiss()
    }
    
    private func edit(savedAddress: AddressBook) {
        self.addressEditing = savedAddress
        self.editAddress = true
    }
    
    private func delete(savedAddress: AddressBook) {
        AppToken.shared.getToken { token in
            self.loading = true
            HitApi.shared.postData("RemoveCustAddress", bodyData: TidData(data: ["customerAddress":["custAddrId":savedAddress.id]], tID: token)) { (result: Result<APIStatusReponse, HitApiError>) in
                self.loading = false
                switch result {
                    case .success(let success):
                        if success.serviceStatus == "S" {
                            UserDefaultsController.shared.userModel?.addressBook?.removeAll(where: {$0.id == savedAddress.id})
                            self.addresses = UserDefaultsController.shared.userModel?.addressBook ?? []
                        } else {
                            self.error = (success.message ?? "Something went wrong")
                        }
                    case .failure(let error):
                        self.error = error.toString()
                }
            }
            
        }
    }
}
