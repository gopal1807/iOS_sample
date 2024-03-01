//
//  EditProfileView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 18/11/21.
//

import SwiftUI


struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}


struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = EditProfileViewModel()
    
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
    var body: some View {
        viewModel.dismiss = self.dismiss
        return ZStack {
            VStack(alignment: .leading) {
                RedHeaderView(title: "Edit Profile", onBackTap: dismiss)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        AppTextField(leftIcon: Image(systemName: "person.fill"),
                                     rightIcon: EmptyView(),
                                     title: "Enter Your Name",
                                     text: $viewModel.name)
                            .keyboardType(.namePhonePad)
                        AppTextField(leftIcon: Image(systemName: "envelope.fill"),
                                     rightIcon: EmptyView(),
                                     title: "Enter Email Id",
                                     text: $viewModel.emailID)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disabled(true)
                        PhoneNumberTextField(title: "Enter Mobile Number", text: $viewModel.phoneNumber, countryCode: $viewModel.countryCode)
                        
                        Button(action: viewModel.editTapped,
                               label: {
                            Text("Save")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 60)
                                .background(Color("redColor")
                                                .clipShape(Capsule()))
                            
                        })
                            .padding(24)
                            .padding(.bottom)
                    }
                }.padding()
            }
            if viewModel.loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.black)
                    .background(Color.white.opacity(0.3).ignoresSafeArea())
            }
        }
        .alert(item: $viewModel.error, content: { (errString) -> Alert in
            Alert(title: Text(errString))
        })
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

class EditProfileViewModel: ObservableObject {
    @Published var name = ""
    @Published var emailID = ""
    @Published var phoneNumber = ""
    @Published var error: String?
    @Published var loading = false
    @Published var countryCode = "1"
    var dismiss:(() -> ())?
    
    
    init() {
        if let userData = UserDefaultsController.shared.userModel {
            self.name = userData.fullName
            let completeNumber = (userData.tel ?? userData.cell ?? "").seperateCountryCode()
            self.countryCode = completeNumber.0
            self.phoneNumber = completeNumber.1
            self.emailID = userData.email ?? ""
        }
    }
    
    func editTapped() {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.error = "Please enter your name"
        } else if phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.error = "Please enter mobile number"
        } else if !(phoneNumber.isPhoneNumber) {
            self.error = "Please enter a valid phone number"
        } else {
            AppToken.shared.getToken { (token) in
                self.editProfile(token: token)
            }
        }
    }
    
    func editProfile(token: String) {
        let names = name.replacingOccurrences(of: "  ", with: " ").components(separatedBy: " ")
        let fname = names.first ?? ""
        let lname = names.count > 1 ? (names.last ?? "") : ""
        let mname = names.count > 2 ? names[1] : ""
        let phone = "+" + self.countryCode + self.phoneNumber

        guard let userData = UserDefaultsController.shared.userModel else { return }
        let custData = ["custId":"\(userData.id)","fName":fname,"mName":mname,"lName":lname,"tel":phone,"cell":"","eMail":userData.email ?? "","optIn":"F","MobileOptIn":"0"]
        self.loading = true
        HitApi.shared.postData("SetUserProfile", bodyData: TidData(data: ["customerData" : custData], tID: token)) { (result: Result<APIStatusReponse, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let success):
                    if success.serviceStatus == "S" {
                        var userData    = UserDefaultsController.shared.userModel
                        userData?.tel   = "+" + self.countryCode + self.phoneNumber
                        userData?.fName = fname
                        userData?.mName = mname
                        userData?.lName = lname
                        UserDefaultsController.shared.userModel = userData
                        self.dismiss?()
                    } else {
                        self.error = (success.message ?? "Something went wrong")
                    }
                case .failure(let error):
                    self.error = error.toString()
            }
        }
    }
    

}
