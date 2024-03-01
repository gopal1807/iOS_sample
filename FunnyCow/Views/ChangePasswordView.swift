//
//  ChangePasswordView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 20/11/21.
//

import SwiftUI

//
//  ChangePasswordView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 18/11/21.
//

import SwiftUI


struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
    }
}


struct ChangePasswordView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = ChangePasswordViewModel()
    
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
    

    
    var body: some View {
        viewModel.dismiss = self.dismiss
        return ZStack {
            Text("")
                .alert(isPresented: $viewModel.showSuccessAlert) {
                    Alert(title: Text("Password updated successfully."), message: nil, dismissButton: .default(Text("OK"), action: {
                        self.dismiss()
                    }))
                }
            
            Text("")
                .alert(item: $viewModel.error, content: { (errString) -> Alert in
                    Alert(title: Text(errString))
                })
            VStack(alignment: .leading) {
                RedHeaderView(title: "Change Password", onBackTap: dismiss)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        AppTextField(leftIcon: Image(systemName: "lock.fill"),
                                     rightIcon: Button(action: {
                                        viewModel.securePassword.toggle()
                                     }, label: {
                                        Image(systemName: viewModel.securePassword ? "eye.fill" : "eye.slash.fill").foregroundColor(Color("redColor"))
                                     }
                                     ),
                                     title: "Enter Current Password",
                                     text: $viewModel.oldPassword,
                                     isSecureEntry: viewModel.securePassword)
                        
                        AppTextField(leftIcon: Image(systemName: "lock.fill"),
                                     rightIcon: Button(action: {
                                        viewModel.secureNewPassword.toggle()
                                     }, label: {
                                        Image(systemName: viewModel.secureNewPassword ? "eye.fill" : "eye.slash.fill").foregroundColor(Color("redColor"))
                                     }
                                     ),
                                     title: "Enter New Password",
                                     text: $viewModel.newPassword,
                                     isSecureEntry: viewModel.secureNewPassword)
                        
                        AppTextField(leftIcon: Image(systemName: "lock.fill"),
                                     rightIcon: Button(action: {
                                        viewModel.secureRepeatPassword.toggle()
                                     }, label: {
                                        Image(systemName: viewModel.secureRepeatPassword ? "eye.fill" : "eye.slash.fill").foregroundColor(Color("redColor"))
                                     }
                                     ),
                                     title: "Repeat Password",
                                     text: $viewModel.repeatNewPassword,
                                     isSecureEntry: viewModel.secureRepeatPassword)
                        
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
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

class ChangePasswordViewModel: ObservableObject {
    @Published var securePassword = true
    @Published var secureNewPassword = true
    @Published var secureRepeatPassword = true
    @Published var oldPassword = ""
    @Published var newPassword = ""
    @Published var repeatNewPassword = ""
    @Published var error: String?
    @Published var loading = false
    @Published var showSuccessAlert = false
    
    var dismiss:(() -> ())?
    
    
    
    func editTapped() {
        if oldPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.error = "Please enter your password"
        } else if newPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.error = "Please enter new password"
        } else if newPassword.trimmingCharacters(in: .whitespacesAndNewlines).count < 8 {
            self.error = ("Nice try but password need a minimum of 8 characters")
        } else if repeatNewPassword != newPassword {
            self.error = "New Password and Confirm Password do not match"
        } else {
            AppToken.shared.getToken { (token) in
                self.ChangePassword(token: token)
            }
        }
    }
    
    func ChangePassword(token: String) {
        let id = UserDefaultsController.shared.userModel?.globalUserId ?? -1
        self.loading = true
        HitApi.shared.postData("UpdatePassword", bodyData: TidData(data: ["username":"","oldpassword":oldPassword,"password":newPassword,"GlobalUserId":"\(id)"], tID: token)) { (result: Result<APIStatusReponse, HitApiError>) in
            self.loading = false
            switch result {
                case .success(let success):
                    if success.serviceStatus == "S" {
                        self.showSuccessAlert = true
                    } else {
                        self.error = (success.message ?? "Unable to update the Password")
                    }
                case .failure(let error):
                    self.error = error.toString()
            }
        }
    }
    

}

