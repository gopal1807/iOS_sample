//
//  ProfileView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 09/11/20.
//

import SwiftUI

struct ProfileView: View {
    var viewModel = ProfileViewModel()
    @State var isSharePresented = false
    @State var loading = false
    @State var showOptions = false
    @State var showEditProfile = false
    @State var changePassword = false
    @State var manageAddress = false
    @EnvironmentObject var tabbarViewModel: TabbarSelection
    @State var showDeletedAlert: String?
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(viewModel.name)
                                .font(.title2)
                                .fontWeight(.black)
                            if !viewModel.email.contains("appleid.com") {
                                imageText(image: "envelope.fill", text: viewModel.email)
                            }
                            if !viewModel.phoneNumber.isEmpty {
                                imageText(image: "phone.fill", text: viewModel.phoneNumber)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Button {
                            self.showOptions = true
                        } label: {
                            Text("Edit")
                                .bold()
                                .foregroundColor(.accentColor)
                        }
                        
                    }
                    .padding(.horizontal)
                    VStack {
                        rewardPointCount(icon: "reward", title: "Reward Point", count: viewModel.rewardPoints)
                        rewardPointCount(icon: "totalOrder", title: "Total Orders", count: viewModel.totalOrders)
                        rewardPointCount(icon: "restaurant", title: "Last Order", count: viewModel.lastOrderTime)
                    }
                    .foregroundColor(.white)
                    .font(.title2)
                    .padding(5)
                    .background(Color.appAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .addNeumoShadow()
                    .padding(20)
               
                    Button(action: {
                        tabbarViewModel.pushToOrderHistory = true
                    }) {
                        VStack {
                            Image("orderHistory")
                                .font(.system(size: 50))
                                .padding(.bottom, 16)
                            Text("Order History")
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding()
                        .background(Color.appAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .addNeumoShadow()
                        .padding(.horizontal, 20)
                    }
                    
                    Button(action: {
                        isSharePresented.toggle()
                    }) {
                        HStack {
                            Text("Share with\nFriends & Family")
                            Spacer()
                            Image("friends")
                                .font(.system(size: 50))
                        }
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding()
                        .background(Color.appAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .addNeumoShadow()
                        .padding([.top, .horizontal], 12)
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: logout, label: {
                            Text("LOGOUT")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white)
                                .padding(.vertical)
                                .padding(.horizontal, 40)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [.black, Color.appAccent]), startPoint: .leading, endPoint: .trailing)
                                        .clipShape(Capsule())
                                )
                        })
                        Spacer()
                    }.padding()
                }
            }
            if loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            sheets
        }
        .navigationTitle("")
        .navigationBarHidden(true)
      
    }
    
    var sheets: some View {
        HStack {
            Text("")
                .sheet(isPresented: $isSharePresented, content: {
                    ActivityViewController(activityItems: shareItems())
                })
            
            Text("")
                .sheet(isPresented: $changePassword, content: {
                    ChangePasswordView()
                })
            
            Text("")
                .sheet(isPresented:  $showEditProfile, content: {
                    EditProfileView()
                })
            Text("")
                .actionSheet(isPresented: $showOptions) {
                    ActionSheet(title: Text("Profile"), message: nil, buttons: [
                        .default(Text("Edit Profile")) { self.showEditProfile = true },
                        .default(Text("Manage Address")) { self.manageAddress = true },
                        .default(Text("Change Password")) { self.changePassword = true },
                        .default(Text("Order History")) { tabbarViewModel.pushToOrderHistory = true },
                        .destructive(Text("Delete Account"), action: deleteUser),
                        .cancel()
                    ])
                }
            Text("")
                .alert(item: $showDeletedAlert) { (item) -> Alert in
                    Alert(title: Text("Delete Account"), message: Text(item), dismissButton: Alert.Button.destructive(Text("Ok"), action: {
                        UserDefaultsController.shared.logout()
                    }))
                }
            NavigationLink(
                destination: OrderHistoryView(),
                isActive: $tabbarViewModel.pushToOrderHistory,
                label: { EmptyView() })
            
            NavigationLink(
                destination: SavedAddressView(addressSelectable: false),
                isActive: $manageAddress,
                label: { EmptyView() })
            
        }
    }

    fileprivate func imageText(image: String, text: String) -> some View {
        return HStack {
            Image(systemName:image)
                .foregroundColor(Color.appAccent)
            Text(text)
        }
    }
    
    fileprivate func rewardPointCount(icon: String, title: String, count: String) -> some View {
        return HStack {
            Image(icon)
                .foregroundColor(.white)
            Text(title)
            Spacer()
            Text(count)
        }
        .padding()
        .overlay(Capsule()
                    .strokeBorder(Color(UIColor(white: 0.6, alpha: 1)))
        )
        .padding(5)
    }
    
    func shareItems() -> [Any] {
        var shareString = """
Download the \(appName) Ordering App and Order amazing food from your favourite restaurant now.

Apple App Store/IOS
https://apps.apple.com/us/app/\(iosAppShareId)
"""
        if !androidAppShareId.isEmpty {
            shareString.append("""


Google Play Store/Android
https://play.google.com/store/apps/details?id=\(androidAppShareId)
""")
        }
        return [shareString]
    }
    
    func logout() {
        guard let custId = UserDefaultsController.shared.userModel?.id
        else { return }
        self.loading = true
        AppToken.shared.getToken { (token) in
            let request = FCMRequest(tID: token, data: FCMRequestData(custID: "\(custId)", fcmToken: UserDefaultsController.shared.fcmToken, deviceType: "2", deviceID: ""))
            HitApi.shared.postData("DeleteCustFCMToken", bodyData: request) { (result: Result<String, HitApiError>) in
                self.loading = false
                switch result {
                    case .success(let response):
                        print(response)
                        UserDefaultsController.shared.logout()
                    case .failure(let error):
                        print(error.toString())
                }
            }
        }
    }
    
    func deleteUser() {
        guard let userid: String = UserDefaultsController.shared.userModel?.userid
        else { return }
        self.loading = true
        AppToken.shared.getToken { (token) in
            let tidData = ["UserId": userid, "chainid": "\(chainId)"]
            let requestbody = TidData(data: tidData, tID: token)
            var request = URLRequest(url: URL(string: "https://bellymelly.com/DeleteUseriOS.imsvc")!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let data = try? JSONEncoder().encode(requestbody) else {
                print("bad body request data")
                return
            }
            let newData = ["postData": data.base64EncodedString()]
            request.httpBody = try? JSONSerialization.data(withJSONObject: newData, options: [])
            request.httpMethod = "POST"
            
            URLSession.shared.dataTask(with: request) { data, resp, err in
                DispatchQueue.main.async {
                    self.loading = false
                    guard let data = data else { return }
                    print("-------delete")
                    print(String(data: data, encoding: .utf8) ?? "")
                    print("-------deleteEnd")
                    if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any], let msg = json["message"] as? String {
                        self.showDeletedAlert = msg
                    }
                }
            }.resume()
        }
    }
}

